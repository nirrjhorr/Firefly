/// An on-device record of a user's perceived change in state after an activity.
///
/// Ratings use a 5-point discrete scale:
/// -2: Much worse
/// -1: A little worse
///  0: About the same
/// +1: A little better
/// +2: Much better
class ActivityEffectivenessLog {
  const ActivityEffectivenessLog({
    required this.id,
    required this.activityId,
    required this.stateAtStart,
    required this.rating,
    required this.timestamp,
    required this.durationSeconds,
  }) : assert(rating >= -2 && rating <= 2, 'Rating must be between -2 and +2');

  final String id;
  final String activityId;
  final String stateAtStart;
  final int rating;
  final DateTime timestamp;
  final int durationSeconds;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'activityId': activityId,
      'stateAtStart': stateAtStart,
      'rating': rating,
      'timestamp': timestamp.toIso8601String(),
      'durationSeconds': durationSeconds,
    };
  }

  factory ActivityEffectivenessLog.fromJson(Map<String, dynamic> json) {
    return ActivityEffectivenessLog(
      id: json['id'] as String,
      activityId: json['activityId'] as String,
      stateAtStart: json['stateAtStart'] as String,
      rating: (json['rating'] as num).toInt(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      durationSeconds: (json['durationSeconds'] as num).toInt(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityEffectivenessLog &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
