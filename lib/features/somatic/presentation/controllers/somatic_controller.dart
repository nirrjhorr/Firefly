import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/contracts/audio_player_port.dart';
import '../../../breathing_grounding/data/adapters/just_audio_player_adapter.dart';
import '../../domain/models/somatic_exercise_mode.dart';
import '../../domain/models/somatic_session_state.dart';

/// Provider for Somatic Centering session management.
final somaticControllerProvider =
    StateNotifierProvider<SomaticController, SomaticSessionState>((ref) {
  return SomaticController();
});

/// Riverpod StateNotifier controlling somatic exercise flow, soundscape audio, and soft timer.
class SomaticController extends StateNotifier<SomaticSessionState> {
  SomaticController({
    AudioPlayerPort? audioPlayer,
  })  : _audioPlayer = audioPlayer ?? JustAudioPlayerAdapter(),
        super(const SomaticSessionState(mode: SomaticExerciseMode.heavyBody));

  final AudioPlayerPort _audioPlayer;
  static const String ambientTrackPath = 'assets/audio/cyclic_sigh_ambience.mp3';

  /// Switches the active somatic mode and resets step progress cleanly.
  void setMode(SomaticExerciseMode mode) {
    if (state.mode == mode) return;
    state = SomaticSessionState(
      mode: mode,
      isAudioPlaying: state.isAudioPlaying,
      isTimerActive: state.isTimerActive,
      elapsedSeconds: state.elapsedSeconds,
    );
  }

  /// Advances to the next stage, firing a gentle tactile pulse.
  Future<void> advanceStage() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {
      // Haptics fail silently on unsupported platforms
    }

    final newCompleted = state.completedStages + 1;
    if (state.isLastStage) {
      state = state.copyWith(
        completedStages: newCompleted,
        isCompleted: true,
      );
    } else {
      state = state.copyWith(
        currentStageIndex: state.currentStageIndex + 1,
        completedStages: newCompleted,
      );
    }
  }

  /// Non-judgmental stage skip without penalty or negative UI feedback.
  Future<void> skipStage() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (_) {
      // Haptics fail silently
    }

    if (state.isLastStage) {
      state = state.copyWith(isCompleted: true);
    } else {
      state = state.copyWith(
        currentStageIndex: state.currentStageIndex + 1,
      );
    }
  }

  /// Toggles the offline ambient soundscape loop.
  Future<void> toggleAudio() async {
    if (state.isAudioPlaying) {
      await _audioPlayer.pause();
      state = state.copyWith(isAudioPlaying: false);
    } else {
      try {
        await _audioPlayer.loadLoopingAsset(ambientTrackPath);
        await _audioPlayer.setVolume(0.45);
        await _audioPlayer.play();
        state = state.copyWith(isAudioPlaying: true);
      } catch (_) {
        // Safe offline audio fallback
      }
    }
  }

  /// Toggles visibility of the unhurried soft timer.
  void toggleTimer() {
    state = state.copyWith(isTimerActive: !state.isTimerActive);
  }

  /// Increments elapsed session seconds.
  void tickTimer() {
    state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
  }

  /// Restarts the exercise from stage 1 while retaining audio state.
  void reset() {
    state = SomaticSessionState(
      mode: state.mode,
      isAudioPlaying: state.isAudioPlaying,
      isTimerActive: state.isTimerActive,
      elapsedSeconds: 0,
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
