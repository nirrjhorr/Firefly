/// Operating modes for the Focus & Mental Organisation suite.
enum FocusMode {
  threePriorities,
  focusTimer,
  brainDump;

  String get displayName {
    switch (this) {
      case FocusMode.threePriorities:
        return 'Three Priorities';
      case FocusMode.focusTimer:
        return 'Focus Companion';
      case FocusMode.brainDump:
        return 'Brain Dump';
    }
  }

  String get subtitle {
    switch (this) {
      case FocusMode.threePriorities:
        return 'Choose at most 3 gentle intentions to avoid overload.';
      case FocusMode.focusTimer:
        return 'A calm, non-punitive focus interval with zero streak pressure.';
      case FocusMode.brainDump:
        return 'Unload racing tasks and thoughts out of your head.';
    }
  }
}
