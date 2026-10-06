import '../../../../core/database/daos/activities_dao.dart';
import '../../domain/models/activity_category.dart';
import '../../domain/models/activity_effectiveness_log.dart';
import '../../domain/models/activity_item.dart';
import '../../domain/repositories/activity_repository.dart';
import '../services/activity_seeding_service.dart';

/// Concrete Drift-backed implementation of [ActivityRepository].
class DriftActivityRepository implements ActivityRepository {
  DriftActivityRepository(this._dao, [ActivitySeedingService? seedingService])
      : _seedingService = seedingService ?? ActivitySeedingService(_dao);

  final ActivitiesDao _dao;
  final ActivitySeedingService _seedingService;

  /// Ensures initial catalog seeding is performed once before querying.
  Future<void> initialize() async {
    await _seedingService.seedIfNeeded();
  }

  @override
  Future<List<ActivityItem>> getAllActivities() async {
    return _dao.getAllActivities();
  }

  @override
  Stream<List<ActivityItem>> watchAllActivities() {
    return _dao.watchAllActivities();
  }

  @override
  Future<List<ActivityItem>> getActivitiesForCategory(ActivityCategory category) async {
    return _dao.getActivitiesByCategory(category);
  }

  @override
  Future<List<ActivityItem>> getActivitiesForStateAndEnergy({
    required String state,
    required int maxEnergy,
  }) async {
    return _dao.getActivitiesForStateAndEnergy(
      state: state,
      maxEnergy: maxEnergy,
    );
  }

  @override
  Future<ActivityItem?> getActivityById(String id) async {
    return _dao.getActivityById(id);
  }

  @override
  Future<void> logEffectiveness(ActivityEffectivenessLog log) async {
    await _dao.logEffectiveness(log);
  }

  @override
  Future<List<ActivityEffectivenessLog>> getEffectivenessLogsForActivity(String activityId) async {
    return _dao.getEffectivenessLogsForActivity(activityId);
  }

  @override
  Future<List<ActivityEffectivenessLog>> getAllEffectivenessLogs() async {
    return _dao.getAllEffectivenessLogs();
  }

  @override
  Future<void> clearEffectivenessLogs() async {
    await _dao.clearEffectivenessLogs();
  }

  @override
  Future<double> getAffinityScore(String activityId, String state) async {
    return _dao.getAverageAffinity(activityId, state);
  }

  @override
  Future<void> toggleFavorite(String activityId) async {
    await _dao.toggleFavorite(activityId);
  }

  @override
  Future<void> seedInitialActivities(List<ActivityItem> activities) async {
    await _dao.insertAll(activities);
  }
}
