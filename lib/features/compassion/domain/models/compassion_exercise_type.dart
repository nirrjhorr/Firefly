/// Types of self-compassion and cognitive untangling exercises available in Firefly.
enum CompassionExerciseType {
  selfCompassionBreak,
  thoughtUntangler,
  lovingKindnessPhrases;

  String get title {
    switch (this) {
      case CompassionExerciseType.selfCompassionBreak:
        return 'Self-Compassion Break';
      case CompassionExerciseType.thoughtUntangler:
        return 'Thought Untangler';
      case CompassionExerciseType.lovingKindnessPhrases:
        return 'Loving-Kindness Sanctuary';
    }
  }

  String get subtitle {
    switch (this) {
      case CompassionExerciseType.selfCompassionBreak:
        return '3-step somatic pause to soothe acute self-criticism or pain';
      case CompassionExerciseType.thoughtUntangler:
        return 'Separate objective reality from harsh internal criticism';
      case CompassionExerciseType.lovingKindnessPhrases:
        return 'Gentle affirmations to soften defensiveness and loneliness';
    }
  }

  int get estimatedMinutes {
    switch (this) {
      case CompassionExerciseType.selfCompassionBreak:
        return 3;
      case CompassionExerciseType.thoughtUntangler:
        return 4;
      case CompassionExerciseType.lovingKindnessPhrases:
        return 3;
    }
  }
}
