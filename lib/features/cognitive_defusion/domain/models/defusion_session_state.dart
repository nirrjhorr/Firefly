import 'defusion_mode.dart';
import 'defusion_thought.dart';

/// Immutable session state for Cognitive Defusion.
class DefusionSessionState {
  const DefusionSessionState({
    required this.activeMode,
    required this.thoughts,
    required this.currentInputText,
    required this.labelingStep,
    required this.labelingThoughtText,
    required this.totalReleasedCount,
    required this.elapsedSeconds,
    this.isDissolving = false,
  });

  final DefusionMode activeMode;
  final List<DefusionThought> thoughts;
  final String currentInputText;
  final int labelingStep; // 1 (raw), 2 ("I notice I am having the thought..."), 3 ("I notice my mind is giving me a story...")
  final String labelingThoughtText;
  final int totalReleasedCount;
  final int elapsedSeconds;
  final bool isDissolving;

  factory DefusionSessionState.initial([DefusionMode mode = DefusionMode.leavesOnStream]) {
    return DefusionSessionState(
      activeMode: mode,
      thoughts: const [],
      currentInputText: '',
      labelingStep: 1,
      labelingThoughtText: kCuratedDefusionPrompts.first,
      totalReleasedCount: 0,
      elapsedSeconds: 0,
      isDissolving: false,
    );
  }

  /// Formats the thought according to the current defusion step level.
  String get formattedLabelingText {
    final thought = labelingThoughtText.trim();
    if (thought.isEmpty) return '';

    switch (labelingStep) {
      case 1:
        return '"$thought"';
      case 2:
        return 'I notice I am having the thought that\n"$thought"';
      case 3:
        return 'I notice that my mind is giving me a story that\n"$thought"\n...and I am here observing it.';
      default:
        return thought;
    }
  }

  DefusionSessionState copyWith({
    DefusionMode? activeMode,
    List<DefusionThought>? thoughts,
    String? currentInputText,
    int? labelingStep,
    String? labelingThoughtText,
    int? totalReleasedCount,
    int? elapsedSeconds,
    bool? isDissolving,
  }) {
    return DefusionSessionState(
      activeMode: activeMode ?? this.activeMode,
      thoughts: thoughts ?? this.thoughts,
      currentInputText: currentInputText ?? this.currentInputText,
      labelingStep: labelingStep ?? this.labelingStep,
      labelingThoughtText: labelingThoughtText ?? this.labelingThoughtText,
      totalReleasedCount: totalReleasedCount ?? this.totalReleasedCount,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      isDissolving: isDissolving ?? this.isDissolving,
    );
  }
}
