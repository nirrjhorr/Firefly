import 'somatic_exercise_mode.dart';

/// Single guided stage entity within a somatic body centering exercise.
class SomaticPrompt {
  const SomaticPrompt({
    required this.id,
    required this.mode,
    required this.stageNumber,
    required this.stageTitle,
    required this.guidanceText,
    required this.sensationFocus,
    required this.breathingAnchor,
    this.durationSeconds = 45,
  });

  final String id;
  final SomaticExerciseMode mode;
  final int stageNumber;
  final String stageTitle;
  final String guidanceText;
  final String sensationFocus;
  final String breathingAnchor;
  final int durationSeconds;
}

/// Curated 100% offline somatic visualization library (Story 12.2).
/// Contains clinically informed, low-arousal, non-judgmental guidance stages.
final Map<SomaticExerciseMode, List<SomaticPrompt>> kOfflineSomaticPrompts = {
  SomaticExerciseMode.heavyBody: [
    const SomaticPrompt(
      id: 'heavy_1_support',
      mode: SomaticExerciseMode.heavyBody,
      stageNumber: 1,
      stageTitle: 'Finding the Support Surface',
      guidanceText:
          'Notice wherever your body meets the chair, bed, or floor. Feel how completely solid that surface is underneath you—it is holding you up without any effort on your part.',
      sensationFocus: 'Points of contact along feet, thighs, back, or heels',
      breathingAnchor: 'As you exhale, let yourself sink 1 millimeter deeper into the surface.',
      durationSeconds: 45,
    ),
    const SomaticPrompt(
      id: 'heavy_2_jaw_shoulders',
      mode: SomaticExerciseMode.heavyBody,
      stageNumber: 2,
      stageTitle: 'Releasing Facial & Neck Guarding',
      guidanceText:
          'Gently unclench your back teeth. Let the tongue rest softly on the floor of your mouth. Notice your shoulders—allow them to drop half an inch away from your ears.',
      sensationFocus: 'Slackness in the jaw, unweighted lightness across the neck',
      breathingAnchor: 'Exhale as if sighing silently through your collarbones.',
      durationSeconds: 45,
    ),
    const SomaticPrompt(
      id: 'heavy_3_limbs_gravity',
      mode: SomaticExerciseMode.heavyBody,
      stageNumber: 3,
      stageTitle: 'Surrendering to Gravity',
      guidanceText:
          'Imagine gravity as a warm, comforting downward pull. Your arms and legs feel heavy, like wet sand or warm stones resting in sunshine. There is nothing to hold up right now.',
      sensationFocus: 'Pleasant, heavy downward weight in your forearms and calves',
      breathingAnchor: 'Breathe out slowly; give away any remaining muscular bracing.',
      durationSeconds: 45,
    ),
    const SomaticPrompt(
      id: 'heavy_4_grounded_rest',
      mode: SomaticExerciseMode.heavyBody,
      stageNumber: 4,
      stageTitle: 'Resting in Settled Weight',
      guidanceText:
          'Rest in this quiet, grounded heaviness for a few unhurried moments. You do not need to do anything, fix anything, or protect against anything right here.',
      sensationFocus: 'Deep stillness, calm downward equilibrium',
      breathingAnchor: 'Rest in your natural breath cadence; you are safe and supported.',
      durationSeconds: 45,
    ),
  ],

  SomaticExerciseMode.warmHands: [
    const SomaticPrompt(
      id: 'warm_1_attention',
      mode: SomaticExerciseMode.warmHands,
      stageNumber: 1,
      stageTitle: 'Centering Awareness in the Palms',
      guidanceText:
          'Turn your attention inward toward both hands. Whether they are resting on your lap or beside you, simply notice what sensations are present right now—temperature, pulse, or resting pressure.',
      sensationFocus: 'Tingling, temperature, or tactile texture against your skin',
      breathingAnchor: 'With each gentle breath, bring your mind closer to your fingertips.',
      durationSeconds: 45,
    ),
    const SomaticPrompt(
      id: 'warm_2_radiance',
      mode: SomaticExerciseMode.warmHands,
      stageNumber: 2,
      stageTitle: 'Visualizing Gentle Warmth',
      guidanceText:
          'Picture holding a smooth ceramic cup of warm tea, or resting your palms under gentle afternoon sunlight. Imagine that soothing warmth beginning to soak into the center of your palms.',
      sensationFocus: 'Subtle radiating warmth in the hollow of each palm',
      breathingAnchor: 'Exhale smoothly; let warmth slowly expand across your knuckles.',
      durationSeconds: 45,
    ),
    const SomaticPrompt(
      id: 'warm_3_dilation',
      mode: SomaticExerciseMode.warmHands,
      stageNumber: 3,
      stageTitle: 'Peripheral Blood Flow Dilation',
      guidanceText:
          'Silently affirm: "My hands are heavy and warm." Imagine tiny blood vessels gently opening up, easing your pulse and inviting calm circulation to your fingertips.',
      sensationFocus: 'Mild throbbing pulse, softness in hand muscles, relaxing wrists',
      breathingAnchor: 'Breathe in ease; breathe out sympathetic tension.',
      durationSeconds: 45,
    ),
    const SomaticPrompt(
      id: 'warm_4_calm_circulation',
      mode: SomaticExerciseMode.warmHands,
      stageNumber: 4,
      stageTitle: 'Full Body Parasympathetic Settling',
      guidanceText:
          'Let that soothing warmth from your hands travel softly up your arms, relaxing your chest and easing your heart rate into a steady, tranquil pace.',
      sensationFocus: 'Quiet chest, eased heart rhythm, relaxed shoulders',
      breathingAnchor: 'Notice how warm hands mirror a calm, settled nervous system.',
      durationSeconds: 45,
    ),
  ],

  SomaticExerciseMode.mountainPosture: [
    const SomaticPrompt(
      id: 'mountain_1_rooting',
      mode: SomaticExerciseMode.mountainPosture,
      stageNumber: 1,
      stageTitle: 'Rooting Your Base',
      guidanceText:
          'Whether sitting or standing, feel your base rooted firmly into the earth. Picture deep, ancient roots extending downward through the floor, anchoring you into bedrock.',
      sensationFocus: 'Firm contact, physical stability, wide unshakeable base',
      breathingAnchor: 'Inhale grounding from the earth; exhale feeling completely anchored.',
      durationSeconds: 45,
    ),
    const SomaticPrompt(
      id: 'mountain_2_alignment',
      mode: SomaticExerciseMode.mountainPosture,
      stageNumber: 2,
      stageTitle: 'The Aligned Ridge',
      guidanceText:
          'Let your spine lengthen gently upward like the majestic ridge of a mountain. Not rigid or forced, but naturally dignified, upright, and spacious.',
      sensationFocus: 'Spaciousness between vertebrae, open chest, relaxed neck',
      breathingAnchor: 'Inhale tall and steady; exhale maintaining effortless dignity.',
      durationSeconds: 45,
    ),
    const SomaticPrompt(
      id: 'mountain_3_weathering',
      mode: SomaticExerciseMode.mountainPosture,
      stageNumber: 3,
      stageTitle: 'Weathering Internal Storms',
      guidanceText:
          'A mountain experiences rain, raging wind, snow, and blazing sun—yet the core of the mountain remains still. Allow your thoughts and feelings to blow past like weather.',
      sensationFocus: 'Separation between transient feelings and your stable core',
      breathingAnchor: 'Watch worries swirl like clouds around your peak; you remain still.',
      durationSeconds: 45,
    ),
    const SomaticPrompt(
      id: 'mountain_4_permanence',
      mode: SomaticExerciseMode.mountainPosture,
      stageNumber: 4,
      stageTitle: 'Abiding in Stillness',
      guidanceText:
          'Rest in the knowledge that whatever comes your way today, you have this immovable, calm center to return to whenever you need it.',
      sensationFocus: 'Quiet confidence, grounded resilience, grounded breath',
      breathingAnchor: 'Rest in this unshakable posture for three slow, natural breaths.',
      durationSeconds: 45,
    ),
  ],

  SomaticExerciseMode.mindfulPause: [
    const SomaticPrompt(
      id: 'pause_1_stop',
      mode: SomaticExerciseMode.mindfulPause,
      stageNumber: 1,
      stageTitle: 'Stop & Acknowledge',
      guidanceText:
          'Press pause on whatever you were doing or thinking. You do not need to figure out your next step right this second. Simply acknowledge: "I am here, in this moment."',
      sensationFocus: 'Stopping physical momentum, releasing the urge to react',
      breathingAnchor: 'Take one deliberate, unhurried breath in through your nose.',
      durationSeconds: 30,
    ),
    const SomaticPrompt(
      id: 'pause_2_anchor',
      mode: SomaticExerciseMode.mindfulPause,
      stageNumber: 2,
      stageTitle: 'Drop Into Physical Contact',
      guidanceText:
          'Drop your attention straight down into your feet touching the floor or your hands resting on your lap. Feel that immediate, tangible physical sensation.',
      sensationFocus: 'Pressure of feet on ground, temperature of skin, tangible contact',
      breathingAnchor: 'Feel the anchor holding you firmly in physical reality.',
      durationSeconds: 30,
    ),
    const SomaticPrompt(
      id: 'pause_3_soften',
      mode: SomaticExerciseMode.mindfulPause,
      stageNumber: 3,
      stageTitle: 'Breathe & Soften Posture',
      guidanceText:
          'Take one slow, full breath out. As the air leaves your body, gently soften your stomach and unlock your knees or jaw. Carry this micro-calm into your next movement.',
      sensationFocus: 'Soft belly, relaxed jaw, gentle open awareness',
      breathingAnchor: 'A long, soft sigh out. You are ready to proceed at your own pace.',
      durationSeconds: 30,
    ),
  ],
};
