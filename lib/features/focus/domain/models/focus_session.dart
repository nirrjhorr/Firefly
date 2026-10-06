/// Immutable domain model representing a low-stimulation focus interval.
/// Designed without streak pressure, red urgency graphics, or shame counters.
class FocusSession {
  final String id;
  final int durationMinutes;
  final int remainingSeconds;
  final String? priorityId;
  final String? priorityTitle;
  final String? ambientSoundId;
  final bool isPaused;
  final bool isCompleted;
  final DateTime startedAt;
  final DateTime? completedAt;

  const FocusSession({
    required this.id,
    required this.durationMinutes,
    required this.remainingSeconds,
    this.priorityId,
    this.priorityTitle,
    this.ambientSoundId,
    this.isPaused = false,
    this.isCompleted = false,
    required this.startedAt,
    this.completedAt,
  });

  factory FocusSession.create({
    required int durationMinutes,
    String? priorityId,
    String? priorityTitle,
    String? ambientSoundId,
  }) {
    return FocusSession(
      id: 'focussession_${DateTime.now().millisecondsSinceEpoch}',
      durationMinutes: durationMinutes,
      remainingSeconds: durationMinutes * 60,
      priorityId: priorityId,
      priorityTitle: priorityTitle,
      ambientSoundId: ambientSoundId,
      isPaused: false,
      isCompleted: false,
      startedAt: DateTime.now(),
    );
  }

  double get progress {
    final totalSeconds = durationMinutes * 60;
    if (totalSeconds <= 0) return 1.0;
    return ((totalSeconds - remainingSeconds) / totalSeconds).clamp(0.0, 1.0);
  }

  String get formattedTime {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    final mStr = minutes.toString().padLeft(2, '0');
    final sStr = seconds.toString().padLeft(2, '0');
    return '$mStr:$sStr';
  }

  FocusSession copyWith({
    String? id,
    int? durationMinutes,
    int? remainingSeconds,
    String? priorityId,
    String? priorityTitle,
    String? ambientSoundId,
    bool? isPaused,
    bool? isCompleted,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return FocusSession(
      id: id ?? this.id,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      priorityId: priorityId ?? this.priorityId,
      priorityTitle: priorityTitle ?? this.priorityTitle,
      ambientSoundId: ambientSoundId ?? this.ambientSoundId,
      isPaused: isPaused ?? this.isPaused,
      isCompleted: isCompleted ?? this.isCompleted,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'durationMinutes': durationMinutes,
      'remainingSeconds': remainingSeconds,
      'priorityId': priorityId,
      'priorityTitle': priorityTitle,
      'ambientSoundId': ambientSoundId,
      'isPaused': isPaused,
      'isCompleted': isCompleted,
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory FocusSession.fromJson(Map<String, dynamic> json) {
    return FocusSession(
      id: json['id'] as String,
      durationMinutes: json['durationMinutes'] as int,
      remainingSeconds: json['remainingSeconds'] as int,
      priorityId: json['priorityId'] as String?,
      priorityTitle: json['priorityTitle'] as String?,
      ambientSoundId: json['ambientSoundId'] as String?,
      isPaused: json['isPaused'] as bool? ?? false,
      isCompleted: json['isCompleted'] as bool? ?? false,
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FocusSession &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          durationMinutes == other.durationMinutes &&
          remainingSeconds == other.remainingSeconds &&
          isPaused == other.isPaused &&
          isCompleted == other.isCompleted;

  @override
  int get hashCode =>
      id.hashCode ^
      durationMinutes.hashCode ^
      remainingSeconds.hashCode ^
      isPaused.hashCode ^
      isCompleted.hashCode;
}
