/// Evidence-based somatic visualization and body centering modes in Firefly (Story 12.2).
/// Down-regulates autonomic hyper-arousal and releases held somatic tension.
enum SomaticExerciseMode {
  /// Gravitational settling: releasing skeletal and postural tension into the support beneath.
  heavyBody,

  /// Autogenic peripheral vasodilation: visualizing warm blood flow into hands and fingers.
  warmHands,

  /// Proprioceptive & vestibular grounding: embodying the rooted stillness of a mountain.
  mountainPosture,

  /// Fast 3-step physical anchor: Stop, Drop attention to physical contact, Breathe & soften.
  mindfulPause;

  String get title {
    switch (this) {
      case SomaticExerciseMode.heavyBody:
        return 'Heavy Body Gravity Settling';
      case SomaticExerciseMode.warmHands:
        return 'Warm Hands Peripheral Dilation';
      case SomaticExerciseMode.mountainPosture:
        return 'Mountain Posture Stability';
      case SomaticExerciseMode.mindfulPause:
        return 'Mindful Pause & Anchor';
    }
  }

  String get subtitle {
    switch (this) {
      case SomaticExerciseMode.heavyBody:
        return 'Yielding postural tension into the ground';
      case SomaticExerciseMode.warmHands:
        return 'Autogenic calming via blood flow visualization';
      case SomaticExerciseMode.mountainPosture:
        return 'Embodying rooted, unshakable physical stillness';
      case SomaticExerciseMode.mindfulPause:
        return 'Quick 3-step physical reset during high arousal';
    }
  }

  String get description {
    switch (this) {
      case SomaticExerciseMode.heavyBody:
        return 'Guide your awareness downward, allowing gravity to carry the weight of your jaw, shoulders, and limbs so your muscles can release defensive vigilance.';
      case SomaticExerciseMode.warmHands:
        return 'Focus gently on the nerve endings in your palms and fingertips, imagining soothing warmth to stimulate peripheral vasodilation and parasympathetic tone.';
      case SomaticExerciseMode.mountainPosture:
        return 'Somatic imagery aligning your spine and base with the unwavering permanence of a mountain, weathering transient thoughts and feelings without moving.';
      case SomaticExerciseMode.mindfulPause:
        return 'A rapid somatic circuit to arrest fight-or-flight escalation: pause action, ground your feet or hands, and take one soft, unforced breath.';
    }
  }

  String get scientificMechanism {
    switch (this) {
      case SomaticExerciseMode.heavyBody:
        return 'Reduces tonic muscular guarding and somatic hyper-vigilance through somatic proprioception.';
      case SomaticExerciseMode.warmHands:
        return 'Autogenic thermal training activates peripheral vasodilation, reducing sympathetic tone.';
      case SomaticExerciseMode.mountainPosture:
        return 'Proprioceptive posture stabilization grounds vestibular balance and distress tolerance.';
      case SomaticExerciseMode.mindfulPause:
        return 'Brief interoceptive interrupt disrupts cognitive rumination and autonomic arousal.';
    }
  }

  String get iconKey {
    switch (this) {
      case SomaticExerciseMode.heavyBody:
        return 'arrow_downward';
      case SomaticExerciseMode.warmHands:
        return 'front_hand';
      case SomaticExerciseMode.mountainPosture:
        return 'landscape';
      case SomaticExerciseMode.mindfulPause:
        return 'pause_circle';
    }
  }

  int get suggestedDurationSeconds {
    switch (this) {
      case SomaticExerciseMode.heavyBody:
        return 180;
      case SomaticExerciseMode.warmHands:
        return 180;
      case SomaticExerciseMode.mountainPosture:
        return 210;
      case SomaticExerciseMode.mindfulPause:
        return 90;
    }
  }

  static SomaticExerciseMode fromString(String value) {
    final normalized = value.trim().toLowerCase();
    for (final mode in SomaticExerciseMode.values) {
      if (mode.name.toLowerCase() == normalized) {
        return mode;
      }
    }
    return SomaticExerciseMode.heavyBody;
  }
}
