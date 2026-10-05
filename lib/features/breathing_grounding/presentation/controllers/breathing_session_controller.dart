import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/contracts/audio_player_port.dart';
import '../../../../core/contracts/haptics_port.dart';
import '../../domain/models/breathing_session_state.dart';
import 'hardware_providers.dart';

/// Available ambient soundscapes for respiration and grounding.
class RespirationSoundscapes {
  static const String cyclicSighAmbience = 'cyclic_sigh_ambience';
  static const String gentleRain = 'gentle_rain';
  static const String groundingChime = 'grounding_chime';

  static String? resolveAssetPath(String? soundscapeId) {
    if (soundscapeId == null) return null;
    switch (soundscapeId) {
      case cyclicSighAmbience:
        return 'assets/audio/cyclic_sigh_ambience.mp3';
      case gentleRain:
        return 'assets/audio/gentle_rain.mp3';
      case groundingChime:
        return 'assets/audio/grounding_chime.mp3';
      default:
        return soundscapeId.contains('/')
            ? soundscapeId
            : 'assets/audio/$soundscapeId.mp3';
    }
  }
}

/// Reactive controller driving multi-technique respiration (Cyclic Sighing, Box,
/// Resonance, 4-7-8, Star, Diaphragmatic), synchronized haptic cues, and gapless audio.
class BreathingSessionNotifier extends StateNotifier<BreathingSessionState> {
  final AudioPlayerPort _audioPlayer;
  final HapticsPort _haptics;
  final Duration tickerInterval;

  Timer? _timer;
  int _elapsedPhaseMs = 0;
  int _totalElapsedMs = 0;
  bool _isDisposed = false;

  BreathingSessionNotifier({
    required AudioPlayerPort audioPlayer,
    required HapticsPort haptics,
    this.tickerInterval = const Duration(milliseconds: 50),
    BreathingTechnique initialTechnique = BreathingTechnique.cyclicSighing,
    String? defaultSoundscape,
  })  : _audioPlayer = audioPlayer,
        _haptics = haptics,
        super(BreathingSessionState(
          phase: BreathingPhase.inhale,
          technique: initialTechnique,
          soundscape: defaultSoundscape,
        ));

  /// Selects or changes the active breathing technique.
  void setTechnique(BreathingTechnique technique) {
    if (_isDisposed) return;
    _elapsedPhaseMs = 0;
    state = state.copyWith(
      technique: technique,
      phase: BreathingPhase.inhale,
      phaseProgress: 0.0,
    );
  }

  /// Starts or restarts a breathing session.
  Future<void> start() async {
    if (_isDisposed) return;
    _timer?.cancel();
    _elapsedPhaseMs = 0;
    _totalElapsedMs = 0;

    state = state.copyWith(
      phase: BreathingPhase.inhale,
      phaseProgress: 0.0,
      cycleCount: 0,
      elapsedSeconds: 0,
      isActive: true,
    );

    _triggerInhaleHaptics();
    _playCurrentSoundscape();
    _startTicker();
  }

  /// Pauses an active session.
  Future<void> pause() async {
    if (_isDisposed || !state.isActive) return;
    _timer?.cancel();
    _timer = null;

    state = state.copyWith(isActive: false);
    await _fadeOutAudio();
  }

  /// Resumes a paused session without resetting cycle count or elapsed time.
  Future<void> resume() async {
    if (_isDisposed || state.isActive) return;

    state = state.copyWith(isActive: true);
    await _fadeInAudio();
    _startTicker();
  }

  /// Toggles between active and paused.
  Future<void> togglePlayPause() async {
    if (state.isActive) {
      await pause();
    } else {
      if (_totalElapsedMs == 0) {
        await start();
      } else {
        await resume();
      }
    }
  }

  /// Stops and completely resets the session.
  Future<void> stop() async {
    if (_isDisposed) return;
    _timer?.cancel();
    _timer = null;
    _elapsedPhaseMs = 0;
    _totalElapsedMs = 0;

    state = state.copyWith(
      phase: BreathingPhase.inhale,
      phaseProgress: 0.0,
      cycleCount: 0,
      elapsedSeconds: 0,
      isActive: false,
    );

    await _stopAudio();
  }

  /// Selects or changes the background ambient soundscape.
  Future<void> setSoundscape(String? newSoundscape) async {
    if (_isDisposed) return;
    final changed = state.soundscape != newSoundscape;
    state = state.copyWith(
      soundscape: newSoundscape,
      clearSoundscape: newSoundscape == null,
    );

    if (state.isActive && changed) {
      if (newSoundscape == null) {
        await _stopAudio();
      } else {
        await _playCurrentSoundscape();
      }
    }
  }

  void _startTicker() {
    _timer?.cancel();
    _timer = Timer.periodic(tickerInterval, (timer) {
      if (_isDisposed || !state.isActive) {
        timer.cancel();
        return;
      }
      _onTick();
    });
  }

  void _onTick() {
    _elapsedPhaseMs += tickerInterval.inMilliseconds;
    _totalElapsedMs += tickerInterval.inMilliseconds;

    final targetPhaseMs = _getTargetDurationMs(state.phase, state.technique);

    if (_elapsedPhaseMs >= targetPhaseMs) {
      _elapsedPhaseMs = 0;
      _advancePhase();
    } else {
      final progress = (_elapsedPhaseMs / targetPhaseMs).clamp(0.0, 1.0);
      state = state.copyWith(
        phaseProgress: progress,
        elapsedSeconds: _totalElapsedMs ~/ 1000,
      );
    }
  }

  int _getTargetDurationMs(BreathingPhase phase, BreathingTechnique technique) {
    switch (phase) {
      case BreathingPhase.inhale:
        return technique.inhaleMs;
      case BreathingPhase.inhaleHold:
        return technique.inhaleHoldMs > 0 ? technique.inhaleHoldMs : 50;
      case BreathingPhase.exhale:
        return technique.exhaleMs;
      case BreathingPhase.exhaleHold:
        return technique.exhaleHoldMs > 0 ? technique.exhaleHoldMs : 50;
    }
  }

  void _advancePhase() {
    final tech = state.technique;
    switch (state.phase) {
      case BreathingPhase.inhale:
        if (tech.inhaleHoldMs > 0) {
          state = state.copyWith(
            phase: BreathingPhase.inhaleHold,
            phaseProgress: 0.0,
            elapsedSeconds: _totalElapsedMs ~/ 1000,
          );
          _triggerHoldHaptics();
        } else {
          state = state.copyWith(
            phase: BreathingPhase.exhale,
            phaseProgress: 0.0,
            elapsedSeconds: _totalElapsedMs ~/ 1000,
          );
          _triggerExhaleHaptics();
        }
        break;

      case BreathingPhase.inhaleHold:
        state = state.copyWith(
          phase: BreathingPhase.exhale,
          phaseProgress: 0.0,
          elapsedSeconds: _totalElapsedMs ~/ 1000,
        );
        _triggerExhaleHaptics();
        break;

      case BreathingPhase.exhale:
        if (tech.exhaleHoldMs > 0) {
          state = state.copyWith(
            phase: BreathingPhase.exhaleHold,
            phaseProgress: 0.0,
            elapsedSeconds: _totalElapsedMs ~/ 1000,
          );
          _triggerHoldHaptics();
        } else {
          final newCount = state.cycleCount + 1;
          state = state.copyWith(
            phase: BreathingPhase.inhale,
            phaseProgress: 0.0,
            cycleCount: newCount,
            elapsedSeconds: _totalElapsedMs ~/ 1000,
          );
          _triggerInhaleHaptics();
        }
        break;

      case BreathingPhase.exhaleHold:
        final newCount = state.cycleCount + 1;
        state = state.copyWith(
          phase: BreathingPhase.inhale,
          phaseProgress: 0.0,
          cycleCount: newCount,
          elapsedSeconds: _totalElapsedMs ~/ 1000,
        );
        _triggerInhaleHaptics();
        break;
    }
  }

  void _triggerInhaleHaptics() {
    try {
      _haptics.phaseTransitionInhale();
    } catch (_) {}
  }

  void _triggerExhaleHaptics() {
    try {
      _haptics.phaseTransitionExhale();
    } catch (_) {}
  }

  void _triggerHoldHaptics() {
    try {
      _haptics.selectionClick();
    } catch (_) {}
  }

  Future<void> _playCurrentSoundscape() async {
    if (state.soundscape == null) return;
    try {
      final path = RespirationSoundscapes.resolveAssetPath(state.soundscape);
      if (path != null) {
        await _audioPlayer.loadLoopingAsset(path);
        await _audioPlayer.fadeIn(duration: const Duration(milliseconds: 300));
        await _audioPlayer.play();
      }
    } catch (_) {}
  }

  Future<void> _fadeInAudio() async {
    try {
      if (state.soundscape != null) {
        await _audioPlayer.fadeIn(duration: const Duration(milliseconds: 300));
        await _audioPlayer.play();
      }
    } catch (_) {}
  }

  Future<void> _fadeOutAudio() async {
    try {
      await _audioPlayer.fadeOut(duration: const Duration(milliseconds: 300));
    } catch (_) {}
  }

  Future<void> _stopAudio() async {
    try {
      await _audioPlayer.stop();
    } catch (_) {}
  }

  @override
  void dispose() {
    _isDisposed = true;
    _timer?.cancel();
    _timer = null;
    try {
      _audioPlayer.stop();
    } catch (_) {}
    super.dispose();
  }
}

/// Riverpod provider managing reactive respiration sessions.
final breathingSessionControllerProvider = StateNotifierProvider.autoDispose<
    BreathingSessionNotifier, BreathingSessionState>((ref) {
  final audioPlayer = ref.watch(audioPlayerPortProvider);
  final haptics = ref.watch(hapticsPortProvider);

  final notifier = BreathingSessionNotifier(
    audioPlayer: audioPlayer,
    haptics: haptics,
    defaultSoundscape: RespirationSoundscapes.cyclicSighAmbience,
  );

  ref.onDispose(() {
    notifier.dispose();
  });

  return notifier;
});
