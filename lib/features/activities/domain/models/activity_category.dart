import 'regulation_group.dart';

/// The 16 canonical self-regulation activity categories from the Firefly Activity Architecture.
enum ActivityCategory {
  physical,
  respiration,
  sensoryGrounding,
  cognitiveGrounding,
  flow,
  labyrinth,
  mindfulness,
  pmr,
  emotionalExpression,
  behavioralActivation,
  nature,
  audio,
  sleep,
  social,
  creative,
  cognitiveDefusion;

  RegulationGroup get regulationGroup {
    switch (this) {
      case ActivityCategory.physical:
      case ActivityCategory.pmr:
      case ActivityCategory.behavioralActivation:
        return RegulationGroup.movement;
      case ActivityCategory.respiration:
        return RegulationGroup.respiration;
      case ActivityCategory.sensoryGrounding:
      case ActivityCategory.mindfulness:
      case ActivityCategory.nature:
        return RegulationGroup.grounding;
      case ActivityCategory.cognitiveGrounding:
      case ActivityCategory.flow:
      case ActivityCategory.labyrinth:
        return RegulationGroup.flow;
      case ActivityCategory.emotionalExpression:
      case ActivityCategory.cognitiveDefusion:
      case ActivityCategory.creative:
        return RegulationGroup.expression;
      case ActivityCategory.audio:
      case ActivityCategory.sleep:
      case ActivityCategory.social:
        return RegulationGroup.restAndSocial;
    }
  }

  String get displayName {
    switch (this) {
      case ActivityCategory.physical:
        return 'Physical Movement';
      case ActivityCategory.respiration:
        return 'Breathing & Respiration';
      case ActivityCategory.sensoryGrounding:
        return 'Sensory Grounding';
      case ActivityCategory.cognitiveGrounding:
        return 'Cognitive Grounding';
      case ActivityCategory.flow:
        return 'Flow & Focus';
      case ActivityCategory.labyrinth:
        return 'Labyrinth & Tracing';
      case ActivityCategory.mindfulness:
        return 'Mindfulness';
      case ActivityCategory.pmr:
        return 'Muscle Relaxation';
      case ActivityCategory.emotionalExpression:
        return 'Emotional Expression';
      case ActivityCategory.behavioralActivation:
        return 'Tiny Steps';
      case ActivityCategory.nature:
        return 'Nature & Environment';
      case ActivityCategory.audio:
        return 'Audio Sanctuary';
      case ActivityCategory.sleep:
        return 'Sleep & Wind-Down';
      case ActivityCategory.social:
        return 'Connection & Reaching Out';
      case ActivityCategory.creative:
        return 'Creative & Doodling';
      case ActivityCategory.cognitiveDefusion:
        return 'Thought Distance';
    }
  }

  String get iconKey {
    switch (this) {
      case ActivityCategory.physical:
        return 'figure.walk';
      case ActivityCategory.respiration:
        return 'wind';
      case ActivityCategory.sensoryGrounding:
        return 'hand.point.up.left';
      case ActivityCategory.cognitiveGrounding:
        return 'brain.head.profile';
      case ActivityCategory.flow:
        return 'sparkles';
      case ActivityCategory.labyrinth:
        return 'circle.hexagonpath';
      case ActivityCategory.mindfulness:
        return 'eye';
      case ActivityCategory.pmr:
        return 'figure.mind.and.body';
      case ActivityCategory.emotionalExpression:
        return 'pencil.and.outline';
      case ActivityCategory.behavioralActivation:
        return 'checklist';
      case ActivityCategory.nature:
        return 'leaf';
      case ActivityCategory.audio:
        return 'headphones';
      case ActivityCategory.sleep:
        return 'moon.stars';
      case ActivityCategory.social:
        return 'person.2';
      case ActivityCategory.creative:
        return 'paintpalette';
      case ActivityCategory.cognitiveDefusion:
        return 'cloud';
    }
  }

  static ActivityCategory fromString(String value) {
    return ActivityCategory.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => ActivityCategory.sensoryGrounding,
    );
  }
}

