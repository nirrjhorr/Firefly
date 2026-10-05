import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/daos/activities_dao.dart';
import '../../data/repositories/drift_activity_repository.dart';
import '../../domain/models/activity_category.dart';
import '../../domain/models/activity_item.dart';
import '../../domain/repositories/activity_repository.dart';

/// Provider for [ActivitiesDao]. In testing or standalone mode, falls back to in-memory DAO.
final activitiesDaoProvider = Provider<ActivitiesDao>((ref) {
  return ActivitiesDao.inMemory();
});

/// Provider for [ActivityRepository].
final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  final dao = ref.watch(activitiesDaoProvider);
  return DriftActivityRepository(dao);
});

/// Stream provider for all activities.
final allActivitiesStreamProvider = StreamProvider<List<ActivityItem>>((ref) {
  final repository = ref.watch(activityRepositoryProvider);
  return repository.watchAllActivities();
});

/// Family provider to query state-matched activities for a given (state, energy) pair.
final stateMatchedActivitiesProvider = FutureProvider.family<List<ActivityItem>, ({String state, int maxEnergy})>(
  (ref, params) async {
    final repository = ref.watch(activityRepositoryProvider);
    return repository.getActivitiesForStateAndEnergy(
      state: params.state,
      maxEnergy: params.maxEnergy,
    );
  },
);

/// Family provider to query activities by [ActivityCategory].
final categoryActivitiesProvider = FutureProvider.family<List<ActivityItem>, ActivityCategory>(
  (ref, category) async {
    final repository = ref.watch(activityRepositoryProvider);
    return repository.getActivitiesForCategory(category);
  },
);
