import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../core/contracts/audio_player_port.dart';

/// Concrete adapter for [AudioPlayerPort] leveraging [AudioPlayer] from `just_audio`
/// and [AudioSession] for seamless offline background ambient playback.
class JustAudioPlayerAdapter implements AudioPlayerPort {
  final AudioPlayer _player;
  double _volume = 1.0;
  bool _isDisposed = false;

  JustAudioPlayerAdapter({AudioPlayer? player})
      : _player = player ?? AudioPlayer() {
    _initSession();
  }

  Future<void> _initSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
    } catch (_) {
      // Silent failure: session configuration errors should not break audio adapter
    }
  }

  @override
  bool get isPlaying => _player.playing;

  @override
  double get volume => _volume;

  @override
  Future<void> loadLoopingAsset(String assetPath) async {
    if (_isDisposed) return;
    try {
      await _player.setAsset(assetPath);
      await _player.setLoopMode(LoopMode.one);
    } catch (_) {
      // Silent failure: missing asset or decode error shouldn't crash breathing flow
    }
  }

  @override
  Future<void> play() async {
    if (_isDisposed) return;
    try {
      await _player.play();
    } catch (_) {
      // Silent failure
    }
  }

  @override
  Future<void> pause() async {
    if (_isDisposed) return;
    try {
      await _player.pause();
    } catch (_) {
      // Silent failure
    }
  }

  @override
  Future<void> stop() async {
    if (_isDisposed) return;
    try {
      await _player.stop();
    } catch (_) {
      // Silent failure
    }
  }

  @override
  Future<void> setVolume(double volume) async {
    if (_isDisposed) return;
    try {
      _volume = volume.clamp(0.0, 1.0);
      await _player.setVolume(_volume);
    } catch (_) {
      // Silent failure
    }
  }

  @override
  Future<void> fadeIn({
    Duration duration = const Duration(milliseconds: 300),
    double targetVolume = 1.0,
  }) async {
    if (_isDisposed) return;
    try {
      const steps = 10;
      final stepDuration =
          Duration(milliseconds: duration.inMilliseconds ~/ steps);
      final startVolume = _volume;
      final clampedTarget = targetVolume.clamp(0.0, 1.0);
      final delta = (clampedTarget - startVolume) / steps;

      for (int i = 1; i <= steps; i++) {
        if (_isDisposed) break;
        final current = (startVolume + delta * i).clamp(0.0, 1.0);
        await setVolume(current);
        if (i < steps) {
          await Future<void>.delayed(stepDuration);
        }
      }
    } catch (_) {
      // Silent failure
    }
  }

  @override
  Future<void> fadeOut({
    Duration duration = const Duration(milliseconds: 300),
  }) async {
    if (_isDisposed) return;
    try {
      const steps = 10;
      final stepDuration =
          Duration(milliseconds: duration.inMilliseconds ~/ steps);
      final startVolume = _volume;
      final delta = startVolume / steps;

      for (int i = 1; i <= steps; i++) {
        if (_isDisposed) break;
        final current = (startVolume - delta * i).clamp(0.0, 1.0);
        await setVolume(current);
        if (i < steps) {
          await Future<void>.delayed(stepDuration);
        }
      }
      await pause();
    } catch (_) {
      // Silent failure
    }
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    try {
      await _player.dispose();
    } catch (_) {
      // Silent failure
    }
  }
}
