import 'nature_observation_mode.dart';
import 'nature_prompt.dart';

/// Immutable session state for a Nature Observation and Environmental Grounding session.
class NatureSessionState {
  const NatureSessionState({
    required this.mode,
    this.currentPromptIndex = 0,
    this.completedPrompts = 0,
    this.isCompleted = false,
    this.isTimerActive = false,
    this.elapsedSeconds = 0,
  });

  final NatureObservationMode mode;
  final int currentPromptIndex;
  final int completedPrompts;
  final bool isCompleted;
  final bool isTimerActive;
  final int elapsedSeconds;

  List<NaturePrompt> get prompts =>
      kOfflineNaturePrompts[mode] ?? kOfflineNaturePrompts[NatureObservationMode.skyGazing]!;

  NaturePrompt get currentPrompt {
    final list = prompts;
    if (currentPromptIndex < 0 || currentPromptIndex >= list.length) {
      return list.first;
    }
    return list[currentPromptIndex];
  }

  int get totalPrompts => prompts.length;

  bool get hasPrevious => currentPromptIndex > 0;

  bool get hasNext => currentPromptIndex < totalPrompts - 1;

  double get progressFraction {
    if (totalPrompts == 0) return 0.0;
    if (isCompleted) return 1.0;
    return (currentPromptIndex / totalPrompts).clamp(0.0, 1.0);
  }

  NatureSessionState copyWith({
    NatureObservationMode? mode,
    int? currentPromptIndex,
    int? completedPrompts,
    bool? isCompleted,
    bool? isTimerActive,
    int? elapsedSeconds,
  }) {
    return NatureSessionState(
      mode: mode ?? this.mode,
      currentPromptIndex: currentPromptIndex ?? this.currentPromptIndex,
      completedPrompts: completedPrompts ?? this.completedPrompts,
      isCompleted: isCompleted ?? this.isCompleted,
      isTimerActive: isTimerActive ?? this.isTimerActive,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    );
  }
}
