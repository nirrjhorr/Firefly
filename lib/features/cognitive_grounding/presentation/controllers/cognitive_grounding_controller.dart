import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/contracts/haptics_port.dart';
import '../../../breathing_grounding/presentation/controllers/hardware_providers.dart';
import '../../domain/models/cognitive_exercise.dart';
import '../../domain/models/cognitive_session_state.dart';

/// Controller managing cognitive grounding exercises, working memory tasks, and smooth transitions.
class CognitiveGroundingController extends StateNotifier<CognitiveSessionState> {
  CognitiveGroundingController({
    required HapticsPort haptics,
    CognitiveExerciseType initialType = CognitiveExerciseType.alphabetCategories,
  })  : _haptics = haptics,
        super(CognitiveSessionState(exerciseType: initialType));

  final HapticsPort _haptics;

  void _triggerHapticClick() {
    try {
      _haptics.groundingConfirm();
    } catch (_) {}
  }

  void _triggerHapticSuccess() {
    try {
      _haptics.groundingConfirm();
    } catch (_) {}
  }

  /// Changes the exercise type and resets progression.
  void setExerciseType(CognitiveExerciseType type) {
    if (state.exerciseType == type && !state.isCompleted && state.completedSteps == 0) {
      return;
    }
    _triggerHapticClick();
    state = CognitiveSessionState(
      exerciseType: type,
      currentCount: type == CognitiveExerciseType.backwardCounting
          ? kCountingConfigs[state.activeCountingConfigIndex].startNumber
          : 100,
    );
  }

  /// Cycles to the next category in Alphabet Categories.
  void nextCategory() {
    _triggerHapticClick();
    final nextIdx = (state.activeCategoryIndex + 1) % kOfflineCognitiveCategories.length;
    state = state.copyWith(activeCategoryIndex: nextIdx);
  }

  /// Sets the counting configuration (e.g. from 100 by 7s).
  void setCountingConfig(int index) {
    _triggerHapticClick();
    final safeIdx = index % kCountingConfigs.length;
    final config = kCountingConfigs[safeIdx];
    state = state.copyWith(
      activeCountingConfigIndex: safeIdx,
      currentCount: config.startNumber,
      completedSteps: 0,
      isCompleted: false,
    );
  }

  /// Advances to the next item or step upon user confirmation ("I have one" / "Next").
  void advance() {
    if (state.isCompleted) return;
    _triggerHapticClick();

    switch (state.exerciseType) {
      case CognitiveExerciseType.alphabetCategories:
        final nextLetter = state.currentLetterIndex + 1;
        if (nextLetter >= 26) {
          _triggerHapticSuccess();
          state = state.copyWith(
            currentLetterIndex: 25,
            completedSteps: state.completedSteps + 1,
            isCompleted: true,
          );
        } else {
          state = state.copyWith(
            currentLetterIndex: nextLetter,
            completedSteps: state.completedSteps + 1,
          );
        }
        break;

      case CognitiveExerciseType.backwardCounting:
        final config = state.activeCountingConfig;
        final nextVal = state.currentCount - config.stepDown;
        if (nextVal <= 0) {
          _triggerHapticSuccess();
          state = state.copyWith(
            currentCount: 0,
            completedSteps: state.completedSteps + 1,
            isCompleted: true,
          );
        } else {
          state = state.copyWith(
            currentCount: nextVal,
            completedSteps: state.completedSteps + 1,
          );
        }
        break;

      case CognitiveExerciseType.wordAssociation:
        final chain = state.activeChain;
        final nextStep = state.activeChainStep + 1;
        if (nextStep >= chain.length) {
          _triggerHapticSuccess();
          state = state.copyWith(
            activeChainStep: chain.length - 1,
            completedSteps: state.completedSteps + 1,
            isCompleted: true,
          );
        } else {
          state = state.copyWith(
            activeChainStep: nextStep,
            completedSteps: state.completedSteps + 1,
          );
        }
        break;

      case CognitiveExerciseType.memorySequence:
        final nextStep = state.completedSteps + 1;
        if (nextStep >= 5) {
          _triggerHapticSuccess();
          state = state.copyWith(
            completedSteps: 5,
            isCompleted: true,
          );
        } else {
          state = state.copyWith(
            completedSteps: nextStep,
          );
        }
        break;
    }
  }

  /// Skips the current step without penalty or judgment.
  void skip() {
    if (state.isCompleted) return;
    _triggerHapticClick();

    switch (state.exerciseType) {
      case CognitiveExerciseType.alphabetCategories:
        final nextLetter = state.currentLetterIndex + 1;
        if (nextLetter >= 26) {
          state = state.copyWith(isCompleted: true);
        } else {
          state = state.copyWith(currentLetterIndex: nextLetter);
        }
        break;

      case CognitiveExerciseType.backwardCounting:
        final config = state.activeCountingConfig;
        final nextVal = state.currentCount - config.stepDown;
        if (nextVal <= 0) {
          state = state.copyWith(isCompleted: true);
        } else {
          state = state.copyWith(currentCount: nextVal);
        }
        break;

      case CognitiveExerciseType.wordAssociation:
        final chain = state.activeChain;
        final nextStep = state.activeChainStep + 1;
        if (nextStep >= chain.length) {
          state = state.copyWith(isCompleted: true);
        } else {
          state = state.copyWith(activeChainStep: nextStep);
        }
        break;

      case CognitiveExerciseType.memorySequence:
        final nextStep = state.completedSteps + 1;
        if (nextStep >= 5) {
          state = state.copyWith(isCompleted: true);
        } else {
          state = state.copyWith(completedSteps: nextStep);
        }
        break;
    }
  }

  /// Resets the active exercise to beginning.
  void reset() {
    _triggerHapticClick();
    state = CognitiveSessionState(
      exerciseType: state.exerciseType,
      activeCategoryIndex: state.activeCategoryIndex,
      activeCountingConfigIndex: state.activeCountingConfigIndex,
      activeChainIndex: (state.activeChainIndex + 1) % kWordAssociationChains.length,
      currentCount: state.activeCountingConfig.startNumber,
    );
  }
}

/// Provider for [CognitiveGroundingController].
final cognitiveGroundingControllerProvider =
    StateNotifierProvider<CognitiveGroundingController, CognitiveSessionState>((ref) {
  final haptics = ref.watch(hapticsPortProvider);
  return CognitiveGroundingController(haptics: haptics);
});
