import 'somatic_exercise_mode.dart';
import 'somatic_prompt.dart';

/// Immutable state representation for an active Somatic Centering session (Story 12.2).
class SomaticSessionState {
  const SomaticSessionState({
    required this.mode,
    this.currentStageIndex = 0,
    this.completedStages = 0,
    this.isCompleted = false,
    this.isAudioPlaying = false,
    this.isTimerActive = true,
    this.elapsedSeconds = 0,
  });

  final SomaticExerciseMode mode;
  final int currentStageIndex;
  final int completedStages;
  final bool isCompleted;
  final bool isAudioPlaying;
  final bool isTimerActive;
  final int elapsedSeconds;

  List<SomaticPrompt> get stages => kOfflineSomaticPrompts[mode] ?? [];

  int get totalStages => stages.length;

  SomaticPrompt? get currentStage {
    if (stages.isEmpty || currentStageIndex >= stages.length) return null;
    return stages[currentStageIndex];
  }

  double get progress {
    if (totalStages == 0) return 0.0;
    return (completedStages / totalStages).clamp(0.0, 1.0);
  }

  bool get isLastStage => currentStageIndex >= totalStages - 1;

  SomaticSessionState copyWith({
    SomaticExerciseMode? mode,
    int? currentStageIndex,
    int? completedStages,
    bool? isCompleted,
    bool? isAudioPlaying,
    bool? isTimerActive,
    int? elapsedSeconds,
  }) {
    return SomaticSessionState(
      mode: mode ?? this.mode,
      currentStageIndex: currentStageIndex ?? this.currentStageIndex,
      completedStages: completedStages ?? this.completedStages,
      isCompleted: isCompleted ?? this.isCompleted,
      isAudioPlaying: isAudioPlaying ?? this.isAudioPlaying,
      isTimerActive: isTimerActive ?? this.isTimerActive,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    );
  }
}
