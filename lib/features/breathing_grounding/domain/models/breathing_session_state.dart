/// Represents the current phase of a respiration exercise.
enum BreathingPhase {
  /// Inhalation phase (4000ms in clinical cyclic sighing).
  inhale,

  /// Extended exhalation phase (8000ms in clinical cyclic sighing).
  exhale;

  bool get isInhale => this == BreathingPhase.inhale;
  bool get isExhale => this == BreathingPhase.exhale;
}

/// State representation for an active or idle breathing session.
class BreathingSessionState {
  final BreathingPhase phase;
  final double phaseProgress; // 0.0 to 1.0
  final int cycleCount;
  final int elapsedSeconds;
  final bool isActive;
  final String? soundscape;

  const BreathingSessionState({
    this.phase = BreathingPhase.inhale,
    this.phaseProgress = 0.0,
    this.cycleCount = 0,
    this.elapsedSeconds = 0,
    this.isActive = false,
    this.soundscape,
  });

  BreathingSessionState copyWith({
    BreathingPhase? phase,
    double? phaseProgress,
    int? cycleCount,
    int? elapsedSeconds,
    bool? isActive,
    String? soundscape,
    bool clearSoundscape = false,
  }) {
    return BreathingSessionState(
      phase: phase ?? this.phase,
      phaseProgress: phaseProgress ?? this.phaseProgress,
      cycleCount: cycleCount ?? this.cycleCount,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      isActive: isActive ?? this.isActive,
      soundscape: clearSoundscape ? null : (soundscape ?? this.soundscape),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BreathingSessionState &&
          runtimeType == other.runtimeType &&
          phase == other.phase &&
          (phaseProgress - other.phaseProgress).abs() < 0.0001 &&
          cycleCount == other.cycleCount &&
          elapsedSeconds == other.elapsedSeconds &&
          isActive == other.isActive &&
          soundscape == other.soundscape;

  @override
  int get hashCode => Object.hash(
        phase,
        phaseProgress,
        cycleCount,
        elapsedSeconds,
        isActive,
        soundscape,
      );

  @override
  String toString() {
    return 'BreathingSessionState(phase: $phase, progress: ${phaseProgress.toStringAsFixed(2)}, '
        'cycles: $cycleCount, elapsed: ${elapsedSeconds}s, active: $isActive, soundscape: $soundscape)';
  }
}
