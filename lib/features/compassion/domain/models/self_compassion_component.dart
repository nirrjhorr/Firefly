/// The three core components of Kristin Neff's empirical self-compassion model
/// (Neff 2003, 2023; Neff & Germer 2013).
enum SelfCompassionComponent {
  mindfulness,
  commonHumanity,
  selfKindness;

  int get stepNumber {
    switch (this) {
      case SelfCompassionComponent.mindfulness:
        return 1;
      case SelfCompassionComponent.commonHumanity:
        return 2;
      case SelfCompassionComponent.selfKindness:
        return 3;
    }
  }

  String get title {
    switch (this) {
      case SelfCompassionComponent.mindfulness:
        return 'Mindfulness';
      case SelfCompassionComponent.commonHumanity:
        return 'Common Humanity';
      case SelfCompassionComponent.selfKindness:
        return 'Self-Kindness';
    }
  }

  String get shortPhrase {
    switch (this) {
      case SelfCompassionComponent.mindfulness:
        return 'This is a moment of difficulty.';
      case SelfCompassionComponent.commonHumanity:
        return 'Difficulty is a natural part of human life.';
      case SelfCompassionComponent.selfKindness:
        return 'May I offer myself warmth and patience.';
    }
  }

  String get description {
    switch (this) {
      case SelfCompassionComponent.mindfulness:
        return 'Acknowledge what hurts right now without magnifying it or pushing it away. Labeling the pain softens its grip.';
      case SelfCompassionComponent.commonHumanity:
        return 'Remind yourself that struggle, vulnerability, and imperfections do not isolate you — they connect you to everyone.';
      case SelfCompassionComponent.selfKindness:
        return 'Speak to yourself the way you would whisper to someone you cherish who is having a painful day.';
    }
  }

  String get somaticPrompt {
    switch (this) {
      case SelfCompassionComponent.mindfulness:
        return 'Notice the physical sensation in your chest, throat, or shoulders. Allow it to just be there for this breath.';
      case SelfCompassionComponent.commonHumanity:
        return 'Feel both feet resting on the earth. Imagine the millions of people sharing this exact quiet struggle today.';
      case SelfCompassionComponent.selfKindness:
        return 'Gently place one warm hand over your heart or across your belly. Feel the comforting weight and warmth of your touch.';
    }
  }

  String get affirmation {
    switch (this) {
      case SelfCompassionComponent.mindfulness:
        return 'I am feeling this, and it is okay to feel it.';
      case SelfCompassionComponent.commonHumanity:
        return 'I am not alone in my struggle.';
      case SelfCompassionComponent.selfKindness:
        return 'I am worthy of gentleness right now.';
    }
  }
}
