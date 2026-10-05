import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/data/movement_catalog.dart';
import '../../domain/models/movement_activity.dart';
import '../../domain/models/movement_session_state.dart';

/// State notifier managing the active movement regulation session lifecycle.
class MovementSessionController extends StateNotifier<MovementSessionState> {
  Timer? _timer;

  MovementSessionController({MovementActivity? initialActivity})
      : super(
          MovementSessionState(
            activity: initialActivity ?? MovementCatalog.quickShakeout,
            remainingSeconds: initialActivity?.durationSeconds ?? MovementCatalog.quickShakeout.durationSeconds,
            status: MovementSessionStatus.idle,
          ),
        );

  /// Select a new activity and reset the session state.
  void selectActivity(MovementActivity activity) {
    _timer?.cancel();
    state = MovementSessionState(
      activity: activity,
      elapsedSeconds: 0,
      remainingSeconds: activity.durationSeconds,
      status: MovementSessionStatus.idle,
      currentStepIndex: 0,
    );
  }

  /// Start or resume the session timer.
  void start() {
    if (state.status == MovementSessionStatus.active) return;

    _triggerHaptic(HapticFeedback.lightImpact);

    state = state.copyWith(status: MovementSessionStatus.active);

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final newElapsed = state.elapsedSeconds + 1;
      final targetDuration = state.activity.durationSeconds;

      if (targetDuration != null) {
        final newRemaining = (targetDuration - newElapsed).clamp(0, targetDuration);

        // Haptic at half-way mark
        if (newElapsed == targetDuration ~/ 2) {
          _triggerHaptic(HapticFeedback.selectionClick);
        }

        // Haptic at 5 seconds remaining
        if (newRemaining == 5) {
          _triggerHaptic(HapticFeedback.selectionClick);
        }

        if (newRemaining <= 0) {
          _timer?.cancel();
          _triggerCompletionHaptics();
          state = state.copyWith(
            elapsedSeconds: targetDuration,
            remainingSeconds: 0,
            status: MovementSessionStatus.completed,
          );
          return;
        }

        state = state.copyWith(
          elapsedSeconds: newElapsed,
          remainingSeconds: newRemaining,
        );
      } else {
        // Open-ended mode
        state = state.copyWith(
          elapsedSeconds: newElapsed,
        );
      }
    });
  }

  /// Pause an active session.
  void pause() {
    if (state.status != MovementSessionStatus.active) return;
    _timer?.cancel();
    _triggerHaptic(HapticFeedback.lightImpact);
    state = state.copyWith(status: MovementSessionStatus.paused);
  }

  /// Reset the session to its starting state.
  void reset() {
    _timer?.cancel();
    _triggerHaptic(HapticFeedback.lightImpact);
    state = MovementSessionState(
      activity: state.activity,
      elapsedSeconds: 0,
      remainingSeconds: state.activity.durationSeconds,
      status: MovementSessionStatus.idle,
      currentStepIndex: 0,
    );
  }

  /// Manually mark the session as complete.
  void complete() {
    _timer?.cancel();
    _triggerCompletionHaptics();
    state = state.copyWith(status: MovementSessionStatus.completed);
  }

  /// Navigate to next instruction step.
  void nextStep() {
    if (state.currentStepIndex < state.activity.instructions.length - 1) {
      _triggerHaptic(HapticFeedback.selectionClick);
      state = state.copyWith(currentStepIndex: state.currentStepIndex + 1);
    }
  }

  /// Navigate to previous instruction step.
  void previousStep() {
    if (state.currentStepIndex > 0) {
      _triggerHaptic(HapticFeedback.selectionClick);
      state = state.copyWith(currentStepIndex: state.currentStepIndex - 1);
    }
  }

  Future<void> _triggerHaptic(Future<void> Function() hapticFn) async {
    try {
      await hapticFn();
    } catch (_) {
      // Graceful fallback on desktop or unsupported devices
    }
  }

  Future<void> _triggerCompletionHaptics() async {
    try {
      await HapticFeedback.mediumImpact();
      await Future<void>.delayed(const Duration(milliseconds: 120));
      await HapticFeedback.lightImpact();
    } catch (_) {
      // Graceful fallback
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// Riverpod family provider for the movement session controller.
final movementSessionControllerProvider = StateNotifierProvider.autoDispose
    .family<MovementSessionController, MovementSessionState, String?>(
  (ref, initialMode) {
    final activity = MovementCatalog.findByIdOrMode(initialMode);
    return MovementSessionController(initialActivity: activity);
  },
);
