import 'dart:math' as math;

/// Pure Dart 2D coordinate for meditative labyrinth path generation and tracing.
/// Keeps domain models decoupled from UI framework types (dart:ui / Flutter).
class LabyrinthCoord {
  const LabyrinthCoord(this.x, this.y);

  final double x;
  final double y;

  double distanceTo(LabyrinthCoord other) {
    final dx = x - other.x;
    final dy = y - other.y;
    return math.sqrt(dx * dx + dy * dy);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LabyrinthCoord &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;

  @override
  String toString() => 'LabyrinthCoord($x, $y)';
}
