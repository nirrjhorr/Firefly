/// Represents the active phase of a respiration cycle.
enum BreathingPhase {
  /// Inhalation phase.
  inhale,

  /// Pause with lungs comfortably full.
  inhaleHold,

  /// Prolonged or measured exhalation phase.
  exhale,

  /// Pause with lungs resting empty.
  exhaleHold;

  bool get isInhale => this == BreathingPhase.inhale;
  bool get isHold => this == BreathingPhase.inhaleHold || this == BreathingPhase.exhaleHold;
  bool get isExhale => this == BreathingPhase.exhale;

  String get label {
    switch (this) {
      case BreathingPhase.inhale:
        return 'Breathe In';
      case BreathingPhase.inhaleHold:
        return 'Hold';
      case BreathingPhase.exhale:
        return 'Let Go';
      case BreathingPhase.exhaleHold:
        return 'Rest';
    }
  }
}

/// The breathing technique cadence.
enum BreathingTechnique {
  cyclicSighing,
  boxBreathing,
  resonance,
  relax478,
  star,
  diaphragmatic;

  String get displayName {
    switch (this) {
      case BreathingTechnique.cyclicSighing:
        return 'Cyclic Sighing';
      case BreathingTechnique.boxBreathing:
        return 'Box Breathing';
      case BreathingTechnique.resonance:
        return 'Resonance (5.5s)';
      case BreathingTechnique.relax478:
        return '4-7-8 Relaxation';
      case BreathingTechnique.star:
        return 'Star Breathing';
      case BreathingTechnique.diaphragmatic:
        return 'Belly Breathing';
    }
  }

  int get inhaleMs {
    switch (this) {
      case BreathingTechnique.cyclicSighing:
        return 4000;
      case BreathingTechnique.boxBreathing:
        return 4000;
      case BreathingTechnique.resonance:
        return 5500;
      case BreathingTechnique.relax478:
        return 4000;
      case BreathingTechnique.star:
        return 3000;
      case BreathingTechnique.diaphragmatic:
        return 4000;
    }
  }

  int get inhaleHoldMs {
    switch (this) {
      case BreathingTechnique.boxBreathing:
        return 4000;
      case BreathingTechnique.relax478:
        return 7000;
      case BreathingTechnique.star:
        return 1000;
      default:
        return 0;
    }
  }

  int get exhaleMs {
    switch (this) {
      case BreathingTechnique.cyclicSighing:
        return 8000;
      case BreathingTechnique.boxBreathing:
        return 4000;
      case BreathingTechnique.resonance:
        return 5500;
      case BreathingTechnique.relax478:
        return 8000;
      case BreathingTechnique.star:
        return 3000;
      case BreathingTechnique.diaphragmatic:
        return 6000;
    }
  }

  int get exhaleHoldMs {
    switch (this) {
      case BreathingTechnique.boxBreathing:
        return 4000;
      case BreathingTechnique.star:
        return 1000;
      default:
        return 0;
    }
  }
}

/// State representation for an active or idle breathing session.
class BreathingSessionState {
  final BreathingPhase phase;
  final BreathingTechnique technique;
  final double phaseProgress; // 0.0 to 1.0
  final int cycleCount;
  final int elapsedSeconds;
  final bool isActive;
  final String? soundscape;

  const BreathingSessionState({
    this.phase = BreathingPhase.inhale,
    this.technique = BreathingTechnique.cyclicSighing,
    this.phaseProgress = 0.0,
    this.cycleCount = 0,
    this.elapsedSeconds = 0,
    this.isActive = false,
    this.soundscape,
  });

  BreathingSessionState copyWith({
    BreathingPhase? phase,
    BreathingTechnique? technique,
    double? phaseProgress,
    int? cycleCount,
    int? elapsedSeconds,
    bool? isActive,
    String? soundscape,
    bool clearSoundscape = false,
  }) {
    return BreathingSessionState(
      phase: phase ?? this.phase,
      technique: technique ?? this.technique,
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
          technique == other.technique &&
          (phaseProgress - other.phaseProgress).abs() < 0.0001 &&
          cycleCount == other.cycleCount &&
          elapsedSeconds == other.elapsedSeconds &&
          isActive == other.isActive &&
          soundscape == other.soundscape;

  @override
  int get hashCode => Object.hash(
        phase,
        technique,
        phaseProgress,
        cycleCount,
        elapsedSeconds,
        isActive,
        soundscape,
      );

  @override
  String toString() {
    return 'BreathingSessionState(technique: ${technique.name}, phase: $phase, progress: ${phaseProgress.toStringAsFixed(2)}, '
        'cycles: $cycleCount, elapsed: ${elapsedSeconds}s, active: $isActive, soundscape: $soundscape)';
  }
}
