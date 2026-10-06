import 'compassion_exercise_type.dart';
import 'untangled_thought.dart';

/// Immutable domain model representing a completed self-compassion practice session.
class CompassionSession {
  const CompassionSession({
    required this.id,
    required this.exerciseType,
    required this.startedAt,
    this.completedAt,
    this.preDistressRating,
    this.postDistressRating,
    this.untangledThought,
    this.reflectionNote,
  });

  factory CompassionSession.create({
    required CompassionExerciseType exerciseType,
    int? preDistressRating,
  }) {
    return CompassionSession(
      id: 'compassion_${DateTime.now().millisecondsSinceEpoch}',
      exerciseType: exerciseType,
      startedAt: DateTime.now(),
      preDistressRating: preDistressRating,
    );
  }

  final String id;
  final CompassionExerciseType exerciseType;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int? preDistressRating;
  final int? postDistressRating;
  final UntangledThought? untangledThought;
  final String? reflectionNote;

  bool get isCompleted => completedAt != null;

  CompassionSession copyWith({
    String? id,
    CompassionExerciseType? exerciseType,
    DateTime? startedAt,
    DateTime? completedAt,
    int? preDistressRating,
    int? postDistressRating,
    UntangledThought? untangledThought,
    String? reflectionNote,
  }) {
    return CompassionSession(
      id: id ?? this.id,
      exerciseType: exerciseType ?? this.exerciseType,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      preDistressRating: preDistressRating ?? this.preDistressRating,
      postDistressRating: postDistressRating ?? this.postDistressRating,
      untangledThought: untangledThought ?? this.untangledThought,
      reflectionNote: reflectionNote ?? this.reflectionNote,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exerciseType': exerciseType.name,
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'preDistressRating': preDistressRating,
      'postDistressRating': postDistressRating,
      'untangledThought': untangledThought?.toJson(),
      'reflectionNote': reflectionNote,
    };
  }

  factory CompassionSession.fromJson(Map<String, dynamic> json) {
    return CompassionSession(
      id: json['id'] as String,
      exerciseType: CompassionExerciseType.values.firstWhere(
        (e) => e.name == json['exerciseType'],
        orElse: () => CompassionExerciseType.selfCompassionBreak,
      ),
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      preDistressRating: json['preDistressRating'] as int?,
      postDistressRating: json['postDistressRating'] as int?,
      untangledThought: json['untangledThought'] != null
          ? UntangledThought.fromJson(
              json['untangledThought'] as Map<String, dynamic>)
          : null,
      reflectionNote: json['reflectionNote'] as String?,
    );
  }
}
