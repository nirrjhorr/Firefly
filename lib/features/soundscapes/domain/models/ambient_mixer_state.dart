import 'dart:math' as math;
import 'ambient_mixer_channel.dart';
import 'ambient_mixer_preset.dart';

/// Immutable state representation for the Multi-Channel Ambient Audio Mixer.
class AmbientMixerState {
  final List<AmbientMixerChannel> channels;
  final double masterVolume;
  final bool isPlaying;
  final int? timerMinutes;
  final int? timerSecondsRemaining;
  final String? activePresetId;

  const AmbientMixerState({
    this.channels = kCuratedMixerChannels,
    this.masterVolume = 0.75,
    this.isPlaying = false,
    this.timerMinutes,
    this.timerSecondsRemaining,
    this.activePresetId,
  });

  /// Factory constructing initial state with the default curated preset applied.
  factory AmbientMixerState.initial() {
    return const AmbientMixerState();
  }

  /// Number of channels actively generating sound (enabled and unmuted).
  int get activeChannelCount =>
      channels.where((c) => c.isEnabled && !c.isMuted && c.volume > 0).length;

  /// Human-readable remaining timer string (e.g. "23:45").
  String? get formattedTimeRemaining {
    if (timerSecondsRemaining == null) return null;
    final mins = timerSecondsRemaining! ~/ 60;
    final secs = timerSecondsRemaining! % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  /// Calculates the logarithmic volume attenuation factor when in the final 5 minutes (300 seconds).
  ///
  /// Mathematical rationale:
  /// Human volume perception is logarithmic (Weber-Fechner law). A linear fade drops perceived
  /// loudness too rapidly initially and maintains a perceptible cliff at zero.
  /// Using: factor = ln(1 + 9 * (t / T)) / ln(10)
  /// At t = 300s: factor = ln(10)/ln(10) = 1.0 (no attenuation)
  /// At t = 150s: factor = ln(5.5)/ln(10) ≈ 0.740
  /// At t = 30s:  factor = ln(1.9)/ln(10) ≈ 0.279
  /// At t = 0s:   factor = ln(1)/ln(10) = 0.0 (silent fadeout)
  static double computeLogarithmicFadeFactor(int secondsRemaining, int totalDurationSeconds) {
    if (secondsRemaining <= 0) return 0.0;
    final fadeDuration = totalDurationSeconds < 300 ? totalDurationSeconds : 300;
    if (secondsRemaining >= fadeDuration) return 1.0;

    final ratio = (secondsRemaining / fadeDuration).clamp(0.0, 1.0);
    return math.log(1.0 + 9.0 * ratio) / math.ln10;
  }

  /// Current fade factor based on active timer.
  double get effectiveFadeFactor {
    if (timerSecondsRemaining == null || timerMinutes == null) return 1.0;
    return computeLogarithmicFadeFactor(timerSecondsRemaining!, timerMinutes! * 60);
  }

  /// Returns updated state with toggled channel enable status.
  AmbientMixerState toggleChannel(String channelId) {
    final updated = channels.map((ch) {
      if (ch.id == channelId) {
        return ch.copyWith(isEnabled: !ch.isEnabled);
      }
      return ch;
    }).toList();
    return copyWith(channels: updated, clearPreset: true);
  }

  /// Returns updated state with updated channel volume.
  AmbientMixerState setChannelVolume(String channelId, double volume) {
    final clamped = volume.clamp(0.0, 1.0);
    final updated = channels.map((ch) {
      if (ch.id == channelId) {
        return ch.copyWith(volume: clamped);
      }
      return ch;
    }).toList();
    return copyWith(channels: updated, clearPreset: true);
  }

  /// Returns updated state with toggled channel mute status.
  AmbientMixerState toggleChannelMute(String channelId) {
    final updated = channels.map((ch) {
      if (ch.id == channelId) {
        return ch.copyWith(isMuted: !ch.isMuted);
      }
      return ch;
    }).toList();
    return copyWith(channels: updated);
  }

  /// Returns updated state with a preset applied.
  AmbientMixerState applyPreset(AmbientMixerPreset preset) {
    final updated = channels.map((ch) {
      final presetVol = preset.channelVolumes[ch.id];
      if (presetVol != null) {
        return ch.copyWith(isEnabled: true, volume: presetVol, isMuted: false);
      } else {
        return ch.copyWith(isEnabled: false);
      }
    }).toList();
    return copyWith(channels: updated, activePresetId: preset.id);
  }

  /// Returns updated state with sleep timer configured.
  AmbientMixerState withTimer(int? minutes) {
    if (minutes == null || minutes <= 0) {
      return copyWith(clearTimer: true);
    }
    return copyWith(
      timerMinutes: minutes,
      timerSecondsRemaining: minutes * 60,
    );
  }

  /// Decrements timer by one second, stopping when reaching zero.
  AmbientMixerState tickTimer() {
    if (timerSecondsRemaining == null) return this;
    final remaining = timerSecondsRemaining! - 1;
    if (remaining <= 0) {
      return copyWith(clearTimer: true, isPlaying: false);
    }
    return copyWith(timerSecondsRemaining: remaining);
  }

  AmbientMixerState copyWith({
    List<AmbientMixerChannel>? channels,
    double? masterVolume,
    bool? isPlaying,
    int? timerMinutes,
    bool clearTimer = false,
    int? timerSecondsRemaining,
    String? activePresetId,
    bool clearPreset = false,
  }) {
    return AmbientMixerState(
      channels: channels ?? this.channels,
      masterVolume: masterVolume ?? this.masterVolume,
      isPlaying: isPlaying ?? this.isPlaying,
      timerMinutes: clearTimer ? null : (timerMinutes ?? this.timerMinutes),
      timerSecondsRemaining: clearTimer ? null : (timerSecondsRemaining ?? this.timerSecondsRemaining),
      activePresetId: clearPreset ? null : (activePresetId ?? this.activePresetId),
    );
  }
}
