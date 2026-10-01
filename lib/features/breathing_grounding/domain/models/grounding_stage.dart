import 'package:flutter/material.dart';

/// The 5 sensory modalities of the 5-4-3-2-1 clinical grounding technique.
enum GroundingSense {
  see,
  touch,
  hear,
  smell,
  taste,
}

/// Represents a single stage in the 5-4-3-2-1 grounding exercise.
class GroundingStage {
  final GroundingSense sense;
  final int targetCount;
  final String title;
  final String subtitle;
  final String instruction;
  final List<String> prompts;
  final IconData icon;

  const GroundingStage({
    required this.sense,
    required this.targetCount,
    required this.title,
    required this.subtitle,
    required this.instruction,
    required this.prompts,
    required this.icon,
  });

  /// The standard sequence of 5 sensory stages.
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
      icon: Icons.visibility_outlined,
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
      icon: Icons.touch_app_outlined,
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
      icon: Icons.hearing_outlined,
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
      icon: Icons.air_outlined,
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
      icon: Icons.water_drop_outlined,
    ),
  ];
}
