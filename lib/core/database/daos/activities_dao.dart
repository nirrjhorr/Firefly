import 'dart:async';

import '../../../features/activities/domain/models/activity_category.dart';
import '../../../features/activities/domain/models/activity_effectiveness_log.dart';
import '../../../features/activities/domain/models/activity_item.dart';

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
    try {
      return _activities.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
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
    final logs = await getEffectivenessLogsForActivity(activityId);
    final normalized = state.toLowerCase().trim();
    final relevant = logs.where((l) => l.stateAtStart.toLowerCase().trim() == normalized);
    if (relevant.isEmpty) return 0.0;
    final sum = relevant.fold<int>(0, (prev, l) => prev + l.rating);
    return sum / relevant.length;
  }

  @override
  Future<int> countActivities() async {
    return _activities.length;
  }

  void dispose() {
    _streamController.close();
  }
}
