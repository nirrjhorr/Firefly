import 'awe_walk_phase.dart';

/// Immutable domain model representing an Awe Walk session.
class AweWalkSession {
  const AweWalkSession({
    required this.id,
    required this.targetDurationMinutes,
    required this.elapsedSeconds,
    required this.currentPhase,
    required this.activePromptIndex,
    required this.completedPromptIds,
    this.anchorDetail,
    this.ratingShift,
    required this.startedAt,
    this.completedAt,
    this.isPaused = false,
  });

  final String id;
  final int targetDurationMinutes;
  final int elapsedSeconds;
  final AweWalkPhase currentPhase;
  final int activePromptIndex;
  final List<String> completedPromptIds;
  final String? anchorDetail;
  final int? ratingShift; // -2 to +2 EMA shift
  final DateTime startedAt;
  final DateTime? completedAt;
  final bool isPaused;

  /// Creates a fresh session with chosen duration (5, 10, or 15 minutes).
  factory AweWalkSession.create({int durationMinutes = 10}) {
    return AweWalkSession(
      id: 'awe_${DateTime.now().millisecondsSinceEpoch}',
      targetDurationMinutes: durationMinutes,
      elapsedSeconds: 0,
      currentPhase: AweWalkPhase.preparation,
      activePromptIndex: 0,
      completedPromptIds: const [],
      anchorDetail: null,
      ratingShift: null,
      startedAt: DateTime.now(),
      completedAt: null,
      isPaused: false,
    );
  }

  int get totalTargetSeconds => targetDurationMinutes * 60;

  double get progressFraction {
    if (totalTargetSeconds <= 0) return 0.0;
    final progress = elapsedSeconds / totalTargetSeconds;
    return progress.clamp(0.0, 1.0);
  }

  bool get isComplete =>
      currentPhase == AweWalkPhase.complete ||
      (elapsedSeconds >= totalTargetSeconds && totalTargetSeconds > 0);

  AweWalkSession copyWith({
    String? id,
    int? targetDurationMinutes,
    int? elapsedSeconds,
    AweWalkPhase? currentPhase,
    int? activePromptIndex,
    List<String>? completedPromptIds,
    String? anchorDetail,
    int? ratingShift,
    DateTime? startedAt,
    DateTime? completedAt,
    bool? isPaused,
  }) {
    return AweWalkSession(
      id: id ?? this.id,
      targetDurationMinutes:
          targetDurationMinutes ?? this.targetDurationMinutes,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      currentPhase: currentPhase ?? this.currentPhase,
      activePromptIndex: activePromptIndex ?? this.activePromptIndex,
      completedPromptIds: completedPromptIds ?? this.completedPromptIds,
      anchorDetail: anchorDetail ?? this.anchorDetail,
      ratingShift: ratingShift ?? this.ratingShift,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      isPaused: isPaused ?? this.isPaused,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'targetDurationMinutes': targetDurationMinutes,
        'elapsedSeconds': elapsedSeconds,
        'currentPhase': currentPhase.name,
        'activePromptIndex': activePromptIndex,
        'completedPromptIds': completedPromptIds,
        'anchorDetail': anchorDetail,
        'ratingShift': ratingShift,
        'startedAt': startedAt.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'isPaused': isPaused,
      };

  factory AweWalkSession.fromJson(Map<String, dynamic> json) {
    return AweWalkSession(
      id: json['id'] as String,
      targetDurationMinutes: (json['targetDurationMinutes'] as num).toInt(),
      elapsedSeconds: (json['elapsedSeconds'] as num).toInt(),
      currentPhase: AweWalkPhase.values.firstWhere(
        (p) => p.name == json['currentPhase'],
        orElse: () => AweWalkPhase.preparation,
      ),
      activePromptIndex: (json['activePromptIndex'] as num).toInt(),
      completedPromptIds: (json['completedPromptIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      anchorDetail: json['anchorDetail'] as String?,
      ratingShift: (json['ratingShift'] as num?)?.toInt(),
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      isPaused: json['isPaused'] as bool? ?? false,
    );
  }
}
