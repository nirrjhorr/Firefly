import 'package:flutter_test/flutter_test.dart';
import 'package:firefly/core/errors/result.dart';
import 'package:firefly/features/check_in/domain/models/check_in_entry.dart';
import 'package:firefly/features/check_in/domain/repositories/check_in_repository.dart';
import 'package:firefly/features/tiny_steps/presentation/controllers/tiny_steps_controller.dart';

class MockCheckInRepository implements CheckInRepository {
  CheckInEntry? mockLatest;

  @override
  Future<Result<CheckInEntry?, Exception>> getLatestCheckIn() async {
    return Ok(mockLatest);
  }

  @override
  Future<Result<List<CheckInEntry>, Exception>> getRecentCheckIns({int limit = 10}) async {
    if (mockLatest != null) {
      return Ok([mockLatest!]);
    }
    return const Ok([]);
  }

  @override
  Future<Result<CheckInEntry, Exception>> saveCheckIn(CheckInEntry entry) async {
    mockLatest = entry;
    return Ok(entry);
  }
}

void main() {
  group('TinyStepsController', () {
    test('initializes with default energy 2 when no check-in exists', () async {
      final controller = TinyStepsController();
      // Allow async _init to complete
      await Future<void>.delayed(Duration.zero);

      expect(controller.state.isLoading, isFalse);
      expect(controller.state.energyLevel, equals(2));
      expect(controller.state.candidates.length, equals(3));
      expect(controller.state.hasCompleted, isFalse);
      expect(controller.state.completedStepId, isNull);

      // Verify all candidates match energy level 2
      for (final candidate in controller.state.candidates) {
        expect(candidate.matchesEnergy(2), isTrue);
      }

      // Verify all 3 candidates are distinct
      final candidateIds = controller.state.candidates.map((c) => c.id).toSet();
      expect(candidateIds.length, equals(3));
    });

    test('initializes with energy level from latest check-in entry', () async {
      final mockRepo = MockCheckInRepository();
      mockRepo.mockLatest = CheckInEntry(
        id: 'chk_123',
        moodCategory: 'steady',
        energyLevel: 4,
        anxietyLevel: 1,
        lonelinessLevel: 1,
        createdAtUnix: 1000,
        updatedAtUnix: 1000,
      );

      final controller = TinyStepsController(checkInRepository: mockRepo);
      await Future<void>.delayed(Duration.zero);

      expect(controller.state.isLoading, isFalse);
      expect(controller.state.energyLevel, equals(4));
      expect(controller.state.candidates.length, equals(3));

      // Verify all candidates match energy 4
      for (final candidate in controller.state.candidates) {
        expect(candidate.matchesEnergy(4), isTrue);
      }
    });

    test('setEnergyLevel updates energy and refreshes matching candidates', () async {
      final controller = TinyStepsController();
      await Future<void>.delayed(Duration.zero);

      controller.setEnergyLevel(5);
      expect(controller.state.energyLevel, equals(5));
      expect(controller.state.candidates.length, equals(3));

      for (final candidate in controller.state.candidates) {
        expect(candidate.matchesEnergy(5), isTrue);
      }
    });

    test('shuffle loads alternative candidates and clears completion', () async {
      final controller = TinyStepsController();
      await Future<void>.delayed(Duration.zero);

      final initialCandidates = controller.state.candidates;
      controller.completeStep(initialCandidates.first.id);
      expect(controller.state.hasCompleted, isTrue);

      controller.shuffle();
      expect(controller.state.candidates.length, equals(3));
      expect(controller.state.hasCompleted, isFalse);
      expect(controller.state.completedStepId, isNull);

      // Verify distinct candidates in the new set
      final newIds = controller.state.candidates.map((c) => c.id).toSet();
      expect(newIds.length, equals(3));
    });

    test('completeStep tracks step completion and completedStep getter resolves entity', () async {
      final controller = TinyStepsController();
      await Future<void>.delayed(Duration.zero);

      final stepToComplete = controller.state.candidates[1];
      controller.completeStep(stepToComplete.id);

      expect(controller.state.hasCompleted, isTrue);
      expect(controller.state.completedStepId, equals(stepToComplete.id));
      expect(controller.state.completedStep, isNotNull);
      expect(controller.state.completedStep!.id, equals(stepToComplete.id));
      expect(controller.state.completedStep!.title, equals(stepToComplete.title));

      // resetCompleted resets status
      controller.resetCompleted();
      expect(controller.state.hasCompleted, isFalse);
      expect(controller.state.completedStepId, isNull);
      expect(controller.state.completedStep, isNull);
    });
  });
}
