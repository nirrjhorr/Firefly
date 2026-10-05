import '../../../lib/features/pmr/domain/models/pmr_zone.dart';

void main() {
  print('=== Verifying Progressive Muscle Relaxation (PMR) Models ===');

  // 1. Verify 10 anatomical zones
  assert(PmrMuscleZone.values.length == 10, 'Expected 10 PMR muscle zones');
  for (final zone in PmrMuscleZone.values) {
    assert(zone.displayName.isNotEmpty, '${zone.name} displayName must not be empty');
    assert(zone.tenseInstruction.isNotEmpty, '${zone.name} tenseInstruction must not be empty');
    assert(zone.releaseInstruction.isNotEmpty, '${zone.name} releaseInstruction must not be empty');
    assert(zone.relativeCenterY >= 0.0 && zone.relativeCenterY <= 1.0, '${zone.name} relativeCenterY must be between 0 and 1');
    print('Zone: ${zone.displayName.padRight(22)} | Y: ${zone.relativeCenterY} | Tense: ${zone.tenseInstruction.substring(0, 25)}...');
  }

  // 2. Verify 4 clinical phases & durations
  assert(PmrPhase.values.length == 4, 'Expected 4 PMR phases');
  assert(PmrPhase.tense.durationSeconds == 5, 'Tense duration should be 5s');
  assert(PmrPhase.hold.durationSeconds == 3, 'Hold duration should be 3s');
  assert(PmrPhase.release.durationSeconds == 10, 'Release duration should be 10s');
  assert(PmrPhase.notice.durationSeconds == 5, 'Notice duration should be 5s');

  final totalZoneDuration = PmrPhase.values.fold<int>(0, (sum, p) => sum + p.durationSeconds);
  assert(totalZoneDuration == 23, 'Total time per zone should be 23 seconds');
  print('Single zone cycle duration: ${totalZoneDuration}s (5s tense + 3s hold + 10s release + 5s notice)');

  // 3. Verify standard vs quick sequence
  const state = PmrSessionState();
  assert(state.zones.length == 10, 'Default state must have 10 zones');
  assert(state.currentZoneIndex == 0, 'Initial zone index must be 0');
  assert(state.currentZone == PmrMuscleZone.forehead, 'First zone must be forehead');
  assert(state.phase == PmrPhase.tense, 'Initial phase must be tense');
  assert(state.isActive == false, 'Initial state must be inactive');

  // 4. Verify quick mode state
  const quickZones = [
    PmrMuscleZone.face,
    PmrMuscleZone.neckShoulders,
    PmrMuscleZone.handsArms,
    PmrMuscleZone.stomach,
    PmrMuscleZone.calvesFeet,
  ];
  final quickState = state.copyWith(zones: quickZones, isQuickMode: true);
  assert(quickState.zones.length == 5, 'Quick mode must have 5 zones');
  assert(quickState.currentZone == PmrMuscleZone.face, 'First quick zone must be face');

  // 5. Verify state copyWith transitions
  final nextZoneState = quickState.copyWith(currentZoneIndex: 1, phase: PmrPhase.release, phaseProgress: 0.5);
  assert(nextZoneState.currentZone == PmrMuscleZone.neckShoulders);
  assert(nextZoneState.phase == PmrPhase.release);
  assert(nextZoneState.phaseProgress == 0.5);

  print('=== All PMR Domain Models & Timings PASSED successfully! (10/10 zones validated) ===');
}
