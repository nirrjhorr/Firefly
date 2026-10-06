import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/contracts/audio_player_port.dart';
import '../../../breathing_grounding/data/adapters/just_audio_player_adapter.dart';
import '../../domain/models/ambient_mixer_channel.dart';
import '../../domain/models/ambient_mixer_preset.dart';
import '../../domain/models/ambient_mixer_state.dart';

/// Controller managing multi-channel ambient sound mixing, independent volume curves,
/// preset switching, and logarithmic sleep timer volume attenuation.
class AmbientAudioMixerNotifier extends StateNotifier<AmbientMixerState> {
  final AudioPlayerPort Function() _playerFactory;
  final Map<String, AudioPlayerPort> _channelPlayers = {};
  Timer? _sleepTimer;
  int _totalTimerSeconds = 0;

  AmbientAudioMixerNotifier({
    AudioPlayerPort Function()? playerFactory,
    AmbientMixerState initialState = const AmbientMixerState(),
  })  : _playerFactory = playerFactory ?? (() => JustAudioPlayerAdapter()),
        super(initialState);

  AudioPlayerPort _getPlayerForChannel(String channelId) {
    return _channelPlayers.putIfAbsent(channelId, () => _playerFactory());
  }

  /// Toggles master playback on/off for all active channels.
  Future<void> togglePlayPause() async {
    if (state.isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  /// Starts playback across all currently enabled channels.
  Future<void> play() async {
    state = state.copyWith(isPlaying: true);
    await _syncAllAudio(shouldPlay: true);
  }

  /// Pauses playback across all channels without resetting timer or states.
  Future<void> pause() async {
    state = state.copyWith(isPlaying: false);
    for (final player in _channelPlayers.values) {
      if (player.isPlaying) {
        await player.pause();
      }
    }
  }

  /// Stops playback, clears sleep timer, and resets volume attenuation.
  Future<void> stop() async {
    _cancelTimer();
    state = state.copyWith(isPlaying: false, clearTimer: true);
    for (final player in _channelPlayers.values) {
      await player.stop();
    }
  }

  /// Adjusts master volume and updates active channel output levels.
  Future<void> setMasterVolume(double volume) async {
    final clamped = volume.clamp(0.0, 1.0);
    state = state.copyWith(masterVolume: clamped);
    await _syncAllAudio();
  }

  /// Adjusts individual channel volume.
  Future<void> setChannelVolume(String channelId, double volume) async {
    state = state.setChannelVolume(channelId, volume);
    await _syncChannel(channelId);
  }

  /// Toggles an audio channel on or off.
  Future<void> toggleChannel(String channelId) async {
    state = state.toggleChannel(channelId);
    await _syncChannel(channelId);
  }

  /// Toggles mute state on a single channel.
  Future<void> toggleChannelMute(String channelId) async {
    state = state.toggleChannelMute(channelId);
    await _syncChannel(channelId);
  }

  /// Applies a restful preset, configuring active channels and calibrated volume ratios.
  Future<void> applyPreset(AmbientMixerPreset preset) async {
    state = state.applyPreset(preset);
    await _syncAllAudio();
  }

  /// Configures sleep wind-down timer with logarithmic volume attenuation.
  void setSleepTimer(int? minutes) {
    _cancelTimer();

    state = state.withTimer(minutes);
    if (minutes == null || minutes <= 0) {
      _syncAllAudio();
      return;
    }

    final totalSeconds = minutes * 60;
    _totalTimerSeconds = totalSeconds;

    state = state.copyWith(
      timerMinutes: minutes,
      timerSecondsRemaining: totalSeconds,
    );

    _sleepTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      final remaining = (state.timerSecondsRemaining ?? 0) - 1;

      if (remaining <= 0) {
        timer.cancel();
        await stop();
      } else {
        state = state.copyWith(timerSecondsRemaining: remaining);
        // During the final 300 seconds, continuously attenuate volume
        if (remaining <= 300) {
          await _syncAllAudio();
        }
      }
    });
  }

  /// Synchronizes an individual channel player with current state.
  Future<void> _syncChannel(String channelId) async {
    final ch = state.channels.firstWhere((c) => c.id == channelId);
    final player = _getPlayerForChannel(channelId);
    final targetVol = ch.computedVolume(
      state.masterVolume,
      fadeFactor: state.effectiveFadeFactor,
    );

    if (ch.isEnabled && !ch.isMuted && state.isPlaying) {
      await player.loadLoopingAsset(ch.assetPath);
      await player.setVolume(targetVol);
      if (!player.isPlaying) {
        await player.play();
      }
    } else {
      if (player.isPlaying) {
        await player.pause();
      }
      await player.setVolume(targetVol);
    }
  }

  /// Synchronizes all channel players with current state.
  Future<void> _syncAllAudio({bool shouldPlay = false}) async {
    for (final ch in state.channels) {
      final player = _getPlayerForChannel(ch.id);
      final targetVol = ch.computedVolume(
        state.masterVolume,
        fadeFactor: state.effectiveFadeFactor,
      );

      if (ch.isEnabled && !ch.isMuted && state.isPlaying) {
        await player.loadLoopingAsset(ch.assetPath);
        await player.setVolume(targetVol);
        if (shouldPlay && !player.isPlaying) {
          await player.play();
        }
      } else {
        if (player.isPlaying) {
          await player.pause();
        }
        await player.setVolume(targetVol);
      }
    }
  }

  void _cancelTimer() {
    _sleepTimer?.cancel();
    _sleepTimer = null;
  }

  @override
  void dispose() {
    _cancelTimer();
    for (final player in _channelPlayers.values) {
      player.dispose();
    }
    _channelPlayers.clear();
    super.dispose();
  }
}

final ambientAudioMixerProvider =
    StateNotifierProvider<AmbientAudioMixerNotifier, AmbientMixerState>((ref) {
  return AmbientAudioMixerNotifier();
});
