/// Abstract port defining audio playback capabilities for respiration
/// soundscapes and calming audio.
abstract class AudioPlayerPort {
  /// Loads an offline asset audio file configured for gapless looping.
  Future<void> loadLoopingAsset(String assetPath);

  /// Starts playback.
  Future<void> play();

  /// Pauses playback.
  Future<void> pause();

  /// Stops playback and resets position to beginning.
  Future<void> stop();

  /// Sets current volume (clamped between 0.0 and 1.0).
  Future<void> setVolume(double volume);

  /// Smoothly ramps volume up to target volume over [duration].
  Future<void> fadeIn({Duration duration = const Duration(milliseconds: 300), double targetVolume = 1.0});

  /// Smoothly ramps volume down to 0.0 over [duration].
  Future<void> fadeOut({Duration duration = const Duration(milliseconds: 300)});

  /// Disposes underlying audio resources.
  Future<void> dispose();

  /// Whether audio is actively playing.
  bool get isPlaying;

  /// Current volume level (0.0 to 1.0).
  double get volume;
}
