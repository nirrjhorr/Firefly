/// Lightweight icon representation decoupled from Flutter UI framework.
class GroundingIcon {
  final int codePoint;
  final String fontFamily;

  const GroundingIcon(this.codePoint, {this.fontFamily = 'MaterialIcons'});

  static const visibility = GroundingIcon(0xe6bd);
  static const touchApp = GroundingIcon(0xe671);
  static const hearing = GroundingIcon(0xe30d);
  static const air = GroundingIcon(0xe06e);
  static const waterDrop = GroundingIcon(0xe6c2);
  static const texture = GroundingIcon(0xe662);
  static const grain = GroundingIcon(0xe2e2);
  static const surroundSound = GroundingIcon(0xe63f);
  static const graphicEq = GroundingIcon(0xe2e6);
  static const eco = GroundingIcon(0xe212);
  static const wbSunny = GroundingIcon(0xe6d4);
  static const palette = GroundingIcon(0xe463);
  static const seat = GroundingIcon(0xe072);
  static const accessibility = GroundingIcon(0xe043);
  static const spa = GroundingIcon(0xe5e1);
  static const autoAwesome = GroundingIcon(0xe08f);
}

/// The sensory modalities of grounding techniques.
enum GroundingSense {
  see,
  touch,
  hear,
  smell,
  taste,
  proprioception,
}

/// The 5 clinically validated grounding modes available in Firefly.
enum GroundingMode {
  fiveSenses,
  textureHunt,
  soundHunt,
  colourSearch,
  feetOnFloor;

  String get label {
    switch (this) {
      case GroundingMode.fiveSenses:
        return '5-4-3-2-1 Senses';
      case GroundingMode.textureHunt:
        return 'Texture Hunt';
      case GroundingMode.soundHunt:
        return 'Sound Hunt';
      case GroundingMode.colourSearch:
        return 'Colour Search';
      case GroundingMode.feetOnFloor:
        return 'Feet on Floor';
    }
  }

  String get description {
    switch (this) {
      case GroundingMode.fiveSenses:
        return 'Full sensory ladder engaging all five external senses';
      case GroundingMode.textureHunt:
        return 'Tactile exploration of 3 physical surfaces around you';
      case GroundingMode.soundHunt:
        return 'Acoustic orienting from nearby sounds to distant ambient audio';
      case GroundingMode.colourSearch:
        return 'Visual scanning to spot 4 gentle grounding tones in the room';
      case GroundingMode.feetOnFloor:
        return 'Proprioceptive body awareness of gravity and firm support';
    }
  }

  GroundingIcon get icon {
    switch (this) {
      case GroundingMode.fiveSenses:
        return GroundingIcon.autoAwesome;
      case GroundingMode.textureHunt:
        return GroundingIcon.texture;
      case GroundingMode.soundHunt:
        return GroundingIcon.hearing;
      case GroundingMode.colourSearch:
        return GroundingIcon.palette;
      case GroundingMode.feetOnFloor:
        return GroundingIcon.accessibility;
    }
  }

  List<GroundingStage> get stages {
    switch (this) {
      case GroundingMode.fiveSenses:
        return GroundingStage.standardStages;
      case GroundingMode.textureHunt:
        return GroundingStage.textureHuntStages;
      case GroundingMode.soundHunt:
        return GroundingStage.soundHuntStages;
      case GroundingMode.colourSearch:
        return GroundingStage.colourSearchStages;
      case GroundingMode.feetOnFloor:
        return GroundingStage.feetOnFloorStages;
    }
  }

  static GroundingMode fromString(String? value) {
    if (value == null) return GroundingMode.fiveSenses;
    return GroundingMode.values.firstWhere(
      (m) => m.name.toLowerCase() == value.toLowerCase(),
      orElse: () => GroundingMode.fiveSenses,
    );
  }
}

/// Represents a single stage in any sensory grounding exercise.
class GroundingStage {
  final GroundingSense sense;
  final int targetCount;
  final String title;
  final String subtitle;
  final String instruction;
  final List<String> prompts;
  final GroundingIcon icon;

  const GroundingStage({
    required this.sense,
    required this.targetCount,
    required this.title,
    required this.subtitle,
    required this.instruction,
    required this.prompts,
    required this.icon,
  });

  /// The standard sequence of 5 sensory stages (5-4-3-2-1).
  static const List<GroundingStage> standardStages = [
    GroundingStage(
      sense: GroundingSense.see,
      targetCount: 5,
      title: '5 Things you can see',
      subtitle: 'Look around your environment',
      instruction:
          'Acknowledge 5 things you see around you. Notice shapes, shadows, colors, or small details.',
      prompts: [
        'A color or pattern',
        'A point of light or shadow',
        'An everyday object nearby',
        'A texture across the room',
        'Something small or overlooked',
      ],
      icon: GroundingIcon.visibility,
    ),
    GroundingStage(
      sense: GroundingSense.touch,
      targetCount: 4,
      title: '4 Things you can touch',
      subtitle: 'Notice physical sensations',
      instruction:
          'Notice 4 things you can feel physically. Ground yourself in your tactile contact with the world.',
      prompts: [
        'The surface under your feet or seat',
        'The fabric of your clothing',
        'The cool or warm air on your skin',
        'A texture under your fingertips',
      ],
      icon: GroundingIcon.touchApp,
    ),
    GroundingStage(
      sense: GroundingSense.hear,
      targetCount: 3,
      title: '3 Things you can hear',
      subtitle: 'Tune into background sounds',
      instruction:
          'Listen carefully. What are 3 sounds you can notice in the background or within yourself?',
      prompts: [
        'A distant ambient sound',
        'A nearby quiet hum or rustle',
        'Your own gentle, steady breath',
      ],
      icon: GroundingIcon.hearing,
    ),
    GroundingStage(
      sense: GroundingSense.smell,
      targetCount: 2,
      title: '2 Things you can smell',
      subtitle: 'Notice subtle scents',
      instruction:
          'Notice 2 scents in the air. If none are distinct, recall a comforting scent you love.',
      prompts: [
        'A subtle aroma in the room or air',
        'A scent on your skin, clothing, or memory',
      ],
      icon: GroundingIcon.air,
    ),
    GroundingStage(
      sense: GroundingSense.taste,
      targetCount: 1,
      title: '1 Thing you can taste',
      subtitle: 'Focus on oral sensation',
      instruction:
          'Notice 1 taste in your mouth, or take a gentle sip of cool water and notice how it feels.',
      prompts: [
        'A lingering taste, cool water, or neutral presence',
      ],
      icon: GroundingIcon.waterDrop,
    ),
  ];

  /// Texture Hunt: 3 distinct physical textures.
  static const List<GroundingStage> textureHuntStages = [
    GroundingStage(
      sense: GroundingSense.touch,
      targetCount: 1,
      title: 'A smooth or polished surface',
      subtitle: 'Cool glass, polished wood, or sleek screen',
      instruction:
          'Touch a smooth surface nearby. Notice its temperature, its sleekness, and where your fingertips meet the boundary.',
      prompts: [
        'Notice if it feels cool, slick, or glass-like under your hand',
      ],
      icon: GroundingIcon.texture,
    ),
    GroundingStage(
      sense: GroundingSense.touch,
      targetCount: 1,
      title: 'A rough or textured surface',
      subtitle: 'Wood grain, stone, paper, or ridges',
      instruction:
          'Find a surface with grain, ridges, or texture. Move your fingers slowly across it and notice the uneven detail.',
      prompts: [
        'Notice the ridges, subtle friction, or tactile variety',
      ],
      icon: GroundingIcon.grain,
    ),
    GroundingStage(
      sense: GroundingSense.touch,
      targetCount: 1,
      title: 'A soft or yielding fabric',
      subtitle: 'Blanket, cotton sleeve, or cushion',
      instruction:
          'Gently hold or press a soft fabric. Notice the comfort, yielding cushion, and warmth of the fibers.',
      prompts: [
        'Notice the yielding softness and comforting give of the material',
      ],
      icon: GroundingIcon.touchApp,
    ),
  ];

  /// Sound Hunt: 3 acoustic orienting stages.
  static const List<GroundingStage> soundHuntStages = [
    GroundingStage(
      sense: GroundingSense.hear,
      targetCount: 1,
      title: 'The nearest immediate sound',
      subtitle: 'Right next to you or inside the room',
      instruction:
          'Listen for the sound closest to your body: your breath, the rustle of clothes, or the soft hum of your phone.',
      prompts: [
        'Notice how close and personal this sound is in this very second',
      ],
      icon: GroundingIcon.hearing,
    ),
    GroundingStage(
      sense: GroundingSense.hear,
      targetCount: 1,
      title: 'A distant or background sound',
      subtitle: 'Outside the room or through the walls',
      instruction:
          'Cast your awareness outward. Can you hear distant wind, a bird, traffic far away, or the hum of the building?',
      prompts: [
        'Notice how sounds come and go in the distance while you remain here',
      ],
      icon: GroundingIcon.surroundSound,
    ),
    GroundingStage(
      sense: GroundingSense.hear,
      targetCount: 1,
      title: 'A steady or ambient tone',
      subtitle: 'A continuous, unchanging presence',
      instruction:
          'Notice any continuous tone in the air: a fan, air flowing, or the quiet floor of silence itself.',
      prompts: [
        'Let your hearing rest in this continuous background presence',
      ],
      icon: GroundingIcon.graphicEq,
    ),
  ];

  /// Colour Search: 4 visual scanning stages.
  static const List<GroundingStage> colourSearchStages = [
    GroundingStage(
      sense: GroundingSense.see,
      targetCount: 1,
      title: 'Find something green or botanical',
      subtitle: 'A plant, clothing item, book spine, or natural tint',
      instruction:
          'Let your eyes wander until they rest on a green or earthy tone. Notice its exact shade — olive, moss, sage, or emerald.',
      prompts: [
        'Notice the soothing organic depth of this green item',
      ],
      icon: GroundingIcon.eco,
    ),
    GroundingStage(
      sense: GroundingSense.see,
      targetCount: 1,
      title: 'Find something blue or cool-toned',
      subtitle: 'Sky outside, fabric, ceramic, or ink',
      instruction:
          'Look around for a cool blue tone. Notice how the cool color reflects the ambient light in the room.',
      prompts: [
        'Rest your eyes on this calming blue shade for a breath',
      ],
      icon: GroundingIcon.waterDrop,
    ),
    GroundingStage(
      sense: GroundingSense.see,
      targetCount: 1,
      title: 'Find something warm or golden',
      subtitle: 'Wood, amber, honey, sunlight, or brass',
      instruction:
          'Scan for something carrying warmth — gold, yellow, amber, or warm wood. Notice the light catching it.',
      prompts: [
        'Notice the warmth and grounding presence of this color',
      ],
      icon: GroundingIcon.wbSunny,
    ),
    GroundingStage(
      sense: GroundingSense.see,
      targetCount: 1,
      title: 'Find a neutral, grounding tone',
      subtitle: 'Stone, gray, dark slate, linen, or earth',
      instruction:
          'Find a neutral shade holding the room together. A tabletop, shadow, wall, or floor.',
      prompts: [
        'Acknowledge this neutral presence anchoring your surroundings',
      ],
      icon: GroundingIcon.palette,
    ),
  ];

  /// Feet on Floor: 3 proprioceptive grounding stages.
  static const List<GroundingStage> feetOnFloorStages = [
    GroundingStage(
      sense: GroundingSense.proprioception,
      targetCount: 1,
      title: 'Contact with the floor or seat',
      subtitle: 'Where your body meets physical support',
      instruction:
          'Bring attention to the soles of your feet resting on the floor (or your body resting in your chair). Feel the contact points.',
      prompts: [
        'Notice the firmness, pressure, and exact boundary of contact',
      ],
      icon: GroundingIcon.seat,
    ),
    GroundingStage(
      sense: GroundingSense.proprioception,
      targetCount: 1,
      title: 'Weight, warmth, and texture',
      subtitle: 'Socks, shoes, floorboards, or carpet',
      instruction:
          'Notice sensations under your feet or seat: warmth, coolness, texture of socks or flooring. Press down gently for 3 seconds, then release.',
      prompts: [
        'Feel the resistance of the solid surface pushing back against you',
      ],
      icon: GroundingIcon.touchApp,
    ),
    GroundingStage(
      sense: GroundingSense.proprioception,
      targetCount: 1,
      title: 'Trusting gravity and stability',
      subtitle: 'You do not have to hold yourself up right now',
      instruction:
          'Take a slow breath out and allow your full weight to settle into the floor. The earth is solid beneath you and completely holds you.',
      prompts: [
        'Let your shoulders drop and trust the firm support beneath you',
      ],
      icon: GroundingIcon.spa,
    ),
  ];
}
