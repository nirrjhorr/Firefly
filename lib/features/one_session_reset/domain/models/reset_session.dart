import 'reset_distress_anchor.dart';
import 'reset_phase.dart';

/// Immutable domain model representing a Single-Session Intervention (SSI) reset.
class ResetSession {
  const ResetSession({
    required this.id,
    required this.startedAt,
    this.completedAt,
    this.anchor,
    this.selectedTechnique,
    this.reframeReflection,
    this.microCommitment,
    this.effectivenessRating,
    this.currentPhase = ResetPhase.anchor,
  });

  factory ResetSession.create() {
    return ResetSession(
      id: 'reset_${DateTime.now().millisecondsSinceEpoch}',
      startedAt: DateTime.now(),
      currentPhase: ResetPhase.anchor,
    );
  }

  final String id;
  final DateTime startedAt;
  final DateTime? completedAt;
  final ResetDistressAnchor? anchor;
  final String? selectedTechnique;
  final String? reframeReflection;
  final String? microCommitment;
  final String? effectivenessRating;
  final ResetPhase currentPhase;

  bool get isCompleted => completedAt != null || currentPhase == ResetPhase.complete;

  ResetSession copyWith({
    String? id,
    DateTime? startedAt,
    DateTime? completedAt,
    ResetDistressAnchor? anchor,
    String? selectedTechnique,
    String? reframeReflection,
    String? microCommitment,
    String? effectivenessRating,
    ResetPhase? currentPhase,
  }) {
    return ResetSession(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      anchor: anchor ?? this.anchor,
      selectedTechnique: selectedTechnique ?? this.selectedTechnique,
      reframeReflection: reframeReflection ?? this.reframeReflection,
      microCommitment: microCommitment ?? this.microCommitment,
      effectivenessRating: effectivenessRating ?? this.effectivenessRating,
      currentPhase: currentPhase ?? this.currentPhase,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'anchor': anchor?.name,
      'selectedTechnique': selectedTechnique,
      'reframeReflection': reframeReflection,
      'microCommitment': microCommitment,
      'effectivenessRating': effectivenessRating,
      'currentPhase': currentPhase.name,
    };
  }

  factory ResetSession.fromJson(Map<String, dynamic> json) {
    return ResetSession(
      id: json['id'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      anchor: json['anchor'] != null
          ? ResetDistressAnchor.values.firstWhere(
              (a) => a.name == json['anchor'],
              orElse: () => ResetDistressAnchor.generalDistress,
            )
          : null,
      selectedTechnique: json['selectedTechnique'] as String?,
      reframeReflection: json['reframeReflection'] as String?,
      microCommitment: json['microCommitment'] as String?,
      effectivenessRating: json['effectivenessRating'] as String?,
      currentPhase: json['currentPhase'] != null
          ? ResetPhase.values.firstWhere(
              (p) => p.name == json['currentPhase'],
              orElse: () => ResetPhase.anchor,
            )
          : ResetPhase.anchor,
    );
  }
}
