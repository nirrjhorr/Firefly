import 'dart:math';

/// A thought externalized onto a visual defusion medium (leaf or cloud).
class DefusionThought {
  const DefusionThought({
    required this.id,
    required this.text,
    required this.createdAtUnix,
    this.driftProgress = 0.0,
    this.isDissolved = false,
    this.horizontalOffset = 0.0,
    this.tiltAngle = 0.0,
    this.lane = 0,
  });

  final String id;
  final String text;
  final int createdAtUnix;
  final double driftProgress; // 0.0 (top/start) -> 1.0 (drifted away)
  final bool isDissolved;
  final double horizontalOffset; // Normalized -1.0 to 1.0 horizontal variation
  final double tiltAngle; // Subtle organic wobble angle in radians
  final int lane;

  DefusionThought copyWith({
    String? id,
    String? text,
    int? createdAtUnix,
    double? driftProgress,
    bool? isDissolved,
    double? horizontalOffset,
    double? tiltAngle,
    int? lane,
  }) {
    return DefusionThought(
      id: id ?? this.id,
      text: text ?? this.text,
      createdAtUnix: createdAtUnix ?? this.createdAtUnix,
      driftProgress: driftProgress ?? this.driftProgress,
      isDissolved: isDissolved ?? this.isDissolved,
      horizontalOffset: horizontalOffset ?? this.horizontalOffset,
      tiltAngle: tiltAngle ?? this.tiltAngle,
      lane: lane ?? this.lane,
    );
  }

  factory DefusionThought.create({
    required String text,
    int? lane,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final rand = Random(now);
    final chosenLane = lane ?? rand.nextInt(3);
    final offset = (rand.nextDouble() * 0.6) - 0.3; // -0.3 to +0.3
    final tilt = (rand.nextDouble() * 0.4) - 0.2; // -0.2 to +0.2 rads
    return DefusionThought(
      id: 'dt_${now}_${rand.nextInt(1000)}',
      text: text.trim(),
      createdAtUnix: now ~/ 1000,
      horizontalOffset: offset,
      tiltAngle: tilt,
      lane: chosenLane,
    );
  }
}

/// Curated starter prompts for users who are overwhelmed or tired of typing.
const List<String> kCuratedDefusionPrompts = [
  "I have too much to do",
  "I'm falling behind",
  "What if things go wrong?",
  "I should be feeling better by now",
  "I'm not doing enough",
  "I can't seem to relax",
  "Everyone else has it together",
  "I have to get this right",
  "I feel completely stuck",
  "What if I let people down?",
  "I'm carrying too much right now",
  "My mind won't slow down",
];
