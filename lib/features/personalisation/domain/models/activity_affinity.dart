/// Immutable record of an activity's on-device personal affinity score
/// under a specific emotional/affective state.
class ActivityAffinity {
  const ActivityAffinity({
    required this.activityId,
    required this.targetState,
    required this.sampleCount,
    required this.averageRating,
    required this.affinityScore,
    this.lastPracticed,
    this.positiveCount = 0,
    this.negativeCount = 0,
    this.neutralCount = 0,
  });

  final String activityId;
  final String targetState;
  final int sampleCount;
  final double averageRating;

  /// Normalized score in [-1.0, 1.0]. Positive means the practice
  /// reliably helps the user feel settled or better in this state.
  final double affinityScore;

  final DateTime? lastPracticed;
  final int positiveCount;
  final int negativeCount;
  final int neutralCount;

  bool get hasSufficientData => sampleCount >= 2;
  bool get isEffective => affinityScore > 0.25;

  Map<String, dynamic> toJson() {
    return {
      'activityId': activityId,
      'targetState': targetState,
      'sampleCount': sampleCount,
      'averageRating': averageRating,
      'affinityScore': affinityScore,
      'lastPracticed': lastPracticed?.toIso8601String(),
      'positiveCount': positiveCount,
      'negativeCount': negativeCount,
      'neutralCount': neutralCount,
    };
  }

  factory ActivityAffinity.fromJson(Map<String, dynamic> json) {
    return ActivityAffinity(
      activityId: json['activityId'] as String,
      targetState: json['targetState'] as String,
      sampleCount: (json['sampleCount'] as num).toInt(),
      averageRating: (json['averageRating'] as num).toDouble(),
      affinityScore: (json['affinityScore'] as num).toDouble(),
      lastPracticed: json['lastPracticed'] != null
          ? DateTime.parse(json['lastPracticed'] as String)
          : null,
      positiveCount: (json['positiveCount'] as num?)?.toInt() ?? 0,
      negativeCount: (json['negativeCount'] as num?)?.toInt() ?? 0,
      neutralCount: (json['neutralCount'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityAffinity &&
          runtimeType == other.runtimeType &&
          activityId == other.activityId &&
          targetState == other.targetState &&
          sampleCount == other.sampleCount &&
          affinityScore == other.affinityScore;

  @override
  int get hashCode =>
      activityId.hashCode ^
      targetState.hashCode ^
      sampleCount.hashCode ^
      affinityScore.hashCode;
}
