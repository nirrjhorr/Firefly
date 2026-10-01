import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app.firefly/core/contracts/haptics_port.dart';
import 'package:app.firefly/features/breathing_grounding/domain/models/grounding_stage.dart';
import 'package:app.firefly/features/breathing_grounding/presentation/controllers/grounding_controller.dart';

class MockHapticsPort extends Mock implements HapticsPort {}

void main() {
  group('GroundingController', () {
    late MockHapticsPort mockHaptics;
    late GroundingController controller;

    setUp(() {
      mockHaptics = MockHapticsPort();
      when(() => mockHaptics.groundingConfirm()).thenAnswer((_) async {});
      controller = GroundingController(haptics: mockHaptics);
    });

    test('Initial state starts at stage 0 (SEE, 5 items) and not completed', () {
      final state = controller.state;
      expect(state.currentStageIndex, equals(0));
      expect(state.currentStageNoticedCount, equals(0));
      expect(state.targetCount, equals(5));
      expect(state.currentStage.sense, equals(GroundingSense.see));
      expect(state.isCompleted, isFalse);
      expect(state.isFirstStage, isTrue);
      expect(state.isLastStage, isFalse);
      expect(state.stageProgress, equals(0.0));
      expect(state.overallProgress, equals(0.0));
    });

    test('noticeItem() increments count and triggers haptic confirm click', () {
      controller.noticeItem();

      expect(controller.state.currentStageNoticedCount, equals(1));
      expect(controller.state.isCurrentStageComplete, isFalse);
      verify(() => mockHaptics.groundingConfirm()).called(1);

      // Notice up to target count 5
      controller.noticeItem();
      controller.noticeItem();
      controller.noticeItem();
      controller.noticeItem();

      expect(controller.state.currentStageNoticedCount, equals(5));
      expect(controller.state.isCurrentStageComplete, isTrue);
      expect(controller.state.stageProgress, equals(1.0));
      verify(() => mockHaptics.groundingConfirm()).called(4);
    });

    test('nextStage() advances from Stage 0 (See) through to Stage 4 (Taste)', () {
      // Advance to Touch (4 items)
      controller.nextStage();
      expect(controller.state.currentStageIndex, equals(1));
      expect(controller.state.currentStage.sense, equals(GroundingSense.touch));
      expect(controller.state.targetCount, equals(4));
      expect(controller.state.currentStageNoticedCount, equals(0));

      // Advance to Hear (3 items)
      controller.nextStage();
      expect(controller.state.currentStageIndex, equals(2));
      expect(controller.state.currentStage.sense, equals(GroundingSense.hear));
      expect(controller.state.targetCount, equals(3));

      // Advance to Smell (2 items)
      controller.nextStage();
      expect(controller.state.currentStageIndex, equals(3));
      expect(controller.state.currentStage.sense, equals(GroundingSense.smell));
      expect(controller.state.targetCount, equals(2));

      // Advance to Taste (1 item)
      controller.nextStage();
      expect(controller.state.currentStageIndex, equals(4));
      expect(controller.state.currentStage.sense, equals(GroundingSense.taste));
      expect(controller.state.targetCount, equals(1));
      expect(controller.state.isLastStage, isTrue);
      expect(controller.state.isCompleted, isFalse);

      // Advance past last stage marks session completed
      controller.nextStage();
      expect(controller.state.isCompleted, isTrue);
    });

    test('previousStage() moves back without penalty', () {
      controller.nextStage(); // Stage 1: Touch
      controller.nextStage(); // Stage 2: Hear
      expect(controller.state.currentStageIndex, equals(2));

      controller.previousStage();
      expect(controller.state.currentStageIndex, equals(1));
      expect(controller.state.currentStage.sense, equals(GroundingSense.touch));

      controller.previousStage();
      expect(controller.state.currentStageIndex, equals(0));
      expect(controller.state.isFirstStage, isTrue);

      // Calling previousStage at first stage does nothing
      controller.previousStage();
      expect(controller.state.currentStageIndex, equals(0));
    });

    test('skipStage() allows bypassing senses cleanly without penalty', () {
      controller.skipStage();
      expect(controller.state.currentStageIndex, equals(1));
      verify(() => mockHaptics.groundingConfirm()).called(1);

      controller.skipStage(); // Stage 2
      controller.skipStage(); // Stage 3
      controller.skipStage(); // Stage 4 (Taste)
      expect(controller.state.currentStageIndex, equals(4));
      expect(controller.state.isCompleted, isFalse);

      controller.skipStage(); // Skip stage 4 -> marks completed
      expect(controller.state.isCompleted, isTrue);
    });

    test('completeEarly() immediately sets isCompleted to true', () {
      controller.noticeItem();
      expect(controller.state.isCompleted, isFalse);

      controller.completeEarly();
      expect(controller.state.isCompleted, isTrue);
      verify(() => mockHaptics.groundingConfirm()).called(2);
    });

    test('reset() restores initial 5-4-3-2-1 state', () {
      controller.nextStage();
      controller.noticeItem();
      controller.completeEarly();
      expect(controller.state.isCompleted, isTrue);

      controller.reset();
      expect(controller.state.currentStageIndex, equals(0));
      expect(controller.state.currentStageNoticedCount, equals(0));
      expect(controller.state.isCompleted, isFalse);
    });
  });
}
