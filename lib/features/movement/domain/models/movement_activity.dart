/// The core types of movement and somatic regulation defined in the Firefly Activity Architecture.
enum MovementType {
  /// Dynamic physical exertion to discharge restlessness and adrenaline (shakeout, stroll, wall pushups, marching).
  activePhysical,

  /// Somatic tension release and body awareness (shoulder rolls, progressive stretch, jaw release, body shaking).
  somaticRelease,

  /// Routine micro-actions providing immediate behavioral momentum (drink water, open curtains, make bed).
  routineAction,

  /// Tactile manipulation and kinesthetic grounding (fidgeting, object holding, stress squeeze).
  tactileFocus;

  String get displayName {
    switch (this) {
      case MovementType.activePhysical:
        return 'Physical Movement';
      case MovementType.somaticRelease:
        return 'Somatic Release';
      case MovementType.routineAction:
        return 'Routine Action';
      case MovementType.tactileFocus:
        return 'Tactile Grounding';
    }
  }
}

/// An immutable definition of an individual movement or somatic release exercise.
class MovementActivity {
  final String id;
  final String title;
  final String description;
  final MovementType type;
  final int energyRequired; // 1 (lowest) to 3 (moderate)
  final int? durationSeconds; // null indicates open-ended
  final List<String> instructions;
  final int? cadenceBpm; // rhythmic visual cadence (e.g. 60-90 bpm)
  final String? sensoryAnchor;

  const MovementActivity({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.energyRequired,
    this.durationSeconds,
    this.instructions = const [],
    this.cadenceBpm,
    this.sensoryAnchor,
  })  : assert(energyRequired >= 1 && energyRequired <= 5, 'energyRequired must be 1..5'),
        assert(durationSeconds == null || durationSeconds > 0, 'durationSeconds must be positive if set');

  bool get isOpenEnded => durationSeconds == null;

  String get formattedDuration {
    if (durationSeconds == null) return 'Open Paced';
    final minutes = durationSeconds! ~/ 60;
    final seconds = durationSeconds! % 60;
    if (minutes > 0 && seconds == 0) return '${minutes}m';
    if (minutes > 0) return '${minutes}m ${seconds}s';
    return '${seconds}s';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MovementActivity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
