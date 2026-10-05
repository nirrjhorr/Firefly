import 'package:flutter_test/flutter_test.dart';
import 'package:firefly/features/activities/domain/models/activity_category.dart';
import 'package:firefly/features/activities/domain/models/activity_effectiveness_log.dart';
import 'package:firefly/features/activities/domain/models/activity_item.dart';

void main() {
  group('ActivityCategory Enum Tests', () {
    test('all 16 categories have valid display names and icon keys', () {
      expect(ActivityCategory.values.length, 16);
      for (final cat in ActivityCategory.values) {
        expect(cat.displayName, isNotEmpty);
        expect(cat.iconKey, isNotEmpty);
      }
    });

    test('fromString parses correctly and defaults safely', () {
      expect(ActivityCategory.fromString('respiration'), ActivityCategory.respiration);
      expect(ActivityCategory.fromString('pmr'), ActivityCategory.pmr);
      expect(ActivityCategory.fromString('flow'), ActivityCategory.flow);
      expect(ActivityCategory.fromString('unknown_category'), ActivityCategory.sensoryGrounding);
    });
  });

  group('ActivityItem Domain Model Tests', () {
    test('instantiates valid ActivityItem successfully', () {
      const item = ActivityItem(
        id: 'test_box_breathing',
        title: 'Box Breathing',
        description: 'Equal intervals of inhale, hold, exhale, hold.',
        category: ActivityCategory.respiration,
        energyRequired: 1,
        targetStates: {'anxious', 'panicked'},
        guidanceType: GuidanceType.interactivePainter,
        evidenceLevel: EvidenceLevel.verified,
        route: '/home/breathe?technique=boxBreathing',
        durationMinutes: 4,
      );

      expect(item.id, 'test_box_breathing');
      expect(item.title, 'Box Breathing');
      expect(item.category, ActivityCategory.respiration);
      expect(item.energyRequired, 1);
      expect(item.targetStates.contains('anxious'), isTrue);
      expect(item.guidanceType, GuidanceType.interactivePainter);
      expect(item.evidenceLevel, EvidenceLevel.verified);
      expect(item.durationMinutes, 4);
      expect(item.isFavorite, isFalse);
    });

    test('asserts invalid energy bounds and duration', () {
      expect(
        () => ActivityItem(
          id: 'test',
          title: 'Title',
          description: 'Desc',
          category: ActivityCategory.physical,
          energyRequired: 0,
          targetStates: {'anxious'},
          guidanceType: GuidanceType.stepSequence,
          evidenceLevel: EvidenceLevel.moderate,
          route: '/home',
        ),
        throwsAssertionError,
      );

      expect(
        () => ActivityItem(
          id: 'test',
          title: 'Title',
          description: 'Desc',
          category: ActivityCategory.physical,
          energyRequired: 6,
          targetStates: {'anxious'},
          guidanceType: GuidanceType.stepSequence,
          evidenceLevel: EvidenceLevel.moderate,
          route: '/home',
        ),
        throwsAssertionError,
      );

      expect(
        () => ActivityItem(
          id: 'test',
          title: 'Title',
          description: 'Desc',
          category: ActivityCategory.physical,
          energyRequired: 3,
          targetStates: {'anxious'},
          guidanceType: GuidanceType.stepSequence,
          evidenceLevel: EvidenceLevel.moderate,
          route: '/home',
          durationMinutes: -1,
        ),
        throwsAssertionError,
      );
    });

    test('JSON serialization and deserialization roundtrip', () {
      const original = ActivityItem(
        id: 'pmr_10_zone',
        title: 'Full Body PMR',
        description: 'Tension and release sequence',
        category: ActivityCategory.pmr,
        energyRequired: 2,
        targetStates: {'anxious', 'restless'},
        guidanceType: GuidanceType.interactiveMap,
        evidenceLevel: EvidenceLevel.verified,
        route: '/home/pmr',
        durationMinutes: 8,
        instructions: ['Tense forehead', 'Release jaw'],
        isCustom: false,
        isFavorite: true,
      );

      final json = original.toJson();
      final reconstructed = ActivityItem.fromJson(json);

      expect(reconstructed.id, original.id);
      expect(reconstructed.title, original.title);
      expect(reconstructed.category, original.category);
      expect(reconstructed.energyRequired, original.energyRequired);
      expect(reconstructed.targetStates, original.targetStates);
      expect(reconstructed.guidanceType, original.guidanceType);
      expect(reconstructed.evidenceLevel, original.evidenceLevel);
      expect(reconstructed.route, original.route);
      expect(reconstructed.durationMinutes, original.durationMinutes);
      expect(reconstructed.instructions, original.instructions);
      expect(reconstructed.isFavorite, original.isFavorite);
    });

    test('copyWith updates specified fields only', () {
      const original = ActivityItem(
        id: 'orig',
        title: 'Original',
        description: 'Desc',
        category: ActivityCategory.nature,
        energyRequired: 1,
        targetStates: {'flat'},
        guidanceType: GuidanceType.timerWithAudio,
        evidenceLevel: EvidenceLevel.moderate,
        route: '/home',
      );

      final updated = original.copyWith(
        title: 'Updated Title',
        isFavorite: true,
      );

      expect(updated.id, 'orig');
      expect(updated.title, 'Updated Title');
      expect(updated.isFavorite, isTrue);
      expect(updated.category, ActivityCategory.nature);
    });
  });

  group('ActivityEffectivenessLog Domain Tests', () {
    test('instantiates and validates rating bounds', () {
      final log = ActivityEffectivenessLog(
        id: 'log_1',
        activityId: 'act_cyclic_sighing',
        stateAtStart: 'anxious',
        rating: 1,
        timestamp: DateTime(2026, 10, 5, 20, 0),
        durationSeconds: 180,
      );

      expect(log.rating, 1);
      expect(log.stateAtStart, 'anxious');
      expect(log.durationSeconds, 180);

      expect(
        () => ActivityEffectivenessLog(
          id: 'log_invalid',
          activityId: 'act_1',
          stateAtStart: 'anxious',
          rating: 3, // Out of bounds (> 2)
          timestamp: DateTime.now(),
          durationSeconds: 60,
        ),
        throwsAssertionError,
      );
    });

    test('JSON serialization roundtrip for ActivityEffectivenessLog', () {
      final log = ActivityEffectivenessLog(
        id: 'log_roundtrip',
        activityId: 'act_box_breathing',
        stateAtStart: 'racingThoughts',
        rating: 2,
        timestamp: DateTime(2026, 10, 5, 21, 30),
        durationSeconds: 240,
      );

      final json = log.toJson();
      final parsed = ActivityEffectivenessLog.fromJson(json);

      expect(parsed.id, log.id);
      expect(parsed.activityId, log.activityId);
      expect(parsed.stateAtStart, log.stateAtStart);
      expect(parsed.rating, log.rating);
      expect(parsed.durationSeconds, log.durationSeconds);
      expect(parsed.timestamp, log.timestamp);
    });
  });
}
