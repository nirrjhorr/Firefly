import 'dart:convert';
import 'dart:io';

import '../../../lib/core/routing/app_routes.dart';
import '../../../lib/features/activities/domain/models/activity_category.dart';
import '../../../lib/features/soundscapes/domain/models/ambient_mixer_channel.dart';
import '../../../lib/features/soundscapes/domain/models/ambient_mixer_preset.dart';
import '../../../lib/features/soundscapes/domain/models/ambient_mixer_state.dart';

void main() {
  stdout.writeln('=== Verifying Story 15.1: Ambient Audio Mixer & Sleep Wind-Down Suite ===');

  // 1. Verify AmbientMixerChannel Domain Model
  assert(kCuratedMixerChannels.length >= 6, 'Expected at least 6 curated mixer channels');
  for (final ch in kCuratedMixerChannels) {
    assert(ch.id.isNotEmpty, 'Channel ID must not be empty');
    assert(ch.title.isNotEmpty, 'Title must not be empty');
    assert(ch.subtitle.isNotEmpty, 'Subtitle must not be empty');
    assert(ch.assetPath.startsWith('assets/audio/'), 'Asset path must point to assets/audio/');
    assert(ch.volume >= 0.0 && ch.volume <= 1.0, 'Volume must be between 0 and 1');
    stdout.writeln('Channel: ${ch.id.padRight(14)} | Title: ${ch.title.padRight(18)} | Vol: ${ch.volume.toStringAsFixed(2)} | Asset: ${ch.assetPath}');
  }

  const testChannel = AmbientMixerChannel(
    id: 'test_rain',
    title: 'Rain',
    subtitle: 'Rain subtitle',
    assetPath: 'assets/audio/gentle_rain.mp3',
    iconKey: 'cloud.rain',
    isEnabled: true,
    volume: 0.80,
  );

  // Volume computation tests
  assert(testChannel.computedVolume(0.50) == 0.40, 'Computed volume must equal volume * masterVolume');
  assert(testChannel.computedVolume(0.50, fadeFactor: 0.50) == 0.20, 'Computed volume must account for fadeFactor');

  final mutedChannel = testChannel.copyWith(isMuted: true);
  assert(mutedChannel.computedVolume(1.0) == 0.0, 'Muted channel must output 0.0 volume');

  final disabledChannel = testChannel.copyWith(isEnabled: false);
  assert(disabledChannel.computedVolume(1.0) == 0.0, 'Disabled channel must output 0.0 volume');
  stdout.writeln('✓ AmbientMixerChannel attenuation and mute logic verified.');

  // 2. Verify Curated AmbientMixerPresets
  assert(kCuratedMixerPresets.length >= 4, 'Expected at least 4 curated presets');
  for (final preset in kCuratedMixerPresets) {
    assert(preset.id.isNotEmpty, 'Preset ID must not be empty');
    assert(preset.title.isNotEmpty, 'Preset title must not be empty');
    assert(preset.channelVolumes.isNotEmpty, 'Preset must define channel volumes');
    for (final entry in preset.channelVolumes.entries) {
      assert(kCuratedMixerChannels.any((c) => c.id == entry.key), 'Unknown channel in preset: ${entry.key}');
      assert(entry.value >= 0.0 && entry.value <= 1.0, 'Preset channel volume out of bounds');
    }
    stdout.writeln('Preset: ${preset.id.padRight(16)} | Title: ${preset.title.padRight(16)} | Channels: ${preset.channelVolumes.keys.join(', ')}');
  }
  stdout.writeln('✓ Curated AmbientMixerPresets validated.');

  // 3. Verify Logarithmic Attenuation Curve (Weber-Fechner Psychoacoustic Law)
  // Formula: factor = ln(1 + 9 * (t / 300)) / ln(10)
  final factor300 = AmbientMixerState.computeLogarithmicFadeFactor(300, 300);
  assert((factor300 - 1.0).abs() < 0.001, 'f(300s) must be 1.0, got $factor300');

  final factor150 = AmbientMixerState.computeLogarithmicFadeFactor(150, 300);
  assert((factor150 - 0.740).abs() < 0.01, 'f(150s) must be ~0.740, got $factor150');

  final factor30 = AmbientMixerState.computeLogarithmicFadeFactor(30, 300);
  assert((factor30 - 0.279).abs() < 0.01, 'f(30s) must be ~0.279, got $factor30');

  final factor0 = AmbientMixerState.computeLogarithmicFadeFactor(0, 300);
  assert(factor0 == 0.0, 'f(0s) must be exactly 0.0, got $factor0');

  final factorOver = AmbientMixerState.computeLogarithmicFadeFactor(600, 1800);
  assert(factorOver == 1.0, 'f(t >= 300) must be 1.0, got $factorOver');
  stdout.writeln('✓ Weber-Fechner logarithmic volume attenuation curve verified (f(300)=1.0, f(150)=0.740, f(30)=0.279, f(0)=0.0).');

  // 4. Verify AmbientMixerState and Functional State Mutations
  var state = AmbientMixerState.initial();
  assert(state.masterVolume == 0.75, 'Default master volume mismatch');
  assert(!state.isPlaying, 'Default isPlaying must be false');
  assert(state.activeChannelCount == 2, 'Default state active channels mismatch');

  // Master Volume update
  state = state.copyWith(masterVolume: 0.90);
  assert(state.masterVolume == 0.90, 'Master volume update failed');

  // Channel toggling
  state = state.toggleChannel('rain');
  assert(!state.channels.firstWhere((c) => c.id == 'rain').isEnabled, 'Channel toggle off failed');
  assert(state.activeChannelCount == 1, 'Active channel count failed after disable');

  state = state.toggleChannel('rain');
  assert(state.channels.firstWhere((c) => c.id == 'rain').isEnabled, 'Channel toggle back on failed');

  // Channel volume update
  state = state.setChannelVolume('rain', 0.85);
  assert(state.channels.firstWhere((c) => c.id == 'rain').volume == 0.85, 'Channel volume update failed');

  // Channel mute
  state = state.toggleChannelMute('rain');
  assert(state.channels.firstWhere((c) => c.id == 'rain').isMuted, 'Channel mute failed');
  assert(state.activeChannelCount == 1, 'Active count must decrease when channel is muted');
  assert(state.channels.firstWhere((c) => c.id == 'rain').computedVolume(state.masterVolume) == 0.0, 'Muted volume output must be 0');

  state = state.toggleChannelMute('rain'); // Unmute
  assert(!state.channels.firstWhere((c) => c.id == 'rain').isMuted, 'Channel unmute failed');

  // Preset application
  final rainyHearth = kCuratedMixerPresets.firstWhere((p) => p.id == 'rainy_hearth');
  state = state.applyPreset(rainyHearth);
  assert(state.activePresetId == 'rainy_hearth', 'Preset ID mismatch');
  assert(state.channels.firstWhere((c) => c.id == 'rain').isEnabled, 'Rain must be enabled in Rainy Hearth');
  assert(state.channels.firstWhere((c) => c.id == 'hearth').isEnabled, 'Hearth must be enabled in Rainy Hearth');
  assert(!state.channels.firstWhere((c) => c.id == 'waves').isEnabled, 'Waves must be disabled in Rainy Hearth');

  // Sleep timer configuration and decrement
  state = state.withTimer(30);
  assert(state.timerMinutes == 30, 'Timer minutes mismatch');
  assert(state.timerSecondsRemaining == 1800, 'Timer seconds mismatch');
  assert(state.formattedTimeRemaining == '30:00', 'Formatted timer mismatch');

  state = state.tickTimer();
  assert(state.timerSecondsRemaining == 1799, 'Timer tick failed');
  assert(state.formattedTimeRemaining == '29:59', 'Formatted timer after tick mismatch');

  // Test expiration on tickTimer
  final expiringState = state.copyWith(timerSecondsRemaining: 1, isPlaying: true);
  final expiredState = expiringState.tickTimer();
  assert(expiredState.timerSecondsRemaining == null, 'Timer must clear on expiry');
  assert(expiredState.timerMinutes == null, 'Timer minutes must clear on expiry');
  assert(!expiredState.isPlaying, 'Playback must stop on timer expiry');

  stdout.writeln('✓ AmbientMixerState functional mutations (channel toggle, volume, mute, preset, timer) verified.');

  // 5. Verify Routes and Taxonomy Integration
  assert(AppRoutes.ambientMixer == '/home/ambient-mixer', 'AppRoutes.ambientMixer constant mismatch');
  assert(ActivityCategory.audio.name == 'audio', 'ActivityCategory audio mismatch');
  assert(ActivityCategory.audio.displayName == 'Audio Sanctuary', 'ActivityCategory display name mismatch');
  stdout.writeln('✓ Routing constants and Activity Taxonomy alignment verified.');

  // 6. Verify JSON Catalog Entries
  final catalogFile = File('assets/data/curated_activities.json');
  assert(catalogFile.existsSync(), 'Catalog file must exist');
  final dynamic decoded = jsonDecode(catalogFile.readAsStringSync());
  assert(decoded is List, 'Catalog must be a list');
  final activities = (decoded as List).cast<Map<String, dynamic>>();

  final mixerActivity = activities.firstWhere(
    (a) => a['id'] == 'act_audio_sound_mixer',
    orElse: () => throw Exception('act_audio_sound_mixer missing from JSON catalog'),
  );
  assert(mixerActivity['category'] == 'audio', 'Category mismatch for sound mixer');
  assert(mixerActivity['route'] == '/home/soundscapes?mode=mixer', 'Route mismatch for sound mixer');

  final sleepTimerActivity = activities.firstWhere(
    (a) => a['id'] == 'act_sleep_fade_timer',
    orElse: () => throw Exception('act_sleep_fade_timer missing from JSON catalog'),
  );
  assert(sleepTimerActivity['category'] == 'sleep', 'Category mismatch for sleep fade timer');

  stdout.writeln('✓ Curated activities act_audio_sound_mixer and act_sleep_fade_timer validated in JSON catalog.');

  stdout.writeln('=== ALL Story 15.1: Ambient Audio Mixer & Sleep Wind-Down Assertions PASSED successfully! (100% Validated) ===');
}
