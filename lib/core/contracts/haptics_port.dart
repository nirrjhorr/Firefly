/// Abstract port defining tactile feedback methods synchronized with
/// respiration phases and sensory grounding interactions.
abstract class HapticsPort {
  /// Emits a tactile double light impact (100ms apart) signaling start of inhalation.
  Future<void> phaseTransitionInhale();

  /// Emits a single tactile light impact signaling transition to exhalation.
  Future<void> phaseTransitionExhale();

  /// Emits a tactile selection click confirming a grounding step completion.
  Future<void> groundingConfirm();
}
