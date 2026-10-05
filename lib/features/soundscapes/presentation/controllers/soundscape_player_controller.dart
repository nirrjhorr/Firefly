import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/contracts/audio_player_port.dart';
import '../../../breathing_grounding/data/adapters/just_audio_player_adapter.dart';
import '../../domain/models/soundscape_track.dart';

/// State of the soundscape audio player.
class SoundscapePlayerState {
  final SoundscapeTrack? activeTrack;
  final bool isPlaying;
  final double volume;
  final int? sleepTimerMinutes;
  final int? sleepTimerSecondsRemaining;
  final bool isLoading;

  const SoundscapePlayerState({
    this.activeTrack,
    this.isPlaying = false,
    this.volume = 0.65,
    this.sleepTimerMinutes,
    this.sleepTimerSecondsRemaining,
    this.isLoading = false,
  });

  SoundscapePlayerState copyWith({
    SoundscapeTrack? activeTrack,
    bool clearActiveTrack = false,
    bool? isPlaying,
    double? volume,
    int? sleepTimerMinutes,
    bool clearSleepTimer = false,
    int? sleepTimerSecondsRemaining,
    bool? isLoading,
  }) {
    return SoundscapePlayerState(
      activeTrack: clearActiveTrack ? null : (activeTrack ?? this.activeTrack),
      isPlaying: isPlaying ?? this.isPlaying,
      volume: volume ?? this.volume,
      sleepTimerMinutes:
          clearSleepTimer ? null : (sleepTimerMinutes ?? this.sleepTimerMinutes),
      sleepTimerSecondsRemaining: clearSleepTimer
          ? null
          : (sleepTimerSecondsRemaining ?? this.sleepTimerSecondsRemaining),
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// State notifier managing playback of relaxation soundscapes.
class SoundscapePlayerNotifier extends StateNotifier<SoundscapePlayerState> {
  final AudioPlayerPort _audioPlayer;
  Timer? _sleepTimer;

  SoundscapePlayerNotifier({AudioPlayerPort? audioPlayer})
      : _audioPlayer = audioPlayer ?? JustAudioPlayerAdapter(),
        super(const SoundscapePlayerState());

  Future<void> playTrack(SoundscapeTrack track) async {
    state = state.copyWith(isLoading: true, activeTrack: track);

    try {
      await _audioPlayer.loadLoopingAsset(track.assetPath);
      await _audioPlayer.setVolume(state.volume);
      await _audioPlayer.play();
      state = state.copyWith(
        isPlaying: true,
        isLoading: false,
        activeTrack: track,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> togglePlayPause() async {
    if (state.activeTrack == null) return;

    if (state.isPlaying) {
      await _audioPlayer.pause();
      state = state.copyWith(isPlaying: false);
    } else {
      await _audioPlayer.play();
      state = state.copyWith(isPlaying: true);
    }
  }

  Future<void> stop() async {
    _cancelTimer();
    await _audioPlayer.stop();
    state = state.copyWith(
      isPlaying: false,
      clearActiveTrack: true,
      clearSleepTimer: true,
    );
  }

  Future<void> setVolume(double volume) async {
    final clamped = volume.clamp(0.0, 1.0);
    state = state.copyWith(volume: clamped);
    await _audioPlayer.setVolume(clamped);
  }

  void setSleepTimer(int? minutes) {
    _cancelTimer();

    if (minutes == null || minutes <= 0) {
      state = state.copyWith(clearSleepTimer: true);
      return;
    }

    final totalSeconds = minutes * 60;
    state = state.copyWith(
      sleepTimerMinutes: minutes,
      sleepTimerSecondsRemaining: totalSeconds,
    );

    _sleepTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      final remaining = (state.sleepTimerSecondsRemaining ?? 0) - 1;
      if (remaining <= 0) {
        timer.cancel();
        // Fade out smoothly over 5 seconds before stopping
        await _audioPlayer.fadeOut(duration: const Duration(seconds: 5));
        await stop();
      } else {
        state = state.copyWith(sleepTimerSecondsRemaining: remaining);
      }
    });
  }

  void _cancelTimer() {
    _sleepTimer?.cancel();
    _sleepTimer = null;
  }

  @override
  void dispose() {
    _cancelTimer();
    _audioPlayer.dispose();
    super.dispose();
  }
}

final soundscapePlayerProvider =
    StateNotifierProvider<SoundscapePlayerNotifier, SoundscapePlayerState>((ref) {
  return SoundscapePlayerNotifier();
});
