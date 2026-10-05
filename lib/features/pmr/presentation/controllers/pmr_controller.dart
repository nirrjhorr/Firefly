import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/contracts/haptics_port.dart';
import '../../../breathing_grounding/presentation/controllers/hardware_providers.dart';
import '../../domain/models/pmr_zone.dart';

/// Standard 10-zone PMR sequence
const List<PmrMuscleZone> kStandardPmrZones = [
  PmrMuscleZone.forehead,
  PmrMuscleZone.face,
  PmrMuscleZone.jaw,
  PmrMuscleZone.neckShoulders,
  PmrMuscleZone.handsArms,
  PmrMuscleZone.chest,
  PmrMuscleZone.stomach,
  PmrMuscleZone.back,
  PmrMuscleZone.thighs,
  PmrMuscleZone.calvesFeet,
];

/// Quick 5-zone PMR sequence for time-constrained de-escalation
const List<PmrMuscleZone> kQuickPmrZones = [
  PmrMuscleZone.face,
  PmrMuscleZone.neckShoulders,
  PmrMuscleZone.handsArms,
  PmrMuscleZone.stomach,
  PmrMuscleZone.calvesFeet,
];

class PmrController extends StateNotifier<PmrSessionState> {
  final HapticsPort _haptics;
  final Duration tickerInterval;

  Timer? _timer;
  int _elapsedPhaseMs = 0;
  bool _isDisposed = false;

  PmrController({
    required HapticsPort haptics,
    this.tickerInterval = const Duration(milliseconds: 50),
    bool isQuickMode = false,
  })  : _haptics = haptics,
        super(PmrSessionState(
          zones: isQuickMode ? kQuickPmrZones : kStandardPmrZones,
          isQuickMode: isQuickMode,
        ));

  /// Starts or restarts the PMR session.
  void start() {
    if (_isDisposed) return;
    _timer?.cancel();
    _elapsedPhaseMs = 0;

    state = state.copyWith(
      phase: PmrPhase.tense,
      phaseProgress: 0.0,
      elapsedPhaseMs: 0,
      isActive: true,
      isCompleted: false,
    );

    _triggerPhaseHaptics(PmrPhase.tense);
    _startTicker();
  }

  /// Pauses an active session.
  void pause() {
    if (_isDisposed || !state.isActive) return;
    _timer?.cancel();
    _timer = null;
    state = state.copyWith(isActive: false);
  }

  /// Resumes a paused session.
  void resume() {
    if (_isDisposed || state.isActive || state.isCompleted) return;
    state = state.copyWith(isActive: true);
    _startTicker();
  }

  /// Toggles between active and paused.
  void togglePlayPause() {
    if (state.isActive) {
      pause();
    } else {
      if (state.isCompleted) {
        restart();
      } else {
        resume();
      }
    }
  }

  /// Stops and resets the session to zone 0.
  void stop() {
    if (_isDisposed) return;
    _timer?.cancel();
    _timer = null;
    _elapsedPhaseMs = 0;

    state = state.copyWith(
      currentZoneIndex: 0,
      phase: PmrPhase.tense,
      phaseProgress: 0.0,
      elapsedPhaseMs: 0,
      isActive: false,
      isCompleted: false,
    );
  }

  /// Restarts from the beginning.
  void restart() {
    stop();
    start();
  }

  /// Jumps directly to a specific muscle group.
  void jumpToZone(int index) {
    if (_isDisposed || index < 0 || index >= state.zones.length) return;
    _elapsedPhaseMs = 0;
    state = state.copyWith(
      currentZoneIndex: index,
      phase: PmrPhase.tense,
      phaseProgress: 0.0,
      elapsedPhaseMs: 0,
      isCompleted: false,
    );
    if (state.isActive) {
      _triggerPhaseHaptics(PmrPhase.tense);
    }
  }

  /// Skips directly to next muscle group.
  void nextZone() {
    if (state.currentZoneIndex < state.zones.length - 1) {
      jumpToZone(state.currentZoneIndex + 1);
    } else {
      _completeSession();
    }
  }

  /// Moves back to previous muscle group.
  void previousZone() {
    if (state.currentZoneIndex > 0) {
      jumpToZone(state.currentZoneIndex - 1);
    }
  }

  /// Toggles between 10-zone standard and 5-zone quick mode.
  void setQuickMode(bool quick) {
    if (_isDisposed || state.isQuickMode == quick) return;
    final active = state.isActive;
    _timer?.cancel();
    _timer = null;
    _elapsedPhaseMs = 0;

    state = PmrSessionState(
      zones: quick ? kQuickPmrZones : kStandardPmrZones,
      currentZoneIndex: 0,
      phase: PmrPhase.tense,
      phaseProgress: 0.0,
      elapsedPhaseMs: 0,
      isActive: active,
      isCompleted: false,
      isQuickMode: quick,
    );

    if (active) {
      _triggerPhaseHaptics(PmrPhase.tense);
      _startTicker();
    }
  }

  void _startTicker() {
    _timer?.cancel();
    _timer = Timer.periodic(tickerInterval, (_) => _tick());
  }

  void _tick() {
    if (_isDisposed || !state.isActive) {
      _timer?.cancel();
      return;
    }

    _elapsedPhaseMs += tickerInterval.inMilliseconds;
    final currentPhaseDuration = state.phase.durationMs;
    final progress = (_elapsedPhaseMs / currentPhaseDuration).clamp(0.0, 1.0);

    if (_elapsedPhaseMs >= currentPhaseDuration) {
      _transitionToNextPhase();
    } else {
      state = state.copyWith(
        phaseProgress: progress,
        elapsedPhaseMs: _elapsedPhaseMs,
      );
    }
  }

  void _transitionToNextPhase() {
    _elapsedPhaseMs = 0;

    switch (state.phase) {
      case PmrPhase.tense:
        state = state.copyWith(
          phase: PmrPhase.hold,
          phaseProgress: 0.0,
          elapsedPhaseMs: 0,
        );
        _triggerPhaseHaptics(PmrPhase.hold);
        break;

      case PmrPhase.hold:
        state = state.copyWith(
          phase: PmrPhase.release,
          phaseProgress: 0.0,
          elapsedPhaseMs: 0,
        );
        _triggerPhaseHaptics(PmrPhase.release);
        break;

      case PmrPhase.release:
        state = state.copyWith(
          phase: PmrPhase.notice,
          phaseProgress: 0.0,
          elapsedPhaseMs: 0,
        );
        _triggerPhaseHaptics(PmrPhase.notice);
        break;

      case PmrPhase.notice:
        if (state.currentZoneIndex < state.zones.length - 1) {
          state = state.copyWith(
            currentZoneIndex: state.currentZoneIndex + 1,
            phase: PmrPhase.tense,
            phaseProgress: 0.0,
            elapsedPhaseMs: 0,
          );
          _triggerPhaseHaptics(PmrPhase.tense);
        } else {
          _completeSession();
        }
        break;
    }
  }

  void _completeSession() {
    _timer?.cancel();
    _timer = null;
    state = state.copyWith(
      isActive: false,
      isCompleted: true,
      phaseProgress: 1.0,
    );
    try {
      _haptics.groundingConfirm();
    } catch (_) {}
  }

  void _triggerPhaseHaptics(PmrPhase phase) {
    try {
      switch (phase) {
        case PmrPhase.tense:
          _haptics.mediumImpact();
          break;
        case PmrPhase.hold:
          _haptics.lightImpact();
          break;
        case PmrPhase.release:
          _haptics.phaseTransitionExhale();
          break;
        case PmrPhase.notice:
          _haptics.selectionClick();
          break;
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _isDisposed = true;
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }
}

/// Riverpod provider for Progressive Muscle Relaxation controller
final pmrControllerProvider =
    StateNotifierProvider.autoDispose<PmrController, PmrSessionState>((ref) {
  final haptics = ref.watch(hapticsPortProvider);
  return PmrController(haptics: haptics);
});
