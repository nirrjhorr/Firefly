/// The 5 sequential phases of the evidence-based Single-Session Intervention (SSI)
/// One-Session Reset protocol (Schleider et al. 2025, Baumel et al. 2019).
enum ResetPhase {
  anchor,
  regulate,
  reframe,
  commit,
  complete;

  int get stepNumber {
    switch (this) {
      case ResetPhase.anchor:
        return 1;
      case ResetPhase.regulate:
        return 2;
      case ResetPhase.reframe:
        return 3;
      case ResetPhase.commit:
        return 4;
      case ResetPhase.complete:
        return 5;
    }
  }

  String get title {
    switch (this) {
      case ResetPhase.anchor:
        return 'Name the Moment';
      case ResetPhase.regulate:
        return 'Settle the Body';
      case ResetPhase.reframe:
        return 'Gentle Perspective';
      case ResetPhase.commit:
        return 'One Small Step';
      case ResetPhase.complete:
        return 'Sanctuary Close';
    }
  }

  String get shortLabel {
    switch (this) {
      case ResetPhase.anchor:
        return 'Anchor';
      case ResetPhase.regulate:
        return 'Regulate';
      case ResetPhase.reframe:
        return 'Reframe';
      case ResetPhase.commit:
        return 'Commit';
      case ResetPhase.complete:
        return 'Complete';
    }
  }

  String get guidancePrompt {
    switch (this) {
      case ResetPhase.anchor:
        return 'Notice what is taking up space in your body and mind right now. There is no right answer.';
      case ResetPhase.regulate:
        return 'Give your autonomic nervous system 90 seconds to slow down. Follow the gentle cadence.';
      case ResetPhase.reframe:
        return 'Put a little compassionate distance between you and the overwhelm.';
      case ResetPhase.commit:
        return 'Pick one tiny physical action you can do in under 2 minutes when you leave this screen.';
      case ResetPhase.complete:
        return 'You took time to show up for yourself. Notice how you feel now.';
    }
  }

  bool get hasPrevious => this != ResetPhase.anchor && this != ResetPhase.complete;
  bool get hasNext => this != ResetPhase.complete;
}
