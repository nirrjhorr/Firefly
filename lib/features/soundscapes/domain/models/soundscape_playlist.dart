import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/icon_tokens.dart';

/// Pre-configured curated playlist oriented around specific psychological/wellbeing use cases.
@immutable
class SoundscapePlaylist {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String evidenceRationale;
  final IconData icon;
  final Color accentColor;
  final List<String> trackIds;

  const SoundscapePlaylist({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.evidenceRationale,
    required this.icon,
    required this.accentColor,
    required this.trackIds,
  });
}

/// The 8 primary curated playlists supported by Firefly.
const List<SoundscapePlaylist> kCuratedPlaylists = [
  SoundscapePlaylist(
    id: 'reset_10min',
    title: '10-Minute Reset',
    subtitle: 'Rapid sympathetic down-regulation',
    description: 'Crisp, refreshing nature and breath-paced acoustics for a mid-day pause.',
    evidenceRationale: 'Brief 5-10 minute natural sound intervals significantly reduce salivary cortisol and sympathetic tone during high cognitive workload.',
    icon: AppIcons.timer,
    accentColor: Color(0xFF4A7862), // Sage
    trackIds: ['cyclic_sigh_ambience', 'forest_birds', 'river_stream', 'grounding_chime'],
  ),
  SoundscapePlaylist(
    id: 'sleep_prep',
    title: 'Sleep Preparation',
    subtitle: 'Slow-wave sleep and pre-bed calming',
    description: 'Low-frequency noise profiles and nocturnal bioacoustics to facilitate sleep onset.',
    evidenceRationale: 'Pink noise and sub-80Hz nature acoustics enhance slow-wave sleep spindle synchrony and reduce sleep latency without pharmacological side effects.',
    icon: AppIcons.moodHeavy,
    accentColor: Color(0xFF3D6A9F), // Dusk
    trackIds: ['soft_pink_noise', 'calm_brown_noise', 'binaural_delta_drone', 'night_crickets', 'rain_on_tent'],
  ),
  SoundscapePlaylist(
    id: 'deep_relaxation',
    title: 'Deep Relaxation',
    subtitle: 'Tension release & vagal tone support',
    description: 'Hypnotic resonant water, singing bowls, and hearth ambience.',
    evidenceRationale: 'Tidal water cycles at 0.1 Hz resonate with human baroreflex oscillations, while singing bowl frequencies elicit sustained alpha/theta brainwave entrainment.',
    icon: AppIcons.progress,
    accentColor: Color(0xFF5D9478), // Sage Light
    trackIds: ['ocean_waves', 'grounding_chime', 'warm_campfire', 'binaural_theta_drone'],
  ),
  SoundscapePlaylist(
    id: 'cognitive_focus',
    title: 'Cognitive Focus',
    subtitle: 'Auditory masking & working memory shielding',
    description: 'Steady, non-intrusive soundscapes that drown out office, conversational, and street noise.',
    evidenceRationale: 'Broadband brown and white noise act as acoustic curtains, preventing sudden auditory transients from breaking sustained attention.',
    icon: Icons.psychology_outlined,
    accentColor: Color(0xFF2E5080), // Dusk Dark
    trackIds: ['calm_brown_noise', 'gentle_white_noise', 'binaural_alpha_drone', 'waterfall', 'rhythmic_clock'],
  ),
  SoundscapePlaylist(
    id: 'rainy_evening',
    title: 'Rainy Evening',
    subtitle: 'Comfort, shelter, and cozy rest',
    description: 'Multi-textured rain on glass, tent, and forest foliage.',
    evidenceRationale: 'Prospect-refuge acoustic dynamics induce psychological sensations of shelter, reducing vigilance and state anxiety.',
    icon: AppIcons.waterDrop,
    accentColor: Color(0xFF6B7E8C), // Neutral Cool
    trackIds: ['gentle_rain', 'rain_on_window', 'rain_on_tent', 'rain_on_leaves', 'thunder_rumble'],
  ),
  SoundscapePlaylist(
    id: 'forest_sanctuary',
    title: 'Forest Sanctuary',
    subtitle: 'Soft fascination & attention restoration',
    description: 'Lush woodland birds, canopy wind breeze, and forest river streams.',
    evidenceRationale: 'Kaplan\'s Attention Restoration Theory demonstrates that arboreal nature biophony replenishes depleted executive focus mechanisms.',
    icon: AppIcons.natureBirds,
    accentColor: Color(0xFF2D4A3A), // Sage Deep
    trackIds: ['forest_birds', 'wind_in_trees', 'river_stream', 'walk_on_leaves', 'tropical_jungle'],
  ),
  SoundscapePlaylist(
    id: 'sensory_grounding',
    title: 'Sensory Grounding',
    subtitle: 'Anchor present somatic awareness',
    description: 'Tactile chimes, footsteps, bubbles, and purring for grounding in reality.',
    evidenceRationale: 'Distinct, recognizable tactile auditory cues help disrupt dissociation and cognitive flooding by anchoring focus to tangible physical sensations.',
    icon: Icons.fingerprint_rounded,
    accentColor: Color(0xFFC27A30), // Amber Warmth
    trackIds: ['grounding_chime', 'wind_chimes', 'walk_in_snow', 'underwater_bubbles', 'cat_purring'],
  ),
  SoundscapePlaylist(
    id: 'ocean_rest',
    title: 'Oceanic Rest',
    subtitle: 'Endless horizons and tidal pacing',
    description: 'Pacific waves, gentle swells, and coastal atmosphere.',
    evidenceRationale: 'Large water body acoustics promote expansive cognitive reappraisal and alleviate acute feelings of emotional constriction.',
    icon: AppIcons.soundWaves,
    accentColor: Color(0xFF2E3840), // Slate
    trackIds: ['ocean_waves', 'cave_water_droplets', 'underwater_bubbles'],
  ),
];
