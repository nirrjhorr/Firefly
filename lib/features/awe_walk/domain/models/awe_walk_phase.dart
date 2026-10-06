/// The sequential phases of the evidence-based Awe Walk protocol
/// (Virginia Sturm et al. 2020, Emotion / UCSF Memory and Aging Center RCT).
enum AweWalkPhase {
  preparation,
  vastness,
  smallSelf,
  gratitude,
  complete;

  int get stepNumber {
    switch (this) {
      case AweWalkPhase.preparation:
        return 1;
      case AweWalkPhase.vastness:
        return 2;
      case AweWalkPhase.smallSelf:
        return 3;
      case AweWalkPhase.gratitude:
        return 4;
      case AweWalkPhase.complete:
        return 5;
    }
  }

  String get title {
    switch (this) {
      case AweWalkPhase.preparation:
        return 'Prepare Your Senses';
      case AweWalkPhase.vastness:
        return 'Vastness & Scale';
      case AweWalkPhase.smallSelf:
        return 'The Small Self';
      case AweWalkPhase.gratitude:
        return 'Sensory Anchor';
      case AweWalkPhase.complete:
        return 'Walk Completed';
    }
  }

  String get shortLabel {
    switch (this) {
      case AweWalkPhase.preparation:
        return 'Prepare';
      case AweWalkPhase.vastness:
        return 'Vastness';
      case AweWalkPhase.smallSelf:
        return 'Small Self';
      case AweWalkPhase.gratitude:
        return 'Anchor';
      case AweWalkPhase.complete:
        return 'Complete';
    }
  }

  String get guidancePrompt {
    switch (this) {
      case AweWalkPhase.preparation:
        return 'Step outside. Drop your shoulders, breathe with the open air, and allow your phone to become a gentle background guide.';
      case AweWalkPhase.vastness:
        return 'Shift your gaze outward and upward. Seek visual scale: tree canopies, horizon lines, sky depth, or historic architecture.';
      case AweWalkPhase.smallSelf:
        return 'Feel the gentle relief of your own smallness. You are one modest, living participant within an immense, resilient world.';
      case AweWalkPhase.gratitude:
        return 'Pick one specific detail of natural beauty or pattern you noticed today. Hold it gently as your sensory anchor.';
      case AweWalkPhase.complete:
        return 'Notice any change in mental spaciousness or physical tension as you transition back.';
    }
  }
}
