import 'package:flutter_test/flutter_test.dart';
import 'package:app.firefly/core/errors/result.dart';
import 'package:app.firefly/core/recommendation_engine/models/action_suggestion.dart';
import 'package:app.firefly/features/check_in/data/repositories/check_in_repository_impl.dart';
import 'package:app.firefly/features/check_in/domain/models/check_in_entry.dart';
import 'package:app.firefly/features/check_in/presentation/controllers/check_in_controller.dart';
import 'package:app.firefly/shared/widgets/mood_tile.dart';

void main() {
  group('CheckInRepository', () {
    late CheckInRepositoryImpl repository;

    setUp(() {
      repository = CheckInRepositoryImpl();
    });

    test('Saves and retrieves latest check-in entry', () async {
      final nowUnix = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final entry = CheckInEntry(
        id: 'test-checkin-1',
        moodCategory: 'anxious',
        energyLevel: 3,
        anxietyLevel: 4,
        lonelinessLevel: 2,
        createdAtUnix: nowUnix,
        updatedAtUnix: nowUnix,
      );

      final saveResult = await repository.saveCheckIn(entry);
      expect(saveResult, isA<Ok<CheckInEntry, Exception>>());

      final latestResult = await repository.getLatestCheckIn();
      expect(latestResult, isA<Ok<CheckInEntry?, Exception>>());
      final retrieved = (latestResult as Ok<CheckInEntry?, Exception>).value;
      expect(retrieved, isNotNull);
      expect(retrieved!.id, equals('test-checkin-1'));
      expect(retrieved.moodCategory, equals('anxious'));
      expect(retrieved.anxietyLevel, equals(4));
    });

    test('Retrieves recent check-ins limited by count', () async {
      for (int i = 1; i <= 5; i++) {
        final entry = CheckInEntry(
          id: 'test-$i',
          moodCategory: 'here',
          energyLevel: i,
          anxietyLevel: 1,
          lonelinessLevel: 1,
          createdAtUnix: i,
          updatedAtUnix: i,
        );
        await repository.saveCheckIn(entry);
      }

      final recentResult = await repository.getRecentCheckIns(limit: 3);
      expect(recentResult, isA<Ok<List<CheckInEntry>, Exception>>());
      final list = (recentResult as Ok<List<CheckInEntry>, Exception>).value;
      expect(list.length, equals(3));
    });
  });

  group('CheckInController', () {
    test('State mutations and submitCheckIn flow', () async {
      final repository = CheckInRepositoryImpl();
      final controller = CheckInController(repository);

      expect(controller.state.selectedMood, equals(MoodCategory.here));
      expect(controller.state.energyLevel, equals(3));
      expect(controller.state.anxietyLevel, equals(2));
      expect(controller.state.lonelinessLevel, equals(2));
      expect(controller.state.activeSuggestion, isNull);

      // Modify values to high anxiety
      controller.setMood(MoodCategory.heavy);
      controller.setEnergy(2);
      controller.setAnxiety(5);
      controller.setLoneliness(1);

      expect(controller.state.selectedMood, equals(MoodCategory.heavy));
      expect(controller.state.anxietyLevel, equals(5));

      // Submit check-in
      final suggestion = await controller.submitCheckIn();

      expect(suggestion.actionType, equals(ActionType.breathing));
      expect(controller.state.activeSuggestion, isNotNull);
      expect(controller.state.activeSuggestion!.actionType, equals(ActionType.breathing));
      expect(controller.state.lastSubmittedEntry, isNotNull);

      // Reset for new check-in
      controller.resetForNewCheckIn();
      expect(controller.state.activeSuggestion, isNull);
      expect(controller.state.selectedMood, equals(MoodCategory.here));
    });
  });
}
