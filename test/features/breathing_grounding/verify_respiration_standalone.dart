import '../../../lib/features/breathing_grounding/domain/models/breathing_session_state.dart';

void main() {
  print('=== Verifying Respiration & Multi-Technique Models ===');

  // 1. Verify techniques & timings
  assert(BreathingTechnique.values.length == 6, 'Expected 6 breathing techniques');
  for (final t in BreathingTechnique.values) {
    assert(t.displayName.isNotEmpty, 'Display name must not be empty');
    assert(t.inhaleMs > 0, '${t.name} inhaleMs must be > 0');
    assert(t.exhaleMs > 0, '${t.name} exhaleMs must be > 0');
    print('Technique: ${t.displayName.padRight(20)} | In: ${t.inhaleMs}ms, InHold: ${t.inhaleHoldMs}ms, Out: ${t.exhaleMs}ms, OutHold: ${t.exhaleHoldMs}ms');
  }

  // 2. Verify Box Breathing hold timings
  final box = BreathingTechnique.boxBreathing;
  assert(box.inhaleMs == 4000 && box.inhaleHoldMs == 4000 && box.exhaleMs == 4000 && box.exhaleHoldMs == 4000,
      'Box breathing must be 4-4-4-4');

  // 3. Verify 4-7-8 Breathing
  final r478 = BreathingTechnique.relax478;
  assert(r478.inhaleMs == 4000 && r478.inhaleHoldMs == 7000 && r478.exhaleMs == 8000 && r478.exhaleHoldMs == 0,
      '4-7-8 timing mismatch');

  // 4. Verify BreathingPhase labels and properties
  assert(BreathingPhase.inhale.isInhale == true, 'inhale.isInhale should be true');
  assert(BreathingPhase.inhaleHold.isHold == true, 'inhaleHold.isHold should be true');
  assert(BreathingPhase.exhale.isExhale == true, 'exhale.isExhale should be true');
  assert(BreathingPhase.exhaleHold.isHold == true, 'exhaleHold.isHold should be true');

  // 5. Verify SessionState immutability and copyWith
  const state = BreathingSessionState();
  assert(state.technique == BreathingTechnique.cyclicSighing, 'Default must be cyclic sighing');
  assert(state.phase == BreathingPhase.inhale, 'Default must be inhale');
  assert(state.isActive == false, 'Default must be inactive');

  final boxState = state.copyWith(technique: BreathingTechnique.boxBreathing, phase: BreathingPhase.inhaleHold);
  assert(boxState.technique == BreathingTechnique.boxBreathing);
  assert(boxState.phase == BreathingPhase.inhaleHold);

  print('=== All Respiration Engine Assertions PASSED successfully! (6/6 techniques validated) ===');
}
