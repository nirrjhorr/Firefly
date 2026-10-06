/// Curated multi-channel soundscape preset for zero-decision pre-bed relaxation.
class AmbientMixerPreset {
  final String id;
  final String title;
  final String subtitle;
  final Map<String, double> channelVolumes;

  const AmbientMixerPreset({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.channelVolumes,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AmbientMixerPreset &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Curated restful acoustic presets combining complementary sonic textures.
const List<AmbientMixerPreset> kCuratedMixerPresets = [
  AmbientMixerPreset(
    id: 'deep_blanket',
    title: 'Deep Blanket',
    subtitle: 'Rain and brown noise for quietening persistent mental chatter',
    channelVolumes: {
      'rain': 0.60,
      'brown_noise': 0.50,
    },
  ),
  AmbientMixerPreset(
    id: 'rainy_hearth',
    title: 'Rainy Hearth',
    subtitle: 'Rhythmic rainfall grounded by the gentle warmth of crackling embers',
    channelVolumes: {
      'rain': 0.65,
      'hearth': 0.45,
    },
  ),
  AmbientMixerPreset(
    id: 'summer_night',
    title: 'Summer Night',
    subtitle: 'Dusk meadow crickets accompanied by delicate wind chimes',
    channelVolumes: {
      'crickets': 0.55,
      'chimes': 0.35,
    },
  ),
  AmbientMixerPreset(
    id: 'ocean_drift',
    title: 'Ocean Drift',
    subtitle: 'Slow, rhythmic tidal swell with grounding low frequencies',
    channelVolumes: {
      'waves': 0.60,
      'brown_noise': 0.35,
    },
  ),
  AmbientMixerPreset(
    id: 'calm_shelter',
    title: 'Calm Shelter',
    subtitle: 'Rain on the roof, quiet chimes, and warmth inside',
    channelVolumes: {
      'rain': 0.50,
      'hearth': 0.40,
      'chimes': 0.25,
    },
  ),
];
