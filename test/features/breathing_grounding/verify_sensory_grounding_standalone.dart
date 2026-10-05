import '../../../lib/features/breathing_grounding/domain/models/grounding_stage.dart';
import '../../../lib/features/breathing_grounding/domain/models/grounding_session_state.dart';

void main() {
  print('=== Verifying Extended Sensory Grounding Suite (FR-13) ===');

  // 1. Verify GroundingMode enum & properties
  assert(GroundingMode.values.length == 5, 'Expected exactly 5 grounding modes');
  for (final mode in GroundingMode.values) {
    assert(mode.label.isNotEmpty, 'Mode ${mode.name} label must not be empty');
    assert(mode.description.isNotEmpty, 'Mode ${mode.name} description must not be empty');
    assert(mode.stages.isNotEmpty, 'Mode ${mode.name} stages must not be empty');
    assert(mode.icon.codePoint > 0, 'Mode ${mode.name} icon codePoint must be valid');
    print('Mode: ${mode.name.padRight(14)} | Label: ${mode.label.padRight(20)} | Stages: ${mode.stages.length}');
  }

  // 2. Verify stage counts and target items per mode
  assert(GroundingMode.fiveSenses.stages.length == 5, 'fiveSenses should have 5 stages');
  assert(GroundingMode.textureHunt.stages.length == 3, 'textureHunt should have 3 stages');
  assert(GroundingMode.soundHunt.stages.length == 3, 'soundHunt should have 3 stages');
  assert(GroundingMode.colourSearch.stages.length == 4, 'colourSearch should have 4 stages');
  assert(GroundingMode.feetOnFloor.stages.length == 3, 'feetOnFloor should have 3 stages');

  // 3. Verify fromString resolution
  assert(GroundingMode.fromString('texturehunt') == GroundingMode.textureHunt);
  assert(GroundingMode.fromString('soundHunt') == GroundingMode.soundHunt);
  assert(GroundingMode.fromString('COLOURSEARCH') == GroundingMode.colourSearch);
  assert(GroundingMode.fromString('feetOnFloor') == GroundingMode.feetOnFloor);
  assert(GroundingMode.fromString('unknown_mode') == GroundingMode.fiveSenses);
  assert(GroundingMode.fromString(null) == GroundingMode.fiveSenses);
  print('✓ GroundingMode fromString resolution verified.');

  // 4. Verify Texture Hunt Mode stages and instructions
  final textureStages = GroundingMode.textureHunt.stages;
  assert(textureStages[0].sense == GroundingSense.touch);
  assert(textureStages[0].title.contains('smooth'));
  assert(textureStages[1].title.contains('rough') || textureStages[1].title.contains('textured'));
  assert(textureStages[2].title.contains('soft') || textureStages[2].title.contains('fabric'));
  print('✓ Texture Hunt 3-stage tactile progression verified.');

  // 5. Verify Sound Hunt Mode stages
  final soundStages = GroundingMode.soundHunt.stages;
  assert(soundStages.every((s) => s.sense == GroundingSense.hear));
  assert(soundStages[0].title.contains('nearest') || soundStages[0].title.contains('immediate'));
  assert(soundStages[1].title.contains('distant') || soundStages[1].title.contains('background'));
  assert(soundStages[2].title.contains('steady') || soundStages[2].title.contains('ambient'));
  print('✓ Sound Hunt acoustic stages verified.');

  // 6. Verify Colour Search Mode stages
  final colourStages = GroundingMode.colourSearch.stages;
  assert(colourStages.every((s) => s.sense == GroundingSense.see));
  assert(colourStages.length == 4);
  print('✓ Colour Search 4-palette visual stages verified.');

  // 7. Verify Feet on Floor Proprioceptive Grounding stages
  final feetStages = GroundingMode.feetOnFloor.stages;
  assert(feetStages.every((s) => s.sense == GroundingSense.proprioception));
  assert(feetStages.length == 3);
  print('✓ Feet on Floor proprioceptive stages verified.');

  // 8. Verify GroundingSessionState progression across modes
  for (final mode in GroundingMode.values) {
    var state = GroundingSessionState(mode: mode);
    assert(state.mode == mode);
    assert(state.currentStageIndex == 0);
    assert(state.currentStageNoticedCount == 0);
    assert(state.isCompleted == false);
    assert(state.overallProgress == 0.0);

    // Step through each stage
    for (int i = 0; i < state.stages.length; i++) {
      assert(state.currentStageIndex == i);
      assert(state.currentStage == state.stages[i]);
      assert(state.targetCount == state.stages[i].targetCount);

      // Notice items up to target
      state = state.copyWith(currentStageNoticedCount: state.targetCount);
      assert(state.isCurrentStageComplete == true);

      if (i < state.stages.length - 1) {
        state = state.copyWith(
          currentStageIndex: i + 1,
          currentStageNoticedCount: 0,
        );
      } else {
        state = state.copyWith(isCompleted: true);
      }
    }

    assert(state.isCompleted == true);
    assert(state.overallProgress == 1.0);
    print('✓ Mode ${mode.name} progression & progress calculations verified.');
  }

  print('=== ALL Extended Sensory Grounding Assertions PASSED successfully! (5/5 modes validated) ===');
}
