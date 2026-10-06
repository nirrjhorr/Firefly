import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/contracts/haptics_port.dart';
import '../../../breathing_grounding/presentation/controllers/hardware_providers.dart';
import '../../domain/models/nature_observation_mode.dart';
import '../../domain/models/nature_session_state.dart';

/// Controller managing Nature Observation & Environmental Grounding exercises.
class NatureController extends StateNotifier<NatureSessionState> {
  NatureController({
    required HapticsPort haptics,
    NatureObservationMode initialMode = NatureObservationMode.skyGazing,
  })  : _haptics = haptics,
        super(NatureSessionState(mode: initialMode));

  final HapticsPort _haptics;

  void _triggerHapticTick() {
    try {
      _haptics.groundingConfirm();
    } catch (_) {}
  }

  void _triggerHapticSuccess() {
    try {
      _haptics.groundingConfirm();
    } catch (_) {}
  }

  /// Sets the nature observation mode and resets progression.
  void setMode(NatureObservationMode mode) {
    if (state.mode == mode && !state.isCompleted && state.currentPromptIndex == 0) {
      return;
    }
    _triggerHapticTick();
    state = NatureSessionState(
      mode: mode,
      isTimerActive: state.isTimerActive,
    );
  }

  /// Advances to the next observation prompt.
  void nextPrompt() {
    if (state.isCompleted) return;
    _triggerHapticTick();

    final nextIndex = state.currentPromptIndex + 1;
    final total = state.totalPrompts;

    if (nextIndex >= total) {
      _triggerHapticSuccess();
      state = state.copyWith(
        currentPromptIndex: total - 1,
        completedPrompts: state.completedPrompts + 1,
        isCompleted: true,
      );
    } else {
      state = state.copyWith(
        currentPromptIndex: nextIndex,
        completedPrompts: state.completedPrompts + 1,
      );
    }
  }

  /// Returns to the previous prompt if user wants to re-read or stay with earlier cue.
  void previousPrompt() {
    if (!state.hasPrevious) return;
    _triggerHapticTick();
    state = state.copyWith(
      currentPromptIndex: state.currentPromptIndex - 1,
      isCompleted: false,
    );
  }

  /// Skips the current prompt non-judgmentally.
  void skipPrompt() {
    if (state.isCompleted) return;
    final nextIndex = state.currentPromptIndex + 1;
    final total = state.totalPrompts;

    if (nextIndex >= total) {
      state = state.copyWith(
        currentPromptIndex: total - 1,
        isCompleted: true,
      );
    } else {
      state = state.copyWith(
        currentPromptIndex: nextIndex,
      );
    }
  }

  /// Toggles the soft ambient timer.
  void toggleTimer() {
    state = state.copyWith(isTimerActive: !state.isTimerActive);
  }

  /// Increments elapsed timer counter.
  void tickTimer() {
    if (state.isTimerActive && !state.isCompleted) {
      state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
    }
  }

  /// Resets session.
  void reset() {
    state = NatureSessionState(mode: state.mode);
  }
}

/// Provider for NatureController.
final natureControllerProvider =
    StateNotifierProvider.autoDispose<NatureController, NatureSessionState>(
  (ref) {
    final haptics = ref.watch(hapticsPortProvider);
    return NatureController(haptics: haptics);
  },
);
