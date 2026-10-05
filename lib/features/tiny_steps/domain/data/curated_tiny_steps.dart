import '../models/tiny_step.dart';

/// Offline catalog of evidence-based behavioural activation micro-actions.
///
/// Designed to reduce cognitive friction and interrupt depression-inertia / anxiety paralysis
/// without requiring internet connectivity or high executive function.
abstract final class TinyStepsCatalog {
  static const List<TinyStep> allSteps = [
    // --- Very Low Energy (Levels 1 - 2) ---
    TinyStep(
      id: 'sip_water',
      title: 'Take a slow sip of water',
      description:
          'Notice the cool temperature and the sensation as you swallow.',
      category: TinyStepCategory.nourishment,
      minEnergyLevel: 1,
      maxEnergyLevel: 2,
      durationMinutes: 1,
    ),
    TinyStep(
      id: 'unclench_jaw',
      title: 'Unclench jaw & drop shoulders',
      description: 'Let your tongue rest away from the roof of your mouth and exhale gently.',
      category: TinyStepCategory.physical,
      minEnergyLevel: 1,
      maxEnergyLevel: 2,
      durationMinutes: 1,
    ),
    TinyStep(
      id: 'look_window',
      title: 'Look out a window for 30s',
      description:
          'Find the farthest visible cloud or tree and rest your gaze there.',
      category: TinyStepCategory.sensory,
      minEnergyLevel: 1,
      maxEnergyLevel: 2,
      durationMinutes: 1,
    ),
    TinyStep(
      id: 'feel_feet',
      title: 'Feel your feet against the floor',
      description:
          'Notice the solid pressure and contact points grounding your body.',
      category: TinyStepCategory.sensory,
      minEnergyLevel: 1,
      maxEnergyLevel: 2,
      durationMinutes: 1,
    ),
    TinyStep(
      id: 'open_palms',
      title: 'Rest both hands open on your lap',
      description:
          'Uncurl your fingers completely and let go of any holding tension.',
      category: TinyStepCategory.physical,
      minEnergyLevel: 1,
      maxEnergyLevel: 2,
      durationMinutes: 1,
    ),
    TinyStep(
      id: 'touch_texture',
      title: 'Notice the texture of fabric',
      description: 'Rub your sleeve or blanket between fingertips and attend to the sensation.',
      category: TinyStepCategory.sensory,
      minEnergyLevel: 1,
      maxEnergyLevel: 3,
      durationMinutes: 1,
    ),
    TinyStep(
      id: 'warm_mug',
      title: 'Hold a warm cup or water glass',
      description: 'Feel the gentle warmth radiating directly into your palms.',
      category: TinyStepCategory.nourishment,
      minEnergyLevel: 1,
      maxEnergyLevel: 3,
      durationMinutes: 2,
    ),
    TinyStep(
      id: 'close_eyes_three_breaths',
      title: 'Three quiet exhales with eyes closed',
      description: 'Inhale gently through your nose and let out a soft sigh with each release.',
      category: TinyStepCategory.physical,
      minEnergyLevel: 1,
      maxEnergyLevel: 3,
      durationMinutes: 1,
    ),

    // --- Moderate Energy (Levels 2 - 4, centered around Level 3) ---
    TinyStep(
      id: 'wash_face',
      title: 'Wash face with cool water',
      description:
          'Splash refreshing cool water over your forehead and cheeks.',
      category: TinyStepCategory.sensory,
      minEnergyLevel: 2,
      maxEnergyLevel: 4,
      durationMinutes: 2,
    ),
    TinyStep(
      id: 'stretch_arms',
      title: 'Stretch your arms overhead',
      description: 'Reach upward toward the ceiling, hold for 5 seconds, and release down.',
      category: TinyStepCategory.physical,
      minEnergyLevel: 2,
      maxEnergyLevel: 4,
      durationMinutes: 1,
    ),
    TinyStep(
      id: 'step_outside_air',
      title: 'Step outside for fresh air',
      description:
          'Open a door or step onto the doorstep and take two deep breaths.',
      category: TinyStepCategory.environment,
      minEnergyLevel: 2,
      maxEnergyLevel: 4,
      durationMinutes: 2,
    ),
    TinyStep(
      id: 'open_blinds',
      title: 'Open curtains or blinds',
      description:
          'Let natural daylight into the room to reset your circadian rhythm.',
      category: TinyStepCategory.environment,
      minEnergyLevel: 2,
      maxEnergyLevel: 4,
      durationMinutes: 1,
    ),
    TinyStep(
      id: 'gentle_neck_rolls',
      title: 'Do three gentle neck rolls',
      description: 'Slowly circle your head clockwise, then counter-clockwise without straining.',
      category: TinyStepCategory.physical,
      minEnergyLevel: 2,
      maxEnergyLevel: 4,
      durationMinutes: 1,
    ),
    TinyStep(
      id: 'listen_three_sounds',
      title: 'Identify 3 distinct ambient sounds',
      description: 'Pause and listen carefully: one near, one in the room, one in the distance.',
      category: TinyStepCategory.sensory,
      minEnergyLevel: 2,
      maxEnergyLevel: 4,
      durationMinutes: 1,
    ),
    TinyStep(
      id: 'eat_one_snack',
      title: 'Eat a small mindful bite',
      description:
          'Take a single piece of fruit, cracker, or nut and slowly savor it.',
      category: TinyStepCategory.nourishment,
      minEnergyLevel: 2,
      maxEnergyLevel: 4,
      durationMinutes: 2,
    ),
    TinyStep(
      id: 'wash_hands_warm',
      title: 'Rinse hands with warm water & soap',
      description:
          'Lather gently, noticing the warmth and clean scent on your hands.',
      category: TinyStepCategory.sensory,
      minEnergyLevel: 2,
      maxEnergyLevel: 4,
      durationMinutes: 1,
    ),

    // --- Higher Energy / Restless Momentum (Levels 3 - 5) ---
    TinyStep(
      id: 'tidy_one_surface',
      title: 'Clear one small surface',
      description: 'Pick up clutter from just one small coffee table, desk corner, or nightstand.',
      category: TinyStepCategory.environment,
      minEnergyLevel: 3,
      maxEnergyLevel: 5,
      durationMinutes: 2,
    ),
    TinyStep(
      id: 'put_away_three',
      title: 'Put away three misplaced items',
      description:
          'Return three displaced objects back to where they usually live.',
      category: TinyStepCategory.environment,
      minEnergyLevel: 3,
      maxEnergyLevel: 5,
      durationMinutes: 2,
    ),
    TinyStep(
      id: 'shake_out_tension',
      title: 'Shake out your hands and arms',
      description: 'Vigorously shake out physical tension from your wrists, arms, and shoulders.',
      category: TinyStepCategory.physical,
      minEnergyLevel: 3,
      maxEnergyLevel: 5,
      durationMinutes: 1,
    ),
    TinyStep(
      id: 'straighten_bed_cushion',
      title: 'Straighten one pillow or blanket',
      description: 'Smooth out the cover on your bed or couch to create an island of calm.',
      category: TinyStepCategory.environment,
      minEnergyLevel: 3,
      maxEnergyLevel: 5,
      durationMinutes: 1,
    ),
    TinyStep(
      id: 'ice_water_glass',
      title: 'Pour a fresh glass of cold water',
      description:
          'Fill a clean glass with water and drink half with calm presence.',
      category: TinyStepCategory.nourishment,
      minEnergyLevel: 3,
      maxEnergyLevel: 5,
      durationMinutes: 2,
    ),
    TinyStep(
      id: 'step_balcony_porch',
      title: 'Step onto the balcony or porch',
      description: 'Stand outdoors for a moment and look at the sky or trees.',
      category: TinyStepCategory.environment,
      minEnergyLevel: 3,
      maxEnergyLevel: 5,
      durationMinutes: 2,
    ),
    TinyStep(
      id: 'standing_torso_twist',
      title: 'Standing gentle torso twists',
      description:
          'Stand with feet shoulder-width and swing arms gently side to side.',
      category: TinyStepCategory.physical,
      minEnergyLevel: 4,
      maxEnergyLevel: 5,
      durationMinutes: 1,
    ),
    TinyStep(
      id: 'wipe_one_table',
      title: 'Wipe down one tabletop',
      description:
          'Take a damp cloth and make one clean, clear spot on a table.',
      category: TinyStepCategory.environment,
      minEnergyLevel: 4,
      maxEnergyLevel: 5,
      durationMinutes: 2,
    ),
  ];

  /// Filter actions suitable for a given energy level (1 - 5).
  static List<TinyStep> getStepsForEnergy(int energyLevel) {
    final clampedEnergy = energyLevel.clamp(1, 5);
    return allSteps.where((step) => step.matchesEnergy(clampedEnergy)).toList();
  }

  /// Filter actions by category.
  static List<TinyStep> getStepsByCategory(TinyStepCategory category) {
    return allSteps.where((step) => step.category == category).toList();
  }

  /// Lookup a step by its unique id.
  static TinyStep? getStepById(String id) {
    try {
      return allSteps.firstWhere((step) => step.id == id);
    } catch (_) {
      return null;
    }
  }
}
