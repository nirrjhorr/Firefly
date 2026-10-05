/// Anatomical muscle zones targeted during Progressive Muscle Relaxation (PMR).
enum PmrMuscleZone {
  forehead,
  face,
  jaw,
  neckShoulders,
  handsArms,
  chest,
  stomach,
  back,
  thighs,
  calvesFeet;

  String get displayName {
    switch (this) {
      case PmrMuscleZone.forehead:
        return 'Forehead & Brow';
      case PmrMuscleZone.face:
        return 'Eyes & Face';
      case PmrMuscleZone.jaw:
        return 'Jaw & Mouth';
      case PmrMuscleZone.neckShoulders:
        return 'Neck & Shoulders';
      case PmrMuscleZone.handsArms:
        return 'Hands & Forearms';
      case PmrMuscleZone.chest:
        return 'Chest & Upper Body';
      case PmrMuscleZone.stomach:
        return 'Abdomen & Core';
      case PmrMuscleZone.back:
        return 'Upper & Lower Back';
      case PmrMuscleZone.thighs:
        return 'Thighs & Hips';
      case PmrMuscleZone.calvesFeet:
        return 'Calves & Feet';
    }
  }

  String get tenseInstruction {
    switch (this) {
      case PmrMuscleZone.forehead:
        return 'Raise eyebrows high or furrow brow tightly.';
      case PmrMuscleZone.face:
        return 'Squeeze eyes shut and scrunch nose gently.';
      case PmrMuscleZone.jaw:
        return 'Clench teeth gently and press tongue to palate.';
      case PmrMuscleZone.neckShoulders:
        return 'Shrug shoulders upward toward your ears.';
      case PmrMuscleZone.handsArms:
        return 'Clench both fists firmly and tighten forearms.';
      case PmrMuscleZone.chest:
        return 'Take a deep breath and hold chest muscles tight.';
      case PmrMuscleZone.stomach:
        return 'Pull abdominal muscles in tight toward spine.';
      case PmrMuscleZone.back:
        return 'Arch back slightly, pulling shoulder blades together.';
      case PmrMuscleZone.thighs:
        return 'Squeeze thighs, glutes, and quadriceps firmly.';
      case PmrMuscleZone.calvesFeet:
        return 'Curl toes downward and flex calf muscles.';
    }
  }

  String get releaseInstruction {
    switch (this) {
      case PmrMuscleZone.forehead:
        return 'Release brow completely. Let the forehead feel smooth and cool.';
      case PmrMuscleZone.face:
        return 'Let all facial muscles soften, smoothing away tension.';
      case PmrMuscleZone.jaw:
        return 'Drop the jaw slightly. Feel teeth part and mouth relax.';
      case PmrMuscleZone.neckShoulders:
        return 'Drop shoulders all the way down. Feel heavy warmth spreading.';
      case PmrMuscleZone.handsArms:
        return 'Open fingers limp. Feel tingling warmth in your palms.';
      case PmrMuscleZone.chest:
        return 'Exhale softly. Let the ribcage sink into stillness.';
      case PmrMuscleZone.stomach:
        return 'Release your belly. Let it be soft and relaxed.';
      case PmrMuscleZone.back:
        return 'Settle back down. Feel your spine rest without tension.';
      case PmrMuscleZone.thighs:
        return 'Release your legs. Feel weight sinking into your seat.';
      case PmrMuscleZone.calvesFeet:
        return 'Release your toes. Let feet rest completely limp and heavy.';
    }
  }

  /// Relative Y center position in the silhouette (0.0 to 1.0)
  double get relativeCenterY {
    switch (this) {
      case PmrMuscleZone.forehead:
        return 0.12;
      case PmrMuscleZone.face:
        return 0.16;
      case PmrMuscleZone.jaw:
        return 0.20;
      case PmrMuscleZone.neckShoulders:
        return 0.26;
      case PmrMuscleZone.chest:
        return 0.35;
      case PmrMuscleZone.handsArms:
        return 0.45;
      case PmrMuscleZone.stomach:
        return 0.47;
      case PmrMuscleZone.back:
        return 0.40;
      case PmrMuscleZone.thighs:
        return 0.62;
      case PmrMuscleZone.calvesFeet:
        return 0.85;
    }
  }
}

/// The 4 clinical phases of each PMR muscle zone cycle.
enum PmrPhase {
  tense(durationSeconds: 5, label: 'Tense'),
  hold(durationSeconds: 3, label: 'Hold'),
  release(durationSeconds: 10, label: 'Release'),
  notice(durationSeconds: 5, label: 'Notice & Feel');

  final int durationSeconds;
  final String label;

  const PmrPhase({
    required this.durationSeconds,
    required this.label,
  });

  int get durationMs => durationSeconds * 1000;
}

/// Immutable state for a Progressive Muscle Relaxation session.
class PmrSessionState {
  final List<PmrMuscleZone> zones;
  final int currentZoneIndex;
  final PmrPhase phase;
  final double phaseProgress; // 0.0 to 1.0
  final int elapsedPhaseMs;
  final bool isActive;
  final bool isCompleted;
  final bool isQuickMode;

  const PmrSessionState({
    this.zones = const [
      PmrMuscleZone.forehead,
      PmrMuscleZone.face,
      PmrMuscleZone.jaw,
      PmrMuscleZone.neckShoulders,
      PmrMuscleZone.handsArms,
      PmrMuscleZone.chest,
      PmrMuscleZone.stomach,
      PmrMuscleZone.back,
      PmrMuscleZone.thighs,
      PmrMuscleZone.calvesFeet,
    ],
    this.currentZoneIndex = 0,
    this.phase = PmrPhase.tense,
    this.phaseProgress = 0.0,
    this.elapsedPhaseMs = 0,
    this.isActive = false,
    this.isCompleted = false,
    this.isQuickMode = false,
  });

  PmrMuscleZone get currentZone =>
      zones.isNotEmpty && currentZoneIndex < zones.length
          ? zones[currentZoneIndex]
          : PmrMuscleZone.forehead;

  int get totalZones => zones.length;

  PmrSessionState copyWith({
    List<PmrMuscleZone>? zones,
    int? currentZoneIndex,
    PmrPhase? phase,
    double? phaseProgress,
    int? elapsedPhaseMs,
    bool? isActive,
    bool? isCompleted,
    bool? isQuickMode,
  }) {
    return PmrSessionState(
      zones: zones ?? this.zones,
      currentZoneIndex: currentZoneIndex ?? this.currentZoneIndex,
      phase: phase ?? this.phase,
      phaseProgress: phaseProgress ?? this.phaseProgress,
      elapsedPhaseMs: elapsedPhaseMs ?? this.elapsedPhaseMs,
      isActive: isActive ?? this.isActive,
      isCompleted: isCompleted ?? this.isCompleted,
      isQuickMode: isQuickMode ?? this.isQuickMode,
    );
  }
}
