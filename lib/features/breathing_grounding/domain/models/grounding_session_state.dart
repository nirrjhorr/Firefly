import 'grounding_stage.dart';

/// State representation for an active or completed 5-4-3-2-1 sensory grounding session.
class GroundingSessionState {
  final int currentStageIndex;
  final int currentStageNoticedCount;
  final bool isCompleted;
  final List<GroundingStage> stages;

  const GroundingSessionState({
    this.currentStageIndex = 0,
    this.currentStageNoticedCount = 0,
    this.isCompleted = false,
    this.stages = GroundingStage.standardStages,
  });

  GroundingStage get currentStage =>
      stages[currentStageIndex.clamp(0, stages.length - 1)];

  int get targetCount => currentStage.targetCount;

  bool get isCurrentStageComplete => currentStageNoticedCount >= targetCount;

  bool get isFirstStage => currentStageIndex == 0;

  bool get isLastStage => currentStageIndex == stages.length - 1;

  double get stageProgress =>
      targetCount > 0 ? (currentStageNoticedCount / targetCount).clamp(0.0, 1.0) : 1.0;

  double get overallProgress {
    if (isCompleted) return 1.0;
    // Total items across standard 5 stages: 5 + 4 + 3 + 2 + 1 = 15
    int totalTarget = 0;
    int totalNoticed = 0;
    for (int i = 0; i < stages.length; i++) {
      totalTarget += stages[i].targetCount;
      if (i < currentStageIndex) {
        totalNoticed += stages[i].targetCount;
      } else if (i == currentStageIndex) {
        totalNoticed += currentStageNoticedCount.clamp(0, stages[i].targetCount);
      }
    }
    return totalTarget > 0 ? (totalNoticed / totalTarget).clamp(0.0, 1.0) : 0.0;
  }

  GroundingSessionState copyWith({
    int? currentStageIndex,
    int? currentStageNoticedCount,
    bool? isCompleted,
    List<GroundingStage>? stages,
  }) {
    return GroundingSessionState(
      currentStageIndex: currentStageIndex ?? this.currentStageIndex,
      currentStageNoticedCount:
          currentStageNoticedCount ?? this.currentStageNoticedCount,
      isCompleted: isCompleted ?? this.isCompleted,
      stages: stages ?? this.stages,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroundingSessionState &&
          runtimeType == other.runtimeType &&
          currentStageIndex == other.currentStageIndex &&
          currentStageNoticedCount == other.currentStageNoticedCount &&
          isCompleted == other.isCompleted;

  @override
  int get hashCode => Object.hash(
        currentStageIndex,
        currentStageNoticedCount,
        isCompleted,
      );

  @override
  String toString() {
    return 'GroundingSessionState(stage: $currentStageIndex, noticed: $currentStageNoticedCount/$targetCount, completed: $isCompleted)';
  }
}
