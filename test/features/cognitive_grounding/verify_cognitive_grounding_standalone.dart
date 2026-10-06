import '../../../lib/features/cognitive_grounding/domain/models/cognitive_exercise.dart';
import '../../../lib/features/cognitive_grounding/domain/models/cognitive_session_state.dart';

void main() {
  print('=== Verifying Cognitive Grounding & Attention Switching Engine (FR-14) ===');

  // 1. Verify CognitiveExerciseType enum & properties
  assert(CognitiveExerciseType.values.length == 4, 'Expected exactly 4 cognitive exercise types');
  for (final type in CognitiveExerciseType.values) {
    assert(type.displayName.isNotEmpty, 'Type ${type.name} displayName must not be empty');
    assert(type.description.isNotEmpty, 'Type ${type.name} description must not be empty');
    assert(type.iconKey.isNotEmpty, 'Type ${type.name} iconKey must not be empty');
    print('Exercise: ${type.name.padRight(20)} | Display: ${type.displayName.padRight(22)} | Icon: ${type.iconKey}');
  }

  // 2. Verify fromString resolution
  assert(CognitiveExerciseType.fromString('alphabetcategories') == CognitiveExerciseType.alphabetCategories);
  assert(CognitiveExerciseType.fromString('backwardCounting') == CognitiveExerciseType.backwardCounting);
  assert(CognitiveExerciseType.fromString('WORDASSOCIATION') == CognitiveExerciseType.wordAssociation);
  assert(CognitiveExerciseType.fromString('memorySequence') == CognitiveExerciseType.memorySequence);
  assert(CognitiveExerciseType.fromString('unknown_type') == CognitiveExerciseType.alphabetCategories);
  print('✓ CognitiveExerciseType fromString resolution verified.');

  assert(kOfflineCognitiveCategories.length >= 50, 'Should have at least 50 offline categories');
  for (final cat in kOfflineCognitiveCategories) {
    assert(cat.id.isNotEmpty && cat.name.isNotEmpty && cat.hint.isNotEmpty);
  }
  print('✓ Offline category prompts verified (${kOfflineCognitiveCategories.length} categories).');

  // 4. Verify Counting Configs & Word Chains
  assert(kCountingConfigs.length >= 3, 'Should have at least 3 counting configurations');
  assert(kWordAssociationChains.length >= 4, 'Should have at least 4 word association chains');
  print('✓ Counting configs & word association chains verified.');

  // 5. Test Alphabet Categories Progression & Logic
  var state = const CognitiveSessionState(
    exerciseType: CognitiveExerciseType.alphabetCategories,
  );
  assert(state.currentLetter == 'A');
  assert(state.progressFraction == 0.0);
  assert(state.activeCategory.name == kOfflineCognitiveCategories[0].name);

  // Advance from A to B
  state = state.copyWith(
    currentLetterIndex: state.currentLetterIndex + 1,
    completedSteps: state.completedSteps + 1,
  );
  assert(state.currentLetter == 'B');
  assert(state.completedSteps == 1);
  assert(state.progressFraction > 0.0);

  // Skip letter B -> C
  state = state.copyWith(currentLetterIndex: state.currentLetterIndex + 1);
  assert(state.currentLetter == 'C');
  assert(state.completedSteps == 1); // skip preserved completed steps

  // Rotate category
  state = state.copyWith(activeCategoryIndex: state.activeCategoryIndex + 1);
  assert(state.activeCategory.name == kOfflineCognitiveCategories[1].name);
  print('✓ Alphabet Categories letter advance, skip, and category rotation verified.');

  // 6. Test Backward Counting Mode Calculations
  var countState = const CognitiveSessionState(
    exerciseType: CognitiveExerciseType.backwardCounting,
    currentCount: 100,
    activeCountingConfigIndex: 0, // from 100 by 7s
  );
  assert(countState.currentCount == 100);
  assert(countState.activeCountingConfig.stepDown == 7);

  // Step down 100 -> 93
  countState = countState.copyWith(
    currentCount: countState.currentCount - countState.activeCountingConfig.stepDown,
    completedSteps: countState.completedSteps + 1,
  );
  assert(countState.currentCount == 93);
  assert(countState.completedSteps == 1);
  assert(countState.progressFraction == (7.0 / 100.0));

  // Change to 50 by 3s
  countState = countState.copyWith(
    activeCountingConfigIndex: 1,
    currentCount: kCountingConfigs[1].startNumber,
  );
  assert(countState.currentCount == 50);
  countState = countState.copyWith(
    currentCount: countState.currentCount - countState.activeCountingConfig.stepDown,
  );
  assert(countState.currentCount == 47);
  print('✓ Backward Counting step-down calculations and config switches verified.');

  // 7. Test Word Associations Mode
  var wordState = const CognitiveSessionState(
    exerciseType: CognitiveExerciseType.wordAssociation,
    activeChainIndex: 0,
    activeChainStep: 0,
  );
  assert(wordState.currentWord == kWordAssociationChains[0][0]);
  wordState = wordState.copyWith(activeChainStep: 1, completedSteps: 1);
  assert(wordState.currentWord == kWordAssociationChains[0][1]);
  print('✓ Word Association stream transitions verified.');

  // 8. Test Memory Sequence Mode
  var seqState = const CognitiveSessionState(
    exerciseType: CognitiveExerciseType.memorySequence,
    completedSteps: 0,
  );
  assert(seqState.progressFraction == 0.0);
  seqState = seqState.copyWith(completedSteps: 3);
  assert(seqState.progressFraction == (3.0 / 5.0));
  print('✓ Calm Sequence step transitions verified.');

  // 9. Test Reset functionality & Boundaries
  final resetState = const CognitiveSessionState(
    exerciseType: CognitiveExerciseType.alphabetCategories,
  );
  assert(resetState.completedSteps == 0);
  assert(!resetState.isCompleted);
  assert(resetState.currentLetter == 'A');
  print('✓ Session state reset verified.');

  print('=== ALL Cognitive Grounding Engine Assertions PASSED successfully! (4/4 modalities validated) ===');
}
