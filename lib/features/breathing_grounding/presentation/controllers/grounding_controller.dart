import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/contracts/haptics_port.dart';
import '../../domain/models/grounding_session_state.dart';
import '../../domain/models/grounding_stage.dart';
import 'hardware_providers.dart';

/// Reactive controller driving step-by-step sensory grounding exercises,
/// mode selection, stage progression, check-offs, and tactile confirmation.
class GroundingController extends StateNotifier<GroundingSessionState> {
  final HapticsPort _haptics;

  GroundingController({
    required HapticsPort haptics,
    GroundingMode mode = GroundingMode.fiveSenses,
    List<GroundingStage>? stages,
  })  : _haptics = haptics,
        super(GroundingSessionState(mode: mode, stages: stages ?? mode.stages));

  /// Sets or switches the active grounding mode, cleanly resetting progression.
  void setMode(GroundingMode mode) {
    if (state.mode == mode &&
        state.currentStageIndex == 0 &&
        state.currentStageNoticedCount == 0 &&
        !state.isCompleted) {
      return;
    }
    _triggerHapticClick();
    state = GroundingSessionState(
      mode: mode,
      stages: mode.stages,
    );
  }

  /// Confirms noticing an item in the current sensory stage.
  /// Triggers a tactile confirmation click via [HapticsPort].
  void noticeItem() {
    if (state.isCompleted) return;

    final newCount = state.currentStageNoticedCount + 1;
    _triggerHapticClick();

    if (newCount >= state.targetCount) {
      if (state.isLastStage) {
        state = state.copyWith(
          currentStageNoticedCount: state.targetCount,
          isCompleted: true,
        );
      } else {
        state = state.copyWith(
          currentStageNoticedCount: state.targetCount,
        );
      }
    } else {
      state = state.copyWith(
        currentStageNoticedCount: newCount,
      );
    }
  }

  /// Advances to the next sensory stage.
  void nextStage() {
    if (state.isCompleted) return;

    _triggerHapticClick();
    if (state.isLastStage) {
      state = state.copyWith(
        isCompleted: true,
        currentStageNoticedCount: state.targetCount,
      );
    } else {
      state = state.copyWith(
        currentStageIndex: state.currentStageIndex + 1,
        currentStageNoticedCount: 0,
      );
    }
  }

  /// Navigates back to the previous sensory stage without penalty.
  void previousStage() {
    if (state.currentStageIndex > 0) {
      _triggerHapticClick();
      final prevIndex = state.currentStageIndex - 1;
      state = state.copyWith(
        currentStageIndex: prevIndex,
        currentStageNoticedCount: state.stages[prevIndex].targetCount,
        isCompleted: false,
      );
    }
  }

  /// Skips the current sensory stage without penalty or shame.
  /// Designed for accessibility with users with sensory differences.
  void skipStage() {
    if (state.isCompleted) return;

    _triggerHapticClick();
    if (state.isLastStage) {
      state = state.copyWith(isCompleted: true);
    } else {
      state = state.copyWith(
        currentStageIndex: state.currentStageIndex + 1,
        currentStageNoticedCount: 0,
      );
    }
  }

  /// Allows completing or exiting the exercise early with positive affirmation.
  void completeEarly() {
    _triggerHapticClick();
    state = state.copyWith(isCompleted: true);
  }

  /// Completely resets the grounding session for the current mode.
  void reset() {
    state = GroundingSessionState(
      mode: state.mode,
      stages: state.stages,
    );
  }

  void _triggerHapticClick() {
    try {
      _haptics.groundingConfirm();
    } catch (_) {
      // Contained per NFRs
    }
  }
}

/// Riverpod provider managing reactive sensory grounding across modes.
final groundingControllerProvider = StateNotifierProvider.autoDispose<
    GroundingController, GroundingSessionState>((ref) {
  final haptics = ref.watch(hapticsPortProvider);
  return GroundingController(haptics: haptics);
});
