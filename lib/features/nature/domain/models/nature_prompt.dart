import 'nature_observation_mode.dart';

/// An individual observational prompt within a nature grounding session.
class NaturePrompt {
  const NaturePrompt({
    required this.id,
    required this.mode,
    required this.stepNumber,
    required this.stageTitle,
    required this.cueText,
    required this.reflectionCue,
    required this.sensoryAnchor,
    this.indoorTip,
  });

  final String id;
  final NatureObservationMode mode;
  final int stepNumber;
  final String stageTitle;
  final String cueText;
  final String reflectionCue;
  final String sensoryAnchor;
  final String? indoorTip;
}

/// Offline curated prompt library for nature and environmental observation.
const Map<NatureObservationMode, List<NaturePrompt>> kOfflineNaturePrompts = {
  NatureObservationMode.skyGazing: [
    NaturePrompt(
      id: 'sky_1',
      mode: NatureObservationMode.skyGazing,
      stepNumber: 1,
      stageTitle: 'Soften Your Gaze',
      cueText: 'Direct your gaze toward the open sky above or outside your window. Let your peripheral vision gently open without focusing on a single spot.',
      reflectionCue: 'Notice the widest expanse of light or space you can see right now.',
      sensoryAnchor: 'Peripheral Vision',
      indoorTip: 'Look upward toward the top of a window or high corner of the room.',
    ),
    NaturePrompt(
      id: 'sky_2',
      mode: NatureObservationMode.skyGazing,
      stepNumber: 2,
      stageTitle: 'Follow Slow Drift',
      cueText: 'Find one cloud edge or subtle shift in air. Watch how gently and effortlessly it shifts across the distance.',
      reflectionCue: 'Notice how the sky holds everything without effort or tension.',
      sensoryAnchor: 'Visual Motion',
      indoorTip: 'Notice the boundary where the window frame meets daylight.',
    ),
    NaturePrompt(
      id: 'sky_3',
      mode: NatureObservationMode.skyGazing,
      stepNumber: 3,
      stageTitle: 'Subtle Gradients',
      cueText: 'Look across the expanse from the horizon to higher up. Observe the delicate transition between tones of blue, grey, gold, or dusk.',
      reflectionCue: 'Where is the light deepest? Where is it softest?',
      sensoryAnchor: 'Color Nuance',
      indoorTip: 'Observe how daylight fades as it moves deeper into your room.',
    ),
    NaturePrompt(
      id: 'sky_4',
      mode: NatureObservationMode.skyGazing,
      stepNumber: 4,
      stageTitle: 'Rest in the Vastness',
      cueText: 'Take a slow, quiet breath. Let yourself remember that whatever is happening inside your mind, this vast calm sky is always here above you.',
      reflectionCue: 'Feel your chest soften as you let your attention rest in open space.',
      sensoryAnchor: 'Whole Body Presence',
    ),
  ],
  NatureObservationMode.treeCanopy: [
    NaturePrompt(
      id: 'tree_1',
      mode: NatureObservationMode.treeCanopy,
      stepNumber: 1,
      stageTitle: 'Notice the Silhouette',
      cueText: 'Look at a tree, plant, or branch. Notice its overall shape and how it reaches out into the surrounding space.',
      reflectionCue: 'Observe the natural asymmetry of living growth.',
      sensoryAnchor: 'Organic Geometry',
      indoorTip: 'Look at a houseplant or a leaf clipping in water.',
    ),
    NaturePrompt(
      id: 'tree_2',
      mode: NatureObservationMode.treeCanopy,
      stepNumber: 2,
      stageTitle: 'Trace Branching Fractals',
      cueText: 'Pick one branch and follow it from where it is thickest out to the smallest, thinnest twigs.',
      reflectionCue: 'Notice how each split creates a smaller version of the whole tree.',
      sensoryAnchor: 'Pattern Tracking',
      indoorTip: 'Trace the veins on a single leaf with your eyes.',
    ),
    NaturePrompt(
      id: 'tree_3',
      mode: NatureObservationMode.treeCanopy,
      stepNumber: 3,
      stageTitle: 'Leaves in Motion',
      cueText: 'Watch the leaves fluttering or settling. Notice how different clusters move at slightly different moments.',
      reflectionCue: 'Notice how the tree yields to the air without snapping.',
      sensoryAnchor: 'Subtle Kinetic Rhythm',
      indoorTip: 'Observe the subtle stillness or slow sway of a plant stem.',
    ),
    NaturePrompt(
      id: 'tree_4',
      mode: NatureObservationMode.treeCanopy,
      stepNumber: 4,
      stageTitle: 'Rooted Stability',
      cueText: 'Bring your attention down to where the trunk meets the earth. Feel your own feet resting on solid ground in the same way.',
      reflectionCue: 'Feel the connection between living ground and upright balance.',
      sensoryAnchor: 'Proprioception',
    ),
  ],
  NatureObservationMode.lightAndShadow: [
    NaturePrompt(
      id: 'light_1',
      mode: NatureObservationMode.lightAndShadow,
      stepNumber: 1,
      stageTitle: 'Locate the Light Source',
      cueText: 'Turn your attention toward the primary source of natural light—the sun, a window, or daylight reflecting off a surface.',
      reflectionCue: 'Where is illumination entering your space right now?',
      sensoryAnchor: 'Luminance',
    ),
    NaturePrompt(
      id: 'light_2',
      mode: NatureObservationMode.lightAndShadow,
      stepNumber: 2,
      stageTitle: 'Find the Shadow Edge',
      cueText: 'Look for where light casts a shadow—against a wall, across floorboards, or beneath an object.',
      reflectionCue: 'Is the border sharp or softly blurred into darkness?',
      sensoryAnchor: 'Edge Contrast',
    ),
    NaturePrompt(
      id: 'light_3',
      mode: NatureObservationMode.lightAndShadow,
      stepNumber: 3,
      stageTitle: 'Texture in the Light',
      cueText: 'Look closely at a surface where light is hitting. Notice small textures—wood grain, fabric weave, or wall plaster.',
      reflectionCue: 'Notice how light reveals details that were invisible in the shade.',
      sensoryAnchor: 'Surface Micro-Detail',
    ),
    NaturePrompt(
      id: 'light_4',
      mode: NatureObservationMode.lightAndShadow,
      stepNumber: 4,
      stageTitle: 'The Slow Movement of Sun',
      cueText: 'Rest for a moment noticing that even when everything feels frantic, sunlight moves steadily and unhurried across the earth.',
      reflectionCue: 'Allow yourself to move at the gentle speed of daylight.',
      sensoryAnchor: 'Temporal Grounding',
    ),
  ],
  NatureObservationMode.outdoorGrounding: [
    NaturePrompt(
      id: 'ground_1',
      mode: NatureObservationMode.outdoorGrounding,
      stepNumber: 1,
      stageTitle: 'Contact with the Earth',
      cueText: 'Bring your awareness down to the soles of your feet. Feel the downward pull of gravity and the firm support underneath.',
      reflectionCue: 'Feel how solid the earth is. You do not have to hold yourself up alone.',
      sensoryAnchor: 'Gravity & Ground',
    ),
    NaturePrompt(
      id: 'ground_2',
      mode: NatureObservationMode.outdoorGrounding,
      stepNumber: 2,
      stageTitle: 'Air on Skin',
      cueText: 'Notice the ambient temperature on your hands, neck, or face. Is the air cool, warm, dry, or humid?',
      reflectionCue: 'Sense the boundary where your body meets the surrounding air.',
      sensoryAnchor: 'Tactile Thermal',
    ),
    NaturePrompt(
      id: 'ground_3',
      mode: NatureObservationMode.outdoorGrounding,
      stepNumber: 3,
      stageTitle: 'Touch a Natural Texture',
      cueText: 'Reach out and touch a natural material nearby—bark, a stone, soil, a leaf, or unvarnished wood.',
      reflectionCue: 'Feel its roughness, coolness, grain, or softness.',
      sensoryAnchor: 'Tactile Texture',
      indoorTip: 'Touch a wooden tabletop, a smooth stone, or a cotton cloth.',
    ),
    NaturePrompt(
      id: 'ground_4',
      mode: NatureObservationMode.outdoorGrounding,
      stepNumber: 4,
      stageTitle: 'Inhale the Atmosphere',
      cueText: 'Take a gentle breath through your nose. Notice any subtle natural scents—earth, rain, dried grass, wood, or fresh air.',
      reflectionCue: 'Let your body absorb this simple, clean breath.',
      sensoryAnchor: 'Olfactory & Breath',
    ),
  ],
  NatureObservationMode.weatherNotice: [
    NaturePrompt(
      id: 'weather_1',
      mode: NatureObservationMode.weatherNotice,
      stepNumber: 1,
      stageTitle: 'Listen to the Atmosphere',
      cueText: 'Close your eyes for ten seconds or soften your vision. Listen for ambient weather sounds—wind rushing, rain falling, or quiet air.',
      reflectionCue: 'What is the background rhythm of the day outside?',
      sensoryAnchor: 'Auditory Layering',
      indoorTip: 'Listen near an exterior window or vent.',
    ),
    NaturePrompt(
      id: 'weather_2',
      mode: NatureObservationMode.weatherNotice,
      stepNumber: 2,
      stageTitle: 'Air Movement',
      cueText: 'Notice whether the air is still or flowing. If there is a breeze, notice how it moves across leaves, clothing, or skin.',
      reflectionCue: 'Notice how air is constantly refreshing the space around you.',
      sensoryAnchor: 'Barometric & Air Flow',
    ),
    NaturePrompt(
      id: 'weather_3',
      mode: NatureObservationMode.weatherNotice,
      stepNumber: 3,
      stageTitle: 'Precipitation or Clarity',
      cueText: 'Observe water in the air: rain droplets on glass, morning dew, mist, or clear crisp sunlight.',
      reflectionCue: 'Watch how water collects, beads, or reflects light.',
      sensoryAnchor: 'Atmospheric Optics',
    ),
    NaturePrompt(
      id: 'weather_4',
      mode: NatureObservationMode.weatherNotice,
      stepNumber: 4,
      stageTitle: 'Seasons & Transience',
      cueText: 'Reflect that weather changes constantly—storms gather, peak, and always clear. Whatever you feel right now is weather too, and it will pass.',
      reflectionCue: 'You are the calm sky, not the passing storm.',
      sensoryAnchor: 'Reframing & Acceptance',
    ),
  ],
};
