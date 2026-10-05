import '../../../lib/features/movement/domain/data/movement_catalog.dart';
import '../../../lib/features/movement/domain/models/movement_activity.dart';
import '../../../lib/features/movement/domain/models/movement_session_state.dart';

void main() {
  print('=== Verifying Movement & Somatic Release Engine Models ===');

  // 1. Verify MovementType definitions
  assert(MovementType.values.length == 4, 'Expected 4 movement types');
  for (final type in MovementType.values) {
    assert(type.displayName.isNotEmpty, '${type.name} displayName must not be empty');
    print('Type verified: ${type.name.padRight(16)} -> ${type.displayName}');
  }

  // 2. Verify MovementCatalog completeness & integrity
  assert(MovementCatalog.all.length >= 10, 'Expected at least 10 curated movement activities');
  final ids = <String>{};

  for (final act in MovementCatalog.all) {
    assert(ids.add(act.id), 'Duplicate activity ID found: ${act.id}');
    assert(act.title.isNotEmpty, 'Title must not be empty for ${act.id}');
    assert(act.description.isNotEmpty, 'Description must not be empty for ${act.id}');
    assert(act.energyRequired >= 1 && act.energyRequired <= 3, 'Energy must be 1..3 for ${act.id}');
    assert(act.instructions.isNotEmpty, 'Instructions list must not be empty for ${act.id}');
    assert(act.sensoryAnchor != null && act.sensoryAnchor!.isNotEmpty, 'Sensory anchor must be defined for ${act.id}');

    if (act.durationSeconds != null) {
      assert(act.durationSeconds! > 0, 'Duration must be positive for ${act.id}');
      assert(act.formattedDuration.isNotEmpty, 'Formatted duration must not be empty');
    }

    print('Activity [${act.type.name.padRight(14)}]: ${act.title.padRight(26)} | Energy: ${act.energyRequired} | Dur: ${act.formattedDuration.padRight(6)} | BPM: ${act.cadenceBpm ?? '-'}');
  }

  // 3. Verify Mode query resolution
  assert(MovementCatalog.findByIdOrMode('act_wall_pushups') == MovementCatalog.wallPushups);
  assert(MovementCatalog.findByIdOrMode('wallpushups') == MovementCatalog.wallPushups);
  assert(MovementCatalog.findByIdOrMode('shakeout') == MovementCatalog.quickShakeout);
  assert(MovementCatalog.findByIdOrMode('stroll') == MovementCatalog.groundedStroll);
  assert(MovementCatalog.findByIdOrMode('walking') == MovementCatalog.groundedStroll);
  assert(MovementCatalog.findByIdOrMode('shoulder_rolls') == MovementCatalog.shoulderRolls);
  assert(MovementCatalog.findByIdOrMode('marching') == MovementCatalog.marchInPlace);
  assert(MovementCatalog.findByIdOrMode('water') == MovementCatalog.drinkWater);
  assert(MovementCatalog.findByIdOrMode('unknown_mode') == MovementCatalog.quickShakeout, 'Fallback should be quickShakeout');
  assert(MovementCatalog.findByIdOrMode(null) == MovementCatalog.quickShakeout, 'Null should fallback to quickShakeout');
  print('Mode and ID resolution tests passed.');

  // 4. Verify category filtering
  final physicals = MovementCatalog.byType(MovementType.activePhysical);
  assert(physicals.isNotEmpty, 'Physical activities list must not be empty');
  for (final p in physicals) {
    assert(p.type == MovementType.activePhysical);
  }

  final somatics = MovementCatalog.byType(MovementType.somaticRelease);
  assert(somatics.isNotEmpty, 'Somatic activities list must not be empty');
  for (final s in somatics) {
    assert(s.type == MovementType.somaticRelease);
  }

  final routines = MovementCatalog.byType(MovementType.routineAction);
  assert(routines.isNotEmpty, 'Routine activities list must not be empty');
  for (final r in routines) {
    assert(r.type == MovementType.routineAction);
  }
  print('Category filtering tests passed.');

  // 5. Verify Session State and calculations
  const timedAct = MovementCatalog.quickShakeout; // 45 seconds
  final state = MovementSessionState(
    activity: timedAct,
    remainingSeconds: 45,
    status: MovementSessionStatus.idle,
  );

  assert(state.elapsedSeconds == 0);
  assert(state.remainingSeconds == 45);
  assert(state.progress == 0.0);
  assert(state.formattedDisplayTime == '00:45');
  assert(!state.status.isRunning);

  // Transition to running with 15s elapsed
  final runningState = state.copyWith(
    elapsedSeconds: 15,
    remainingSeconds: 30,
    status: MovementSessionStatus.active,
  );
  assert(runningState.status.isRunning);
  assert(runningState.formattedDisplayTime == '00:30');
  assert((runningState.progress - (15 / 45)).abs() < 0.001);

  // Transition to completion
  final completedState = runningState.copyWith(
    elapsedSeconds: 45,
    remainingSeconds: 0,
    status: MovementSessionStatus.completed,
  );
  assert(completedState.status.isDone);
  assert(completedState.progress == 1.0);
  assert(completedState.formattedDisplayTime == '00:00');

  // Verify open-ended activity (duration null)
  const openAct = MovementActivity(
    id: 'act_test_open',
    title: 'Open Walking',
    description: 'Test',
    type: MovementType.activePhysical,
    energyRequired: 2,
    instructions: ['Walk freely'],
    sensoryAnchor: 'Feel feet',
  );
  final openState = MovementSessionState(
    activity: openAct,
    elapsedSeconds: 65,
    status: MovementSessionStatus.active,
  );
  assert(openState.progress == 0.0);
  assert(openState.formattedDisplayTime == '01:05');

  print('=== All Movement & Somatic Release Domain Tests PASSED (100% verified)! ===');
}
