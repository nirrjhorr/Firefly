/// Represents an offline ambient soundscape curated specifically for pre-bed relaxation.
class SleepSoundTrack {
  final String id;
  final String title;
  final String subtitle;
  final String assetPath;
  final String iconKey;

  const SleepSoundTrack({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.assetPath,
    required this.iconKey,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SleepSoundTrack &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Default offline soundscape track.
const kDefaultSleepTrack = SleepSoundTrack(
  id: 'gentle_rain',
  title: 'Gentle Rain',
  subtitle: 'Soft, steady rainfall for soothing acoustic masking',
  assetPath: 'assets/audio/gentle_rain.mp3',
  iconKey: 'cloud.rain',
);

/// Offline soundscapes optimized for sleep onset with steady acoustic masking.
const List<SleepSoundTrack> kCuratedSleepTracks = [
  kDefaultSleepTrack,
  SleepSoundTrack(
    id: 'calm_brown_noise',
    title: 'Deep Brown Noise',
    subtitle: 'Low-frequency deep acoustic blanket that quiets racing thoughts',
    assetPath: 'assets/audio/calm_brown_noise.mp3',
    iconKey: 'waveform',
  ),
  SleepSoundTrack(
    id: 'night_crickets',
    title: 'Night Crickets',
    subtitle: 'Calm nocturnal summer meadow ambiance',
    assetPath: 'assets/audio/night_crickets.mp3',
    iconKey: 'moon.stars',
  ),
  SleepSoundTrack(
    id: 'ocean_waves',
    title: 'Ocean Waves',
    subtitle: 'Slow, rhythmic tidal swell mimicking relaxed breathing',
    assetPath: 'assets/audio/ocean_waves.mp3',
    iconKey: 'water.waves',
  ),
  SleepSoundTrack(
    id: 'warm_campfire',
    title: 'Warm Hearth',
    subtitle: 'Gentle crackle of quiet embers in the dark',
    assetPath: 'assets/audio/warm_campfire.mp3',
    iconKey: 'flame',
  ),
  SleepSoundTrack(
    id: 'wind_chimes',
    title: 'Night Chimes',
    subtitle: 'Sparse, mellow brass tones floating in a slow breeze',
    assetPath: 'assets/audio/wind_chimes.mp3',
    iconKey: 'bell',
  ),
];
