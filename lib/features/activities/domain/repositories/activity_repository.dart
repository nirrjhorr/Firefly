import '../models/activity_category.dart';
import '../models/activity_effectiveness_log.dart';
import '../models/activity_item.dart';

/// Clean Architecture interface for accessing and logging self-regulation activities.
abstract class ActivityRepository {
  /// Returns all available activities.
  Future<List<ActivityItem>> getAllActivities();

  /// Emits whenever the activity catalog changes.
  Stream<List<ActivityItem>> watchAllActivities();

  /// Filters activities by the given category.
  Future<List<ActivityItem>> getActivitiesForCategory(ActivityCategory category);

  /// State-matched filtering: returns activities suitable for [state] at or below [maxEnergy].
  Future<List<ActivityItem>> getActivitiesForStateAndEnergy({
    required String state,
    required int maxEnergy,
  });

  /// Fetches an individual activity by ID.
  Future<ActivityItem?> getActivityById(String id);

  /// Appends an effectiveness rating log after an exercise session.
  Future<void> logEffectiveness(ActivityEffectivenessLog log);

  /// Retrieves past effectiveness logs for a given activity.
  Future<List<ActivityEffectivenessLog>> getEffectivenessLogsForActivity(String activityId);

  /// Computes the exponential moving average (EMA) affinity score for an activity in a given state.
  Future<double> getAffinityScore(String activityId, String state);

  /// Toggles whether an activity is marked as favorite by the user.
  Future<void> toggleFavorite(String activityId);

  /// Idempotently seeds initial catalog items if the database is empty.
  Future<void> seedInitialActivities(List<ActivityItem> activities);
}
