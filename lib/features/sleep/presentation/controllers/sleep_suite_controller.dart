import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/contracts/audio_player_port.dart';
import '../../../breathing_grounding/data/adapters/just_audio_player_adapter.dart';
import '../../data/repositories/worry_dump_repository_impl.dart';
import '../../domain/models/sleep_session_state.dart';
import '../../domain/models/sleep_sound_track.dart';
import '../../domain/models/worry_dump_entry.dart';
import '../../domain/repositories/worry_dump_repository.dart';

/// StateNotifier managing pre-bed sleep sanctuary interactions:
/// - Dual-disposition worry dump (park vs. dissolve)
/// - Ambient audio playback with logarithmic fade timer
/// - Circadian wake companion target
class SleepSuiteNotifier extends StateNotifier<SleepSessionState> {
  final WorryDumpRepository _repository;
  final AudioPlayerPort _audioPlayer;
  Timer? _timer;
  int _totalTimerSeconds = 0;

  SleepSuiteNotifier({
    WorryDumpRepository? repository,
    AudioPlayerPort? audioPlayer,
    SleepSessionState initialState = const SleepSessionState(),
  })  : _repository = repository ?? WorryDumpRepositoryImpl(),
        _audioPlayer = audioPlayer ?? JustAudioPlayerAdapter(),
        super(initialState) {
    loadParkedWorries();
  }

  /// Loads stored parked worry entries and purges expired ones.
  Future<void> loadParkedWorries() async {
    final entries = await _repository.getParkedWorries();
    state = state.copyWith(parkedEntries: entries);
  }

  /// Switch between Worry Dump, Ambient Soundscape, and Wake Companion tabs.
  void switchTab(SleepSuiteTab tab) {
    state = state.copyWith(activeTab: tab, clearStatusMessage: true);
  }

  /// Updates draft worry text in real-time.
  void updateWorryText(String text) {
    state = state.copyWith(worryText: text, clearStatusMessage: true);
  }

  /// Disposition 1: "Park until morning"
  /// Encrypts entry, locks it until 8:00 AM next day, and clears memory.
  Future<void> parkUntilMorning({DateTime? now}) async {
    final text = state.worryText.trim();
    if (text.isEmpty) return;

    final entryId = 'worry_${DateTime.now().millisecondsSinceEpoch}';
    final entry = WorryDumpEntry.createParked(
      id: entryId,
      contentPlaintext: text,
      now: now,
    );

    await _repository.saveParkedWorry(entry);

    // Cryptographically zero memory buffers of the draft text
    WorryDumpRepositoryImpl.cryptoEraseString(text);

    final updated = await _repository.getParkedWorries();
    state = state.copyWith(
      worryText: '',
      parkedEntries: updated,
      statusMessage: 'Parked safely until 8:00 AM. Your mind is free to rest.',
    );
  }

  /// Disposition 2: "Let it dissolve"
  /// Triggers peaceful dissolve animation, then immediately zeroes memory buffers.
  Future<void> letItDissolve() async {
    final text = state.worryText;
    if (text.isEmpty) return;

    state = state.copyWith(isDissolving: true, dissolveProgress: 0.0);

    // Simulate gentle 800ms fade/particle dissipation
    for (int step = 1; step <= 8; step++) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      if (!mounted) break;
      state = state.copyWith(dissolveProgress: step / 8.0);
    }

    // Cryptographically wipe text in memory
    WorryDumpRepositoryImpl.cryptoEraseString(text);

    if (mounted) {
      state = state.copyWith(
        worryText: '',
        isDissolving: false,
        dissolveProgress: 0.0,
        statusMessage: 'Your thought has dissolved completely into the dark.',
      );
    }
  }

  /// Deletes a parked worry entry and updates state.
  Future<void> deleteParkedEntry(String id) async {
    await _repository.deleteWorry(id);
    await loadParkedWorries();
  }

  /// Selects a new ambient soundscape track.
  Future<void> selectTrack(SleepSoundTrack track) async {
    final wasPlaying = state.isPlaying;
    state = state.copyWith(selectedTrack: track);

    if (wasPlaying) {
      await _audioPlayer.stop();
      await _audioPlayer.loadLoopingAsset(track.assetPath);
      await _audioPlayer.setVolume(state.currentVolume);
      await _audioPlayer.play();
    }
  }

  /// Toggles ambient sound playback on or off.
  Future<void> togglePlayback() async {
    if (state.isPlaying) {
      await _audioPlayer.pause();
      state = state.copyWith(isPlaying: false);
    } else {
      await _audioPlayer.loadLoopingAsset(state.selectedTrack.assetPath);
      await _audioPlayer.setVolume(state.currentVolume);
      await _audioPlayer.play();
      state = state.copyWith(isPlaying: true);
    }
  }

  /// Sets base volume (0.0 to 1.0) and updates player.
  Future<void> setVolume(double volume) async {
    final clamped = volume.clamp(0.0, 1.0);
    state = state.copyWith(baseVolume: clamped, currentVolume: clamped);
    await _audioPlayer.setVolume(clamped);
  }

  /// Sets sleep timer duration in minutes (15, 30, 45, 60 or null).
  /// Activates logarithmic volume attenuation over the final 5 minutes.
  void setTimer(int? minutes) {
    _cancelTimer();

    if (minutes == null || minutes <= 0) {
      state = state.copyWith(clearTimer: true);
      return;
    }

    final totalSeconds = minutes * 60;
    _totalTimerSeconds = totalSeconds;

    state = state.copyWith(
      timerMinutes: minutes,
      timerSecondsRemaining: totalSeconds,
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      final remaining = (state.timerSecondsRemaining ?? 0) - 1;

      if (remaining <= 0) {
        timer.cancel();
        await stopAudio();
        state = state.copyWith(clearTimer: true);
      } else {
        // Calculate logarithmic volume fade factor over the final 5 minutes (300s)
        final fadeFactor = SleepSessionState.computeLogarithmicFadeFactor(
          remaining,
          _totalTimerSeconds,
        );
        final fadedVolume = (state.baseVolume * fadeFactor).clamp(0.0, 1.0);

        if ((state.currentVolume - fadedVolume).abs() > 0.01) {
          await _audioPlayer.setVolume(fadedVolume);
        }

        state = state.copyWith(
          timerSecondsRemaining: remaining,
          currentVolume: fadedVolume,
        );
      }
    });
  }

  /// Sets circadian wake companion target time.
  void setWakeTarget(int hour, int minute) {
    state = state.copyWith(
      wakeTargetHour: hour,
      wakeTargetMinute: minute,
      isWakeTargetSet: true,
      statusMessage: 'Wake companion set. Sleep deeply with a steady morning anchor.',
    );
  }

  /// Stops audio playback and resets timer.
  Future<void> stopAudio() async {
    _cancelTimer();
    await _audioPlayer.stop();
    state = state.copyWith(
      isPlaying: false,
      clearTimer: true,
      currentVolume: state.baseVolume,
    );
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _cancelTimer();
    _audioPlayer.dispose();
    super.dispose();
  }
}

final worryDumpRepositoryProvider = Provider<WorryDumpRepository>((ref) {
  return WorryDumpRepositoryImpl();
});

final sleepSuiteProvider =
    StateNotifierProvider<SleepSuiteNotifier, SleepSessionState>((ref) {
  final repo = ref.watch(worryDumpRepositoryProvider);
  return SleepSuiteNotifier(repository: repo);
});
