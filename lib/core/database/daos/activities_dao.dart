import 'dart:async';
import 'dart:convert';
import 'package:drift/drift.dart';
import '../../../features/activities/domain/models/activity_category.dart';
import '../../../features/activities/domain/models/activity_effectiveness_log.dart';
import '../../../features/activities/domain/models/activity_item.dart';
import '../app_database.dart';

/// Data Access Object contract for Activities and ActivityEffectivenessLogs.
abstract class ActivitiesDao {
  Future<void> insertActivity(ActivityItem activity);
  Future<void> insertAll(List<ActivityItem> activities);
  Future<ActivityItem?> getActivityById(String id);
  Future<List<ActivityItem>> getAllActivities();
  Stream<List<ActivityItem>> watchAllActivities();
  Future<List<ActivityItem>> getActivitiesByCategory(ActivityCategory category);
  Future<List<ActivityItem>> getActivitiesForStateAndEnergy({
    required String state,
    required int maxEnergy,
  });
  Future<void> toggleFavorite(String id);
  Future<void> logEffectiveness(ActivityEffectivenessLog log);
  Future<List<ActivityEffectivenessLog>> getEffectivenessLogsForActivity(String activityId);
  Future<double> getAverageAffinity(String activityId, String state);
  Future<int> countActivities();

  factory ActivitiesDao.inMemory([List<ActivityItem>? initialActivities]) =>
      InMemoryActivitiesDao(initialActivities);

  factory ActivitiesDao.drift(AppDatabase db) => DriftActivitiesDao(db);
}

/// In-memory implementation of [ActivitiesDao] for fast isolated tests.
class InMemoryActivitiesDao implements ActivitiesDao {
  InMemoryActivitiesDao([List<ActivityItem>? initialActivities])
      : _activities = List.from(initialActivities ?? []) {
    _streamController = StreamController<List<ActivityItem>>.broadcast();
  }

  final List<ActivityItem> _activities;
  final List<ActivityEffectivenessLog> _logs = [];
  late final StreamController<List<ActivityItem>> _streamController;

  void _notify() {
    _streamController.add(List.unmodifiable(_activities));
  }

  @override
  Future<void> insertActivity(ActivityItem activity) async {
    _activities.removeWhere((a) => a.id == activity.id);
    _activities.add(activity);
    _notify();
  }

  @override
  Future<void> insertAll(List<ActivityItem> activities) async {
    for (final activity in activities) {
      _activities.removeWhere((a) => a.id == activity.id);
      _activities.add(activity);
    }
    _notify();
  }

  @override
  Future<ActivityItem?> getActivityById(String id) async {
    final index = _activities.indexWhere((a) => a.id == id);
    if (index == -1) return null;
    return _activities[index];
  }

  @override
  Future<List<ActivityItem>> getAllActivities() async {
    return List.unmodifiable(_activities);
  }

  @override
  Stream<List<ActivityItem>> watchAllActivities() {
    return _streamController.stream;
  }

  @override
  Future<List<ActivityItem>> getActivitiesByCategory(ActivityCategory category) async {
    return _activities.where((a) => a.category == category).toList();
  }

  @override
  Future<List<ActivityItem>> getActivitiesForStateAndEnergy({
    required String state,
    required int maxEnergy,
  }) async {
    final normalizedState = state.toLowerCase().trim();
    final matched = _activities.where((a) {
      final matchesEnergy = a.energyRequired <= maxEnergy;
      final matchesState = a.targetStates.any(
        (s) => s.toLowerCase().trim() == normalizedState,
      );
      return matchesEnergy && matchesState;
    }).toList();

    if (matched.isNotEmpty) return matched;

    // Fallback: return any activity matching low energy if none match the specific state
    return _activities.where((a) => a.energyRequired <= maxEnergy).toList();
  }

  @override
  Future<void> toggleFavorite(String id) async {
    final index = _activities.indexWhere((a) => a.id == id);
    if (index != -1) {
      final current = _activities[index];
      _activities[index] = current.copyWith(isFavorite: !current.isFavorite);
      _notify();
    }
  }

  @override
  Future<void> logEffectiveness(ActivityEffectivenessLog log) async {
    _logs.add(log);
  }

  @override
  Future<List<ActivityEffectivenessLog>> getEffectivenessLogsForActivity(String activityId) async {
    return _logs.where((l) => l.activityId == activityId).toList();
  }

  @override
  Future<double> getAverageAffinity(String activityId, String state) async {
    final normalizedState = state.toLowerCase().trim();
    final relevant = _logs.where(
      (l) => l.activityId == activityId && l.stateAtStart.toLowerCase().trim() == normalizedState,
    );
    if (relevant.isEmpty) return 0.0;

    final sum = relevant.fold<int>(0, (prev, element) => prev + element.rating);
    return sum / relevant.length;
  }

  @override
  Future<int> countActivities() async => _activities.length;
}

/// Drift implementation of [ActivitiesDao] using SQLCipher queries.
class DriftActivitiesDao implements ActivitiesDao {
  DriftActivitiesDao(this._db);

  final AppDatabase _db;

  @override
  Future<void> insertActivity(ActivityItem activity) async {
    await _db.customInsert(
      '''
      INSERT OR REPLACE INTO activities (
        id, title, description, category, energy_required,
        target_states_json, guidance_type, evidence_level, route,
        duration_minutes, instructions_json, is_custom, is_favorite, created_at_unix
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',
      variables: [
        Variable<String>(activity.id),
        Variable<String>(activity.title),
        Variable<String>(activity.description),
        Variable<String>(activity.category.name),
        Variable<int>(activity.energyRequired),
        Variable<String>(jsonEncode(activity.targetStates.toList())),
        Variable<String>(activity.guidanceType.name),
        Variable<String>(activity.evidenceLevel.name),
        Variable<String>(activity.route),
        Variable<int?>(activity.durationMinutes),
        Variable<String>(jsonEncode(activity.instructions)),
        Variable<bool>(activity.isCustom),
        Variable<bool>(activity.isFavorite),
        Variable<int>(DateTime.now().millisecondsSinceEpoch ~/ 1000),
      ],
    );
  }

  @override
  Future<void> insertAll(List<ActivityItem> activities) async {
    for (final a in activities) {
      await insertActivity(a);
    }
  }

  @override
  Future<ActivityItem?> getActivityById(String id) async {
    final rows = await _db.customSelect(
      'SELECT * FROM activities WHERE id = ?',
      variables: [Variable<String>(id)],
    ).get();

    if (rows.isEmpty) return null;
    return _mapRowToItem(rows.first.data);
  }

  @override
  Future<List<ActivityItem>> getAllActivities() async {
    final rows = await _db.customSelect(
      'SELECT * FROM activities ORDER BY title ASC',
    ).get();

    return rows.map((r) => _mapRowToItem(r.data)).toList();
  }

  @override
  Stream<List<ActivityItem>> watchAllActivities() {
    return _db.customSelect(
      'SELECT * FROM activities ORDER BY title ASC',
    ).watch().map((rows) => rows.map((r) => _mapRowToItem(r.data)).toList());
  }

  @override
  Future<List<ActivityItem>> getActivitiesByCategory(ActivityCategory category) async {
    final rows = await _db.customSelect(
      'SELECT * FROM activities WHERE category = ?',
      variables: [Variable<String>(category.name)],
    ).get();

    return rows.map((r) => _mapRowToItem(r.data)).toList();
  }

  @override
  Future<List<ActivityItem>> getActivitiesForStateAndEnergy({
    required String state,
    required int maxEnergy,
  }) async {
    final all = await getAllActivities();
    final normalizedState = state.toLowerCase().trim();

    final matched = all.where((a) {
      final matchesEnergy = a.energyRequired <= maxEnergy;
      final matchesState = a.targetStates.any(
        (s) => s.toLowerCase().trim() == normalizedState,
      );
      return matchesEnergy && matchesState;
    }).toList();

    if (matched.isNotEmpty) return matched;
    return all.where((a) => a.energyRequired <= maxEnergy).toList();
  }

  @override
  Future<void> toggleFavorite(String id) async {
    final current = await getActivityById(id);
    if (current != null) {
      final newFavorite = !current.isFavorite;
      await _db.customUpdate(
        'UPDATE activities SET is_favorite = ? WHERE id = ?',
        variables: [Variable<bool>(newFavorite), Variable<String>(id)],
      );
    }
  }

  @override
  Future<void> logEffectiveness(ActivityEffectivenessLog log) async {
    await _db.customInsert(
      '''
      INSERT INTO activity_effectiveness_logs (
        id, activity_id, state_at_start, rating, duration_seconds, timestamp_unix
      ) VALUES (?, ?, ?, ?, ?, ?)
      ''',
      variables: [
        Variable<String>(log.id),
        Variable<String>(log.activityId),
        Variable<String>(log.stateAtStart),
        Variable<int>(log.rating),
        Variable<int>(log.durationSeconds),
        Variable<int>(log.timestamp.millisecondsSinceEpoch ~/ 1000),
      ],
    );
  }

  @override
  Future<List<ActivityEffectivenessLog>> getEffectivenessLogsForActivity(String activityId) async {
    final rows = await _db.customSelect(
      'SELECT * FROM activity_effectiveness_logs WHERE activity_id = ? ORDER BY timestamp_unix DESC',
      variables: [Variable<String>(activityId)],
    ).get();

    return rows.map((r) {
      final data = r.data;
      return ActivityEffectivenessLog(
        id: data['id'] as String,
        activityId: data['activity_id'] as String,
        stateAtStart: data['state_at_start'] as String,
        rating: data['rating'] as int,
        durationSeconds: data['duration_seconds'] as int,
        timestamp: DateTime.fromMillisecondsSinceEpoch((data['timestamp_unix'] as int) * 1000),
      );
    }).toList();
  }

  @override
  Future<double> getAverageAffinity(String activityId, String state) async {
    final logs = await getEffectivenessLogsForActivity(activityId);
    final normalized = state.toLowerCase().trim();
    final relevant = logs.where((l) => l.stateAtStart.toLowerCase().trim() == normalized);
    if (relevant.isEmpty) return 0.0;
    final sum = relevant.fold<int>(0, (prev, l) => prev + l.rating);
    return sum / relevant.length;
  }

  @override
  Future<int> countActivities() async {
    final rows = await _db.customSelect(
      'SELECT COUNT(*) AS c FROM activities',
    ).get();

    if (rows.isEmpty) return 0;
    return (rows.first.data['c'] as num?)?.toInt() ?? 0;
  }

  ActivityItem _mapRowToItem(Map<String, dynamic> row) {
    Set<String> targets = {};
    if (row['target_states_json'] != null) {
      try {
        final decoded = jsonDecode(row['target_states_json'] as String) as List<dynamic>;
        targets = decoded.map((e) => e.toString().toLowerCase()).toSet();
      } catch (_) {}
    }

    List<String> instructions = [];
    if (row['instructions_json'] != null) {
      try {
        final decoded = jsonDecode(row['instructions_json'] as String) as List<dynamic>;
        instructions = decoded.map((e) => e.toString()).toList();
      } catch (_) {}
    }

    final isFav = row['is_favorite'];
    final bool isFavoriteBool = isFav is bool ? isFav : (isFav == 1);

    final isCust = row['is_custom'];
    final bool isCustomBool = isCust is bool ? isCust : (isCust == 1);

    return ActivityItem(
      id: row['id'] as String,
      title: row['title'] as String,
      description: row['description'] as String,
      category: ActivityCategory.fromString(row['category'] as String),
      energyRequired: row['energy_required'] as int,
      targetStates: targets,
      guidanceType: GuidanceType.fromString(row['guidance_type'] as String),
      evidenceLevel: EvidenceLevel.fromString(row['evidence_level'] as String),
      route: row['route'] as String,
      durationMinutes: row['duration_minutes'] as int?,
      instructions: instructions,
      isCustom: isCustomBool,
      isFavorite: isFavoriteBool,
    );
  }
}
