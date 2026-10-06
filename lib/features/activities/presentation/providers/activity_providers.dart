import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/daos/activities_dao.dart';
import '../../data/repositories/drift_activity_repository.dart';
import '../../domain/models/activity_category.dart';
import '../../domain/models/activity_item.dart';
import '../../domain/models/regulation_group.dart';
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

/// Complete activity catalog provider that guarantees all curated activities
/// are loaded from the bundled asset or fallback.
final activityCatalogProvider = FutureProvider<List<ActivityItem>>((ref) async {
  final repository = ref.watch(activityRepositoryProvider);
  if (repository is DriftActivityRepository) {
    await repository.initialize();
  }
  var list = await repository.getAllActivities();
  if (list.isEmpty) {
    // If database was empty and rootBundle available, parse directly
    try {
      final jsonString = await rootBundle.loadString('assets/data/curated_activities.json');
      final decoded = jsonDecode(jsonString) as List<dynamic>;
      list = decoded.map((e) => ActivityItem.fromJson(e as Map<String, dynamic>)).toList();
      final dao = ref.read(activitiesDaoProvider);
      await dao.insertAll(list);
    } catch (_) {
      // Fallback
    }
  }
  return list;
});

/// Currently selected regulation group tab.
final selectedRegulationGroupProvider = StateProvider<RegulationGroup>((ref) {
  return RegulationGroup.all;
});

/// Search filter query for activity library.
final activitySearchQueryProvider = StateProvider<String>((ref) {
  return '';
});

/// Optional energy filter: null for all, or 1 to 5.
final activityEnergyFilterProvider = StateProvider<int?>((ref) {
  return null;
});

/// Filtered activities derived from selected group, search query, and energy tier.
final filteredActivitiesProvider = Provider<List<ActivityItem>>((ref) {
  final catalogAsync = ref.watch(activityCatalogProvider);
  final allActivities = catalogAsync.value ?? [];
  final selectedGroup = ref.watch(selectedRegulationGroupProvider);
  final query = ref.watch(activitySearchQueryProvider).trim().toLowerCase();
  final energyFilter = ref.watch(activityEnergyFilterProvider);

  return allActivities.where((activity) {
    // 1. Group filtering
    if (!selectedGroup.matches(activity.category)) {
      return false;
    }

    // 2. Energy filtering
    if (energyFilter != null && activity.energyRequired != energyFilter) {
      return false;
    }

    // 3. Search query filtering
    if (query.isNotEmpty) {
      final titleMatch = activity.title.toLowerCase().contains(query);
      final descMatch = activity.description.toLowerCase().contains(query);
      final catMatch = activity.category.displayName.toLowerCase().contains(query);
      final tagMatch = activity.targetStates.any((s) => s.toLowerCase().contains(query));
      if (!titleMatch && !descMatch && !catMatch && !tagMatch) {
        return false;
      }
    }

    return true;
  }).toList();
});

/// Counts of activities for each regulation group to display on tab badges.
final groupActivityCountsProvider = Provider<Map<RegulationGroup, int>>((ref) {
  final catalogAsync = ref.watch(activityCatalogProvider);
  final all = catalogAsync.value ?? [];
  final counts = <RegulationGroup, int>{};

  for (final group in RegulationGroup.values) {
    if (group == RegulationGroup.all) {
      counts[group] = all.length;
    } else {
      counts[group] = all.where((a) => group.matches(a.category)).length;
    }
  }

  return counts;
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
