import 'dart:convert';
import 'dart:io';

import '../../../lib/core/routing/app_routes.dart';
import '../../../lib/features/nature/domain/models/nature_observation_mode.dart';
import '../../../lib/features/nature/domain/models/nature_prompt.dart';
import '../../../lib/features/nature/domain/models/nature_session_state.dart';

void expect(bool condition, String message) {
  if (!condition) {
    throw Exception('FAILED: $message');
  }
}

void main() {
  print('=== Verifying Guided Nature & Outdoor Micro-Observation Suite (Story 12.1) ===');

  testNatureModes();
  testOfflinePromptCatalog();
  testSessionStateProgression();
  testTimerAndSkipLogic();
  testAppRoutesAndCatalogAlignment();
  testZeroNetworkCompliance();

  print('\n=== ALL Nature Observation Verification Tests PASSED! (100% Validated) ===');
}

void testNatureModes() {
  print('\n1. Verifying NatureObservationMode enum and properties...');

  expect(NatureObservationMode.values.length == 5, 'Must define exactly 5 nature modes');

  final modes = [
    NatureObservationMode.skyGazing,
    NatureObservationMode.treeCanopy,
    NatureObservationMode.lightAndShadow,
    NatureObservationMode.outdoorGrounding,
    NatureObservationMode.weatherNotice,
  ];

  for (final mode in modes) {
    expect(mode.title.isNotEmpty, '${mode.name} must have a non-empty title');
    expect(mode.description.isNotEmpty, '${mode.name} must have a non-empty description');
    expect(mode.indoorAlternative.isNotEmpty, '${mode.name} must have an indoor alternative');
    expect(mode.iconKey.isNotEmpty, '${mode.name} must have an icon key');
  }

  expect(NatureObservationMode.fromString('skyGazing') == NatureObservationMode.skyGazing, 'skyGazing lookup');
  expect(NatureObservationMode.fromString('TREECANOPY') == NatureObservationMode.treeCanopy, 'treeCanopy uppercase lookup');
  expect(NatureObservationMode.fromString('unknown') == NatureObservationMode.skyGazing, 'Default fallback');

  print('✓ All 5 NatureObservationModes validated.');
}

void testOfflinePromptCatalog() {
  print('\n2. Verifying kOfflineNaturePrompts catalog completeness...');

  for (final mode in NatureObservationMode.values) {
    final prompts = kOfflineNaturePrompts[mode];
    expect(prompts != null, 'Mode ${mode.name} must have offline prompts defined');
    expect(prompts!.length == 4, 'Mode ${mode.name} should have 4 observation stages');

    for (int i = 0; i < prompts.length; i++) {
      final p = prompts[i];
      expect(p.id.isNotEmpty, 'Prompt id must not be empty');
      expect(p.stepNumber == i + 1, 'Prompt step number should be ${i + 1}');
      expect(p.stageTitle.isNotEmpty, 'Prompt stageTitle must not be empty');
      expect(p.cueText.isNotEmpty, 'Prompt cueText must not be empty');
      expect(p.reflectionCue.isNotEmpty, 'Prompt reflectionCue must not be empty');
      expect(p.sensoryAnchor.isNotEmpty, 'Prompt sensoryAnchor must not be empty');
    }
  }

  print('✓ kOfflineNaturePrompts has 20 high-quality offline observational cues.');
}

void testSessionStateProgression() {
  print('\n3. Verifying NatureSessionState step progression and completion...');

  var state = const NatureSessionState(mode: NatureObservationMode.skyGazing);

  expect(state.currentPromptIndex == 0, 'Initial index is 0');
  expect(state.completedPrompts == 0, 'Initial completed prompts is 0');
  expect(!state.isCompleted, 'Initial isCompleted is false');
  expect(!state.hasPrevious, 'Initial hasPrevious is false');
  expect(state.hasNext, 'Initial hasNext is true');
  expect(state.progressFraction == 0.0, 'Initial progress is 0.0');
  expect(state.currentPrompt.id == 'sky_1', 'Initial prompt is sky_1');

  // Advance step 1 -> step 2
  state = state.copyWith(
    currentPromptIndex: state.currentPromptIndex + 1,
    completedPrompts: state.completedPrompts + 1,
  );
  expect(state.currentPromptIndex == 1, 'Advanced to step 1');
  expect(state.completedPrompts == 1, 'Completed prompts is 1');
  expect(state.hasPrevious, 'hasPrevious is now true');
  expect(state.hasNext, 'hasNext is still true');
  expect(state.currentPrompt.id == 'sky_2', 'Prompt is sky_2');
  expect(state.progressFraction == 0.25, 'Progress is 0.25');

  // Advance step 2 -> step 3
  state = state.copyWith(
    currentPromptIndex: state.currentPromptIndex + 1,
    completedPrompts: state.completedPrompts + 1,
  );
  expect(state.currentPromptIndex == 2, 'Advanced to step 2');
  expect(state.completedPrompts == 2, 'Completed prompts is 2');
  expect(state.currentPrompt.id == 'sky_3', 'Prompt is sky_3');
  expect(state.progressFraction == 0.5, 'Progress is 0.5');

  // Advance step 3 -> step 4 (final step)
  state = state.copyWith(
    currentPromptIndex: state.currentPromptIndex + 1,
    completedPrompts: state.completedPrompts + 1,
  );
  expect(state.currentPromptIndex == 3, 'Advanced to step 3');
  expect(!state.hasNext, 'Final prompt has no next');
  expect(state.progressFraction == 0.75, 'Progress is 0.75');

  // Complete final step
  state = state.copyWith(
    completedPrompts: state.completedPrompts + 1,
    isCompleted: true,
  );
  expect(state.isCompleted, 'isCompleted is true');
  expect(state.progressFraction == 1.0, 'Final progress is 1.0');

  print('✓ State transitions and progression fractions calculated accurately.');
}

void testTimerAndSkipLogic() {
  print('\n4. Verifying soft timer toggling, tick, and non-judgmental skip...');

  var state = const NatureSessionState(mode: NatureObservationMode.treeCanopy);

  // Timer toggle
  expect(!state.isTimerActive, 'Initial timer is inactive');
  state = state.copyWith(isTimerActive: true);
  expect(state.isTimerActive, 'Timer is now active');

  // Ticks
  state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
  state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
  expect(state.elapsedSeconds == 2, 'Elapsed seconds is 2');

  // Non-judgmental skip
  final nextIndex = state.currentPromptIndex + 1;
  state = state.copyWith(currentPromptIndex: nextIndex);
  expect(state.currentPromptIndex == 1, 'Skipped to next prompt');
  expect(state.currentPrompt.id == 'tree_2', 'Prompt is tree_2');

  print('✓ Soft timer and skip mechanics verified.');
}

void testAppRoutesAndCatalogAlignment() {
  print('\n5. Verifying AppRoutes and curated_activities.json alignment...');

  expect(AppRoutes.nature == '/home/nature', 'AppRoutes.nature must equal /home/nature');

  final jsonFile = File('assets/data/curated_activities.json');
  expect(jsonFile.existsSync(), 'curated_activities.json must exist');

  final jsonString = jsonFile.readAsStringSync();
  final list = jsonDecode(jsonString) as List<dynamic>;

  final observationActivities = list
      .where((item) => (item['route'] as String).startsWith(AppRoutes.nature))
      .toList();
  expect(observationActivities.length == 5, 'Must have 5 micro-observation nature activities in curated catalog');

  for (final act in observationActivities) {
    expect(act['category'] == 'nature', 'Category must be nature');
    expect(act['title'] != null && (act['title'] as String).isNotEmpty, 'Title required');
    expect(act['instructions'] != null && (act['instructions'] as List).isNotEmpty, 'Instructions required');
  }

  print('✓ Curated activities catalog includes ${observationActivities.length} aligned micro-observation nature activities.');
}

void testZeroNetworkCompliance() {
  print('\n6. Verifying Zero Network compliance...');

  final modelsDir = Directory('lib/features/nature');
  final dartFiles = modelsDir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  for (final file in dartFiles) {
    final content = file.readAsStringSync();
    expect(!content.contains('http:'), 'No raw http calls permitted in ${file.path}');
    expect(!content.contains('package:http/'), 'No package:http permitted in ${file.path}');
    expect(!content.contains('package:dio/'), 'No package:dio permitted in ${file.path}');
  }

  print('✓ Zero network compliance verified across all Nature feature source files.');
}
