import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:firefly/core/database/daos/activities_dao.dart';
import 'package:firefly/features/activities/data/repositories/drift_activity_repository.dart';
import 'package:firefly/features/activities/domain/models/activity_category.dart';
import 'package:firefly/features/activities/domain/models/activity_effectiveness_log.dart';
import 'package:firefly/features/activities/domain/models/activity_item.dart';

void main() {
  group('ActivityRepository & InMemoryDao Tests', () {
    late ActivitiesDao dao;
    late DriftActivityRepository repository;

    setUp(() {
      dao = ActivitiesDao.inMemory();
      repository = DriftActivityRepository(dao);
    });

    test('curated_activities.json parses with 50+ valid items across all categories', () {
      final file = File('assets/data/curated_activities.json');
      expect(file.existsSync(), isTrue);

      final content = file.readAsStringSync();
      final decoded = jsonDecode(content) as List<dynamic>;

      expect(decoded.length, greaterThanOrEqualTo(50));

      final categoriesFound = <ActivityCategory>{};
      for (final raw in decoded) {
        final item = ActivityItem.fromJson(raw as Map<String, dynamic>);
        expect(item.id, isNotEmpty);
        expect(item.title, isNotEmpty);
        expect(item.energyRequired, inInclusiveRange(1, 5));
        expect(item.targetStates, isNotEmpty);
        categoriesFound.add(item.category);
      }

      // Check representation across the taxonomy
      expect(categoriesFound.contains(ActivityCategory.respiration), isTrue);
      expect(categoriesFound.contains(ActivityCategory.pmr), isTrue);
      expect(categoriesFound.contains(ActivityCategory.sensoryGrounding), isTrue);
      expect(categoriesFound.contains(ActivityCategory.cognitiveGrounding), isTrue);
      expect(categoriesFound.contains(ActivityCategory.flow), isTrue);
      expect(categoriesFound.contains(ActivityCategory.behavioralActivation), isTrue);
      expect(categoriesFound.contains(ActivityCategory.sleep), isTrue);
      expect(categoriesFound.contains(ActivityCategory.social), isTrue);
    });

    test('state and energy filtering returns matching activities', () async {
      const breathing = ActivityItem(
        id: 'breath_1',
        title: 'Deep Breath',
        description: 'Breathe',
        category: ActivityCategory.respiration,
        energyRequired: 1,
        targetStates: {'anxious', 'panicked'},
        guidanceType: GuidanceType.interactivePainter,
        evidenceLevel: EvidenceLevel.verified,
        route: '/home/breathe',
      );

      const moving = ActivityItem(
        id: 'move_1',
        title: 'Brisk Walk',
        description: 'Walk',
        category: ActivityCategory.physical,
        energyRequired: 3,
        targetStates: {'restless'},
        guidanceType: GuidanceType.timerWithAudio,
        evidenceLevel: EvidenceLevel.verified,
        route: '/home/move',
      );

      await dao.insertAll([breathing, moving]);

      final anxiousResults = await repository.getActivitiesForStateAndEnergy(
        state: 'anxious',
        maxEnergy: 2,
      );

      expect(anxiousResults.length, 1);
      expect(anxiousResults.first.id, 'breath_1');

      final highEnergyResults = await repository.getActivitiesForStateAndEnergy(
        state: 'restless',
        maxEnergy: 3,
      );

      expect(highEnergyResults.length, 1);
      expect(highEnergyResults.first.id, 'move_1');
    });

    test('fallback returns low energy items when specific state has no matches', () async {
      const breathing = ActivityItem(
        id: 'breath_1',
        title: 'Deep Breath',
        description: 'Breathe',
        category: ActivityCategory.respiration,
        energyRequired: 1,
        targetStates: {'anxious'},
        guidanceType: GuidanceType.interactivePainter,
        evidenceLevel: EvidenceLevel.verified,
        route: '/home/breathe',
      );

      await dao.insertActivity(breathing);

      // Querying state 'unknownState' at energy 1 should fall back to low energy items
      final fallbackResults = await repository.getActivitiesForStateAndEnergy(
        state: 'unknownState',
        maxEnergy: 1,
      );

      expect(fallbackResults.length, 1);
      expect(fallbackResults.first.id, 'breath_1');
    });

    test('effectiveness logging and affinity score calculation', () async {
      final log1 = ActivityEffectivenessLog(
        id: 'l1',
        activityId: 'act_cyclic_sighing',
        stateAtStart: 'anxious',
        rating: 2, // Much better
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        durationSeconds: 180,
      );

      final log2 = ActivityEffectivenessLog(
        id: 'l2',
        activityId: 'act_cyclic_sighing',
        stateAtStart: 'anxious',
        rating: 1, // A little better
        timestamp: DateTime.now(),
        durationSeconds: 200,
      );

      await repository.logEffectiveness(log1);
      await repository.logEffectiveness(log2);

      final logs = await repository.getEffectivenessLogsForActivity('act_cyclic_sighing');
      expect(logs.length, 2);

      final affinity = await repository.getAffinityScore('act_cyclic_sighing', 'anxious');
      // Average of +2 and +1 is 1.5
      expect(affinity, 1.5);

      final unknownStateAffinity = await repository.getAffinityScore('act_cyclic_sighing', 'restless');
      expect(unknownStateAffinity, 0.0);
    });

    test('toggleFavorite toggles state cleanly', () async {
      const item = ActivityItem(
        id: 'fav_test',
        title: 'Fav Item',
        description: 'Desc',
        category: ActivityCategory.flow,
        energyRequired: 1,
        targetStates: {'racingThoughts'},
        guidanceType: GuidanceType.interactivePainter,
        evidenceLevel: EvidenceLevel.moderate,
        route: '/home/flow',
        isFavorite: false,
      );

      await dao.insertActivity(item);

      await repository.toggleFavorite('fav_test');
      var fetched = await repository.getActivityById('fav_test');
      expect(fetched?.isFavorite, isTrue);

      await repository.toggleFavorite('fav_test');
      fetched = await repository.getActivityById('fav_test');
      expect(fetched?.isFavorite, isFalse);
    });
  });
}
