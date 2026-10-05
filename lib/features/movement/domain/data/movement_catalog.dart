import '../models/movement_activity.dart';

/// Curated evidence-based movement activities matching the Firefly Activity Architecture.
abstract final class MovementCatalog {
  /// 1. Quick Full-Body Shakeout (Discharges somatic restlessness & adrenaline)
  static const quickShakeout = MovementActivity(
    id: 'act_quick_shakeout',
    title: 'Full Body Shakeout',
    description: '45 to 60 seconds of gentle physical shaking to release adrenaline and nervous restlessness.',
    type: MovementType.activePhysical,
    energyRequired: 3,
    durationSeconds: 45,
    cadenceBpm: 90,
    sensoryAnchor: 'Notice the sensation of flicking water from your fingertips.',
    instructions: [
      'Stand up with soft, unlocked knees and relax your jaw.',
      'Begin shaking both hands gently, flicking away tension.',
      'Let the loose motion ripple through your wrists, elbows, and shoulders.',
      'Allow your whole body to gently bounce and loosen for the remaining seconds.',
    ],
  );

  /// 2. Wall Push-Ups (Grounding joint proprioception)
  static const wallPushups = MovementActivity(
    id: 'act_wall_pushups',
    title: 'Wall Push-Ups',
    description: 'Controlled, steady push against a firm wall to provide calming proprioceptive joint input.',
    type: MovementType.activePhysical,
    energyRequired: 3,
    durationSeconds: 120,
    cadenceBpm: 40,
    sensoryAnchor: 'Feel the solid, unwavering resistance of the wall through your palms.',
    instructions: [
      'Stand about an arm\'s length from a solid wall with feet flat.',
      'Place your palms flat against the wall at shoulder width and height.',
      'Inhale slowly as you bend your elbows and bring your chest near the wall.',
      'Exhale smoothly as you push firmly back to starting position without locking joints.',
    ],
  );

  /// 3. Grounded 5-Minute Stroll (Intentional pacing & vestibular grounding)
  static const groundedStroll = MovementActivity(
    id: 'act_grounded_stroll',
    title: 'Grounded 5-Minute Stroll',
    description: 'Slow, intentional walking focusing on heel-to-toe foot placement and natural breath rhythm.',
    type: MovementType.activePhysical,
    energyRequired: 2,
    durationSeconds: 300,
    cadenceBpm: 60,
    sensoryAnchor: 'Feel the solid contact between your shoe sole and the ground beneath you.',
    instructions: [
      'Begin walking at a slow, unhurried, natural pace.',
      'Focus attention on your feet: heel strikes first, rolls forward, toes push gently.',
      'Let your gaze rest softly slightly ahead, without straining.',
      'If your thoughts drift, gently bring attention back to the sensation of each step.',
    ],
  );

  /// 4. Gentle Shoulder Rolls (Upper cervical & trapezius release)
  static const shoulderRolls = MovementActivity(
    id: 'act_shoulder_rolls',
    title: 'Gentle Shoulder Rolls',
    description: 'Slow circular rotations of the shoulder blades to loosen chest and upper cervical spine.',
    type: MovementType.somaticRelease,
    energyRequired: 1,
    durationSeconds: 120,
    cadenceBpm: 30,
    sensoryAnchor: 'Notice the widening space across your collarbones and upper back.',
    instructions: [
      'Sit or stand tall with arms resting loosely at your sides.',
      'Slowly roll both shoulders forward, upward toward your ears.',
      'Gently sweep them backward, drawing shoulder blades together, then drop them down.',
      'Repeat 5 times backward, then reverse and perform 5 gentle circles forward.',
    ],
  );

  /// 5. March in Place (Rhythmic bilateral activation)
  static const marchInPlace = MovementActivity(
    id: 'act_march_in_place',
    title: 'March in Place',
    description: 'Rhythmic, alternating leg lifting to activate circulation and bilateral nervous coordination.',
    type: MovementType.activePhysical,
    energyRequired: 3,
    durationSeconds: 90,
    cadenceBpm: 75,
    sensoryAnchor: 'Feel the alternating rhythm anchoring left and right sides of your body.',
    instructions: [
      'Stand comfortably with feet hip-width apart.',
      'Lift your right knee smoothly toward waist height, then place it softly down.',
      'Lift your left knee in an easy alternating rhythm.',
      'Swing your arms naturally to match your leg tempo.',
    ],
  );

  /// 6. Progressive Full-Body Stretch (Gentle somatic opening)
  static const progressiveStretch = MovementActivity(
    id: 'act_progressive_stretch',
    title: 'Progressive Stretch',
    description: 'Gentle 3-minute sequence opening the neck, side body, hamstrings, and chest.',
    type: MovementType.somaticRelease,
    energyRequired: 2,
    durationSeconds: 180,
    cadenceBpm: 20,
    sensoryAnchor: 'Notice the feeling of warmth expanding through each lengthened muscle.',
    instructions: [
      'Tilt right ear gently toward right shoulder for 15s, then switch to left.',
      'Reach both arms overhead, clasp fingers, and stretch gently toward the sky.',
      'Bend softly to the right for 15s, return center, then bend gently to the left.',
      'Lower arms, place hands on hips, and take two deep, calming breaths.',
    ],
  );

  /// 7. Micro Jaw & Neck Release (Targeted de-escalation)
  static const jawNeckRelease = MovementActivity(
    id: 'act_jaw_neck_release',
    title: 'Jaw & Neck Release',
    description: 'Targeted release of the temporomandibular joint and suboccipital muscles.',
    type: MovementType.somaticRelease,
    energyRequired: 1,
    durationSeconds: 90,
    sensoryAnchor: 'Feel the release of pressure behind your ears and around your lips.',
    instructions: [
      'Let your lips touch softly, but allow your upper and lower teeth to separate.',
      'Rest the tip of your tongue gently behind your front upper teeth.',
      'Drop your chin slightly downward toward your chest to lengthen the back of the neck.',
      'Breathe smoothly, letting your jaw hang completely slack.',
    ],
  );

  /// 8. Routine: Sip of Water
  static const drinkWater = MovementActivity(
    id: 'act_tiny_drink_water',
    title: 'Take a Slow Sip of Water',
    description: 'A physical hydration anchor that interrupts sympathetic autonomic arousal.',
    type: MovementType.routineAction,
    energyRequired: 1,
    durationSeconds: 60,
    sensoryAnchor: 'Notice the cool sensation of water as it reaches your mouth and throat.',
    instructions: [
      'Pour or reach for a glass of cool or room-temperature water.',
      'Hold the glass with both hands, noticing the temperature on your skin.',
      'Take one slow, deliberate sip. Pause and swallow intentionally.',
      'Take one more gentle breath before moving on.',
    ],
  );

  /// 9. Routine: Open Curtains or Window
  static const openCurtains = MovementActivity(
    id: 'act_tiny_open_curtains',
    title: 'Open a Window or Curtain',
    description: 'Expand physical environment and invite fresh airflow and natural daylight.',
    type: MovementType.routineAction,
    energyRequired: 1,
    durationSeconds: 60,
    sensoryAnchor: 'Feel the change in light and temperature on your face.',
    instructions: [
      'Walk over to the nearest window or curtain.',
      'Draw the curtains open or unlock the latch to let fresh air circulate.',
      'Pause for 10 seconds to look outward into the distance.',
    ],
  );

  /// 10. Routine: Cool Water Splash
  static const washFace = MovementActivity(
    id: 'act_tiny_wash_face',
    title: 'Cool Water Splash',
    description: 'Stimulate the mammalian dive reflex to trigger a rapid drop in elevated heart rate.',
    type: MovementType.routineAction,
    energyRequired: 2,
    durationSeconds: 90,
    sensoryAnchor: 'Notice the immediate cooling sensation across your forehead and cheeks.',
    instructions: [
      'Turn on the cold water tap and let it run over your hands.',
      'Cup cold water and gently splash it across your face 2 or 3 times.',
      'Pat dry gently with a clean towel and take one relaxed exhale.',
    ],
  );

  /// Complete list of all curated movement activities.
  static const all = [
    quickShakeout,
    wallPushups,
    groundedStroll,
    shoulderRolls,
    marchInPlace,
    progressiveStretch,
    jawNeckRelease,
    drinkWater,
    openCurtains,
    washFace,
  ];

  /// Find activity by id or mode keyword.
  static MovementActivity findByIdOrMode(String? idOrMode) {
    if (idOrMode == null || idOrMode.isEmpty) return quickShakeout;

    final query = idOrMode.toLowerCase().trim();
    for (final act in all) {
      if (act.id.toLowerCase() == query) return act;
    }

    // Match by mode keywords
    switch (query) {
      case 'shakeout':
        return quickShakeout;
      case 'wallpushups':
      case 'wall_pushups':
        return wallPushups;
      case 'stroll':
      case 'walk':
      case 'walking':
        return groundedStroll;
      case 'shoulderrolls':
      case 'shoulder_rolls':
      case 'shoulders':
        return shoulderRolls;
      case 'marching':
      case 'march':
        return marchInPlace;
      case 'stretch':
      case 'progressive_stretch':
        return progressiveStretch;
      case 'jaw':
      case 'neck':
        return jawNeckRelease;
      case 'water':
      case 'drink':
        return drinkWater;
      case 'curtains':
      case 'window':
        return openCurtains;
      case 'face':
      case 'splash':
        return washFace;
      default:
        return quickShakeout;
    }
  }

  /// Filter activities by MovementType
  static List<MovementActivity> byType(MovementType type) {
    return all.where((a) => a.type == type).toList(growable: false);
  }
}
