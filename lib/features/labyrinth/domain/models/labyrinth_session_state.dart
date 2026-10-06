import 'labyrinth_coord.dart';
import 'labyrinth_pattern_type.dart';

/// Immutable state for a meditative labyrinth finger tracing session (Story 12.3).
class LabyrinthSessionState {
  const LabyrinthSessionState({
    required this.pattern,
    this.tracedPoints = const [],
    this.progress = 0.0,
    this.isTracingActive = false,
    this.isCompleted = false,
    this.loopsCompleted = 0,
    this.showGuidePath = true,
    this.elapsedSeconds = 0,
  });

  final LabyrinthPatternType pattern;
  final List<LabyrinthCoord> tracedPoints;
  final double progress; // 0.0 to 1.0
  final bool isTracingActive;
  final bool isCompleted;
  final int loopsCompleted;
  final bool showGuidePath;
  final int elapsedSeconds;

  int get totalPointsTraced => tracedPoints.length;

  LabyrinthSessionState copyWith({
    LabyrinthPatternType? pattern,
    List<LabyrinthCoord>? tracedPoints,
    double? progress,
    bool? isTracingActive,
    bool? isCompleted,
    int? loopsCompleted,
    bool? showGuidePath,
    int? elapsedSeconds,
  }) {
    return LabyrinthSessionState(
      pattern: pattern ?? this.pattern,
      tracedPoints: tracedPoints ?? this.tracedPoints,
      progress: progress ?? this.progress,
      isTracingActive: isTracingActive ?? this.isTracingActive,
      isCompleted: isCompleted ?? this.isCompleted,
      loopsCompleted: loopsCompleted ?? this.loopsCompleted,
      showGuidePath: showGuidePath ?? this.showGuidePath,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    );
  }
}
