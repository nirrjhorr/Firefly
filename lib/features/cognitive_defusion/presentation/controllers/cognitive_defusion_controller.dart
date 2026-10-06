import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/defusion_mode.dart';
import '../../domain/models/defusion_session_state.dart';
import '../../domain/models/defusion_thought.dart';

final cognitiveDefusionControllerProvider =
    StateNotifierProvider<CognitiveDefusionController, DefusionSessionState>((ref) {
  return CognitiveDefusionController();
});

class CognitiveDefusionController extends StateNotifier<DefusionSessionState> {
  CognitiveDefusionController() : super(DefusionSessionState.initial());

  void setMode(DefusionMode mode) {
    if (state.activeMode == mode) return;
    HapticFeedback.selectionClick();
    state = state.copyWith(activeMode: mode);
  }

  void updateInputText(String text) {
    state = state.copyWith(currentInputText: text);
  }

  /// Places a thought on a leaf or releases it as a cloud.
  void releaseThought([String? overrideText]) {
    final text = (overrideText ?? state.currentInputText).trim();
    if (text.isEmpty) return;

    HapticFeedback.mediumImpact();

    final newThought = DefusionThought.create(text: text);
    final updatedList = List<DefusionThought>.from(state.thoughts)..add(newThought);

    // Keep at most 8 active visual items to preserve performance and avoid clutter
    if (updatedList.length > 8) {
      updatedList.removeAt(0);
    }

    state = state.copyWith(
      thoughts: updatedList,
      currentInputText: '',
      totalReleasedCount: state.totalReleasedCount + 1,
    );
  }

  /// Updates drift progress (moving leaves down or clouds horizontally).
  void advanceDrift(double progressDelta) {
    if (state.thoughts.isEmpty) return;

    final updated = <DefusionThought>[];
    for (final t in state.thoughts) {
      final newProgress = t.driftProgress + progressDelta;
      if (newProgress < 1.05 && !t.isDissolved) {
        updated.add(t.copyWith(driftProgress: newProgress));
      }
    }

    if (updated.length != state.thoughts.length || progressDelta > 0.0) {
      state = state.copyWith(thoughts: updated);
    }
  }

  /// Dissolves a specific thought cloud with gentle mist effect.
  void dissolveThought(String thoughtId) {
    HapticFeedback.lightImpact();
    final updated = state.thoughts.map((t) {
      if (t.id == thoughtId) {
        return t.copyWith(isDissolved: true);
      }
      return t;
    }).toList();

    state = state.copyWith(
      thoughts: updated,
      isDissolving: true,
      totalReleasedCount: state.totalReleasedCount + 1,
    );

    // Reset dissolving flag after subtle animation
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        state = state.copyWith(isDissolving: false);
      }
    });
  }

  /// Advances the 3-step cognitive distance framing.
  void advanceLabelingStep() {
    HapticFeedback.lightImpact();
    if (state.labelingStep < 3) {
      state = state.copyWith(
        labelingStep: state.labelingStep + 1,
        totalReleasedCount: state.totalReleasedCount + 1,
      );
    } else {
      // Loop back or reset to next thought
      state = state.copyWith(
        labelingStep: 1,
        totalReleasedCount: state.totalReleasedCount + 1,
      );
    }
  }

  void setLabelingThought(String thought) {
    HapticFeedback.selectionClick();
    state = state.copyWith(
      labelingThoughtText: thought,
      labelingStep: 1,
    );
  }

  void tickTimer() {
    state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
  }

  void resetSession() {
    state = DefusionSessionState.initial(state.activeMode);
  }
}
