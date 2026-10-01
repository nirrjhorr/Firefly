import 'package:flutter_test/flutter_test.dart';
import 'package:firefly/features/tiny_steps/domain/models/tiny_step.dart';
import 'package:firefly/features/tiny_steps/domain/data/curated_tiny_steps.dart';

void main() {
  group('TinyStep Domain Model', () {
    test('instantiates valid TinyStep successfully', () {
      const step = TinyStep(
        id: 'test_step',
        title: 'Test Title',
        description: 'Test Description',
        category: TinyStepCategory.physical,
        minEnergyLevel: 2,
        maxEnergyLevel: 4,
        durationMinutes: 1,
      );

      expect(step.id, 'test_step');
      expect(step.title, 'Test Title');
      expect(step.description, 'Test Description');
      expect(step.category, TinyStepCategory.physical);
      expect(step.minEnergyLevel, 2);
      expect(step.maxEnergyLevel, 4);
      expect(step.durationMinutes, 1);
    });

    test('asserts invalid energy bounds and duration', () {
      // minEnergyLevel < 1
      expect(
        () => TinyStep(
          id: '1',
          title: 't',
          description: 'd',
          category: TinyStepCategory.sensory,
          minEnergyLevel: 0,
          maxEnergyLevel: 3,
          durationMinutes: 1,
        ),
        throwsAssertionError,
      );

      // maxEnergyLevel > 5
      expect(
        () => TinyStep(
          id: '2',
          title: 't',
          description: 'd',
          category: TinyStepCategory.sensory,
          minEnergyLevel: 2,
          maxEnergyLevel: 6,
          durationMinutes: 1,
        ),
        throwsAssertionError,
      );

      // minEnergyLevel > maxEnergyLevel
      expect(
        () => TinyStep(
          id: '3',
          title: 't',
          description: 'd',
          category: TinyStepCategory.sensory,
          minEnergyLevel: 4,
          maxEnergyLevel: 2,
          durationMinutes: 1,
        ),
        throwsAssertionError,
      );

      // durationMinutes > 2
      expect(
        () => TinyStep(
          id: '4',
          title: 't',
          description: 'd',
          category: TinyStepCategory.sensory,
          minEnergyLevel: 1,
          maxEnergyLevel: 2,
          durationMinutes: 3,
        ),
        throwsAssertionError,
      );

      // durationMinutes <= 0
      expect(
        () => TinyStep(
          id: '5',
          title: 't',
          description: 'd',
          category: TinyStepCategory.sensory,
          minEnergyLevel: 1,
          maxEnergyLevel: 2,
          durationMinutes: 0,
        ),
        throwsAssertionError,
      );
    });

    test('matchesEnergy accurately evaluates ranges', () {
      const step = TinyStep(
        id: 'test_step',
        title: 'Test Title',
        description: 'Test Description',
        category: TinyStepCategory.nourishment,
        minEnergyLevel: 2,
        maxEnergyLevel: 3,
        durationMinutes: 2,
      );

      expect(step.matchesEnergy(1), isFalse);
      expect(step.matchesEnergy(2), isTrue);
      expect(step.matchesEnergy(3), isTrue);
      expect(step.matchesEnergy(4), isFalse);
      expect(step.matchesEnergy(5), isFalse);
    });

    test('toJson and fromJson serialize and deserialize correctly', () {
      const step = TinyStep(
        id: 'serialize_test',
        title: 'Mindful Sip',
        description: 'Drink a sip',
        category: TinyStepCategory.nourishment,
        minEnergyLevel: 1,
        maxEnergyLevel: 2,
        durationMinutes: 1,
      );

      final json = step.toJson();
      expect(json['id'], 'serialize_test');
      expect(json['category'], 'nourishment');

      final deserialized = TinyStep.fromJson(json);
      expect(deserialized, equals(step));
    });

    test('copyWith works as expected', () {
      const step = TinyStep(
        id: 'orig',
        title: 'Orig Title',
        description: 'Orig Desc',
        category: TinyStepCategory.environment,
        minEnergyLevel: 2,
        maxEnergyLevel: 3,
        durationMinutes: 1,
      );

      final modified = step.copyWith(title: 'New Title', durationMinutes: 2);
      expect(modified.id, 'orig');
      expect(modified.title, 'New Title');
      expect(modified.durationMinutes, 2);
      expect(modified.description, 'Orig Desc');
    });
  });

  group('TinyStepsCatalog & Micro-Action Library', () {
    test('contains at least 20 curated micro-actions', () {
      expect(TinyStepsCatalog.allSteps.length, greaterThanOrEqualTo(20));
      expect(TinyStepsCatalog.allSteps.length, equals(24));
    });

    test('all micro-actions have unique IDs', () {
      final ids = TinyStepsCatalog.allSteps.map((s) => s.id).toSet();
      expect(ids.length, equals(TinyStepsCatalog.allSteps.length));
    });

    test('all micro-actions have valid durations <= 2 minutes and non-empty text', () {
      for (final step in TinyStepsCatalog.allSteps) {
        expect(step.durationMinutes, inInclusiveRange(1, 2));
        expect(step.title.trim().isNotEmpty, isTrue, reason: '${step.id} has empty title');
        expect(step.description.trim().isNotEmpty, isTrue, reason: '${step.id} has empty description');
        expect(step.minEnergyLevel, inInclusiveRange(1, 5));
        expect(step.maxEnergyLevel, inInclusiveRange(1, 5));
        expect(step.minEnergyLevel, lessThanOrEqualTo(step.maxEnergyLevel));
      }
    });

    test('adequate distribution across all categories', () {
      for (final category in TinyStepCategory.values) {
        final matches = TinyStepsCatalog.getStepsByCategory(category);
        expect(matches.length, greaterThanOrEqualTo(3),
            reason: 'Category ${category.name} should have at least 3 actions');
      }
    });

    test('adequate distribution across all energy levels (1 through 5)', () {
      for (int energy = 1; energy <= 5; energy++) {
        final matchingSteps = TinyStepsCatalog.getStepsForEnergy(energy);
        expect(matchingSteps.length, greaterThanOrEqualTo(4),
            reason: 'Energy level $energy should have at least 4 candidate actions');
      }
    });

    test('very low energy (1-2) offers gentle, low-friction tasks', () {
      final lowEnergySteps = TinyStepsCatalog.getStepsForEnergy(1);
      final titles = lowEnergySteps.map((s) => s.title.toLowerCase()).toList();
      expect(titles.any((t) => t.contains('sip') || t.contains('water')), isTrue);
      expect(titles.any((t) => t.contains('unclench') || t.contains('jaw')), isTrue);
      expect(titles.any((t) => t.contains('window')), isTrue);
      expect(titles.any((t) => t.contains('feet') || t.contains('floor')), isTrue);
    });

    test('moderate energy (3) offers mild activating actions', () {
      final midEnergySteps = TinyStepsCatalog.getStepsForEnergy(3);
      final titles = midEnergySteps.map((s) => s.title.toLowerCase()).toList();
      expect(titles.any((t) => t.contains('face') || t.contains('water')), isTrue);
      expect(titles.any((t) => t.contains('stretch') || t.contains('arms')), isTrue);
      expect(titles.any((t) => t.contains('outside') || t.contains('air')), isTrue);
    });

    test('higher energy (4-5) offers momentum-building tasks', () {
      final highEnergySteps = TinyStepsCatalog.getStepsForEnergy(5);
      final titles = highEnergySteps.map((s) => s.title.toLowerCase()).toList();
      expect(titles.any((t) => t.contains('surface') || t.contains('tidy') || t.contains('clear')), isTrue);
      expect(titles.any((t) => t.contains('three') || t.contains('misplaced')), isTrue);
    });

    test('getStepById finds item by ID or returns null if not found', () {
      final step = TinyStepsCatalog.getStepById('sip_water');
      expect(step, isNotNull);
      expect(step!.title, 'Take a slow sip of water');

      final nonexistent = TinyStepsCatalog.getStepById('non_existent_id');
      expect(nonexistent, isNull);
    });
  });
}
