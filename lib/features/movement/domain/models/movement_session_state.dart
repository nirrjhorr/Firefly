import 'movement_activity.dart';

/// Operational status of an active movement regulation session.
enum MovementSessionStatus {
  idle,
  active,
  paused,
  completed;

  bool get isRunning => this == MovementSessionStatus.active;
  bool get isPaused => this == MovementSessionStatus.paused;
  bool get isDone => this == MovementSessionStatus.completed;
}

/// Immutable state snapshot of an active movement session.
class MovementSessionState {
  final MovementActivity activity;
  final int elapsedSeconds;
  final int? remainingSeconds;
  final MovementSessionStatus status;
  final int currentStepIndex;

  const MovementSessionState({
    required this.activity,
    this.elapsedSeconds = 0,
    this.remainingSeconds,
    this.status = MovementSessionStatus.idle,
    this.currentStepIndex = 0,
  });

  /// Total progress as a fraction between 0.0 and 1.0 (or 0.0 if open-ended).
  double get progress {
    if (activity.durationSeconds == null || activity.durationSeconds == 0) {
      return 0.0;
    }
    final prog = elapsedSeconds / activity.durationSeconds!;
    return prog.clamp(0.0, 1.0);
  }

  /// Current formatted time display (e.g. "01:45" remaining or elapsed).
  String get formattedDisplayTime {
    final int secondsToShow;
    if (activity.durationSeconds != null) {
      secondsToShow = remainingSeconds ?? activity.durationSeconds!;
    } else {
      secondsToShow = elapsedSeconds;
    }

    final m = (secondsToShow ~/ 60).toString().padLeft(2, '0');
    final s = (secondsToShow % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  MovementSessionState copyWith({
    MovementActivity? activity,
    int? elapsedSeconds,
    int? remainingSeconds,
    MovementSessionStatus? status,
    int? currentStepIndex,
  }) {
    return MovementSessionState(
      activity: activity ?? this.activity,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      status: status ?? this.status,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
    );
  }
}
