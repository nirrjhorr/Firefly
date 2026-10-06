/// Abstract port defining tactile feedback methods synchronized with
/// respiration phases and sensory grounding interactions.
abstract class HapticsPort {
  /// Emits a tactile double light impact (100ms apart) signaling start of inhalation.
  Future<void> phaseTransitionInhale();

  /// Emits a single tactile light impact signaling transition to exhalation.
  Future<void> phaseTransitionExhale();

  /// Emits a tactile selection click confirming a grounding step completion.
  Future<void> groundingConfirm();

  /// Emits a light impact tactile feedback.
  Future<void> lightImpact();

  /// Emits a medium impact tactile feedback.
  Future<void> mediumImpact();

  /// Emits a selection click tactile feedback.
  Future<void> selectionClick();
}
