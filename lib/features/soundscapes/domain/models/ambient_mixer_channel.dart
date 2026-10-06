/// Represents an independent audio channel within the multi-track ambient mixer.
class AmbientMixerChannel {
  final String id;
  final String title;
  final String subtitle;
  final String assetPath;
  final String iconKey;
  final bool isEnabled;
  final double volume;
  final bool isMuted;

  const AmbientMixerChannel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.assetPath,
    required this.iconKey,
    this.isEnabled = false,
    this.volume = 0.60,
    this.isMuted = false,
  });

  /// Computes the effective output volume considering channel enable state, mute state,
  /// master volume, and sleep timer logarithmic fade factor.
  double computedVolume(double masterVolume, {double fadeFactor = 1.0}) {
    if (!isEnabled || isMuted) return 0.0;
    return (volume * masterVolume * fadeFactor).clamp(0.0, 1.0);
  }

  AmbientMixerChannel copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? assetPath,
    String? iconKey,
    bool? isEnabled,
    double? volume,
    bool? isMuted,
  }) {
    return AmbientMixerChannel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      assetPath: assetPath ?? this.assetPath,
      iconKey: iconKey ?? this.iconKey,
      isEnabled: isEnabled ?? this.isEnabled,
      volume: volume ?? this.volume,
      isMuted: isMuted ?? this.isMuted,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AmbientMixerChannel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          isEnabled == other.isEnabled &&
          (volume - other.volume).abs() < 0.001 &&
          isMuted == other.isMuted;

  @override
  int get hashCode => Object.hash(id, isEnabled, volume, isMuted);
}

/// Curated offline acoustic channels available for simultaneous layering.
const List<AmbientMixerChannel> kCuratedMixerChannels = [
  AmbientMixerChannel(
    id: 'rain',
    title: 'Gentle Rain',
    subtitle: 'Broadband acoustic water noise for auditory masking',
    assetPath: 'assets/audio/gentle_rain.mp3',
    iconKey: 'cloud.rain',
    isEnabled: true,
    volume: 0.65,
  ),
  AmbientMixerChannel(
    id: 'brown_noise',
    title: 'Deep Brown Noise',
    subtitle: 'Low-frequency acoustic blanket that settles racing thoughts',
    assetPath: 'assets/audio/calm_brown_noise.mp3',
    iconKey: 'waveform',
    isEnabled: true,
    volume: 0.40,
  ),
  AmbientMixerChannel(
    id: 'hearth',
    title: 'Warm Hearth',
    subtitle: 'Gentle crackle of quiet embers in a darkened room',
    assetPath: 'assets/audio/warm_campfire.mp3',
    iconKey: 'flame',
    isEnabled: false,
    volume: 0.50,
  ),
  AmbientMixerChannel(
    id: 'crickets',
    title: 'Night Crickets',
    subtitle: 'Calm nocturnal summer meadow ambiance',
    assetPath: 'assets/audio/night_crickets.mp3',
    iconKey: 'moon.stars',
    isEnabled: false,
    volume: 0.45,
  ),
  AmbientMixerChannel(
    id: 'waves',
    title: 'Ocean Waves',
    subtitle: 'Slow, rhythmic tidal swell mimicking relaxed respiration',
    assetPath: 'assets/audio/ocean_waves.mp3',
    iconKey: 'water.waves',
    isEnabled: false,
    volume: 0.55,
  ),
  AmbientMixerChannel(
    id: 'chimes',
    title: 'Night Chimes',
    subtitle: 'Sparse, mellow brass tones floating in a slow breeze',
    assetPath: 'assets/audio/wind_chimes.mp3',
    iconKey: 'bell',
    isEnabled: false,
    volume: 0.35,
  ),
];
