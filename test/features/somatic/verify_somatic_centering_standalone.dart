import 'dart:convert';
import 'dart:io';

import '../../../lib/core/routing/app_routes.dart';
import '../../../lib/features/somatic/domain/models/somatic_exercise_mode.dart';
import '../../../lib/features/somatic/domain/models/somatic_prompt.dart';
import '../../../lib/features/somatic/domain/models/somatic_session_state.dart';

void expect(bool condition, String message) {
  if (!condition) {
    throw Exception('FAILED: $message');
  }
}

void main() {
  print('=== Verifying Somatic Visualizations & Body Centering Suite (Story 12.2) ===');

  testSomaticModes();
  testOfflinePromptCatalog();
  testSessionStateProgression();
  testCuratedCatalogAlignment();
  testZeroNetworkCompliance();

  print('\n=== ALL Somatic Centering Verification Tests PASSED! (100% Validated) ===');
}

void testSomaticModes() {
  print('\n1. Verifying SomaticExerciseMode enum and properties...');

  expect(SomaticExerciseMode.values.length == 4, 'Must define exactly 4 somatic modes');

  final modes = [
    SomaticExerciseMode.heavyBody,
    SomaticExerciseMode.warmHands,
    SomaticExerciseMode.mountainPosture,
    SomaticExerciseMode.mindfulPause,
  ];

  for (final mode in modes) {
    expect(mode.title.isNotEmpty, '${mode.name} must have a non-empty title');
    expect(mode.subtitle.isNotEmpty, '${mode.name} must have a non-empty subtitle');
    expect(mode.description.isNotEmpty, '${mode.name} must have a non-empty description');
    expect(mode.scientificMechanism.isNotEmpty, '${mode.name} must have a scientific mechanism');
    expect(mode.iconKey.isNotEmpty, '${mode.name} must have an icon key');
    expect(mode.suggestedDurationSeconds > 0, '${mode.name} must have a positive suggested duration');
  }

  expect(SomaticExerciseMode.fromString('heavyBody') == SomaticExerciseMode.heavyBody, 'heavyBody lookup');
  expect(SomaticExerciseMode.fromString('WARMHANDS') == SomaticExerciseMode.warmHands, 'warmHands uppercase lookup');
  expect(SomaticExerciseMode.fromString('mountainposture') == SomaticExerciseMode.mountainPosture, 'case insensitive lookup');
  expect(SomaticExerciseMode.fromString('unknown_mode') == SomaticExerciseMode.heavyBody, 'Default fallback');

  print('✓ All 4 SomaticExerciseModes validated.');
}

void testOfflinePromptCatalog() {
  print('\n2. Verifying kOfflineSomaticPrompts catalog completeness...');

  for (final mode in SomaticExerciseMode.values) {
    final prompts = kOfflineSomaticPrompts[mode];
    expect(prompts != null, 'Mode ${mode.name} must have offline prompts defined');
    expect(prompts!.isNotEmpty, 'Mode ${mode.name} must have prompts');

    if (mode == SomaticExerciseMode.mindfulPause) {
      expect(prompts.length == 3, 'Mindful pause should have 3 stages');
    } else {
      expect(prompts.length == 4, 'Full somatic exercises should have 4 stages');
    }

    for (int i = 0; i < prompts.length; i++) {
      final p = prompts[i];
      expect(p.id.isNotEmpty, 'Prompt id must not be empty');
      expect(p.stageNumber == i + 1, 'Stage step number should be ${i + 1}');
      expect(p.stageTitle.isNotEmpty, 'Stage stageTitle must not be empty');
      expect(p.guidanceText.isNotEmpty, 'Stage guidanceText must not be empty');
      expect(p.sensationFocus.isNotEmpty, 'Stage sensationFocus must not be empty');
      expect(p.breathingAnchor.isNotEmpty, 'Stage breathingAnchor must not be empty');
      expect(p.durationSeconds > 0, 'Stage durationSeconds must be positive');
    }
  }

  final totalCues = kOfflineSomaticPrompts.values.fold(0, (acc, list) => acc + list.length);
  expect(totalCues == 15, 'Total offline cues should equal 15 across 4 modes (4+4+4+3)');
  print('✓ kOfflineSomaticPrompts has $totalCues clinically-informed offline somatic guidance stages.');
}

void testSessionStateProgression() {
  print('\n3. Verifying SomaticSessionState step progression and completion...');

  var state = const SomaticSessionState(mode: SomaticExerciseMode.heavyBody);
  expect(state.currentStageIndex == 0, 'Initial stage should be 0');
  expect(state.completedStages == 0, 'Initial completed stages should be 0');
  expect(state.isCompleted == false, 'Should not be complete at start');
  expect(state.progress == 0.0, 'Initial progress should be 0.0');
  expect(!state.isLastStage, 'First stage of 4 is not last');

  final currentPrompt = state.currentStage;
  expect(currentPrompt != null, 'Current stage prompt must not be null');
  expect(currentPrompt!.id == 'heavy_1_support', 'First prompt should be heavy_1_support');

  // Advance stage 1 -> 2
  state = state.copyWith(
    currentStageIndex: 1,
    completedStages: 1,
  );
  expect(state.currentStageIndex == 1, 'Stage should be index 1');
  expect(state.completedStages == 1, 'Completed count should be 1');
  expect(state.progress == 0.25, 'Progress should be 1/4 = 0.25');

  // Advance stage 2 -> 3
  state = state.copyWith(
    currentStageIndex: 2,
    completedStages: 2,
  );
  expect(state.progress == 0.50, 'Progress should be 2/4 = 0.50');

  // Advance to last stage (index 3)
  state = state.copyWith(
    currentStageIndex: 3,
    completedStages: 3,
  );
  expect(state.isLastStage, 'Index 3 of 4 stages is the last stage');
  expect(state.progress == 0.75, 'Progress should be 3/4 = 0.75');

  // Complete exercise
  state = state.copyWith(
    completedStages: 4,
    isCompleted: true,
  );
  expect(state.isCompleted, 'State is completed');
  expect(state.progress == 1.0, 'Progress is 100%');

  // Audio and timer toggling
  state = state.copyWith(isAudioPlaying: true, isTimerActive: false, elapsedSeconds: 120);
  expect(state.isAudioPlaying, 'Audio flag set');
  expect(!state.isTimerActive, 'Timer toggle flag');
  expect(state.elapsedSeconds == 120, 'Elapsed seconds recorded');

  print('✓ State transitions, step indices, and progress fraction calculated accurately.');
}

void testCuratedCatalogAlignment() {
  print('\n4. Verifying AppRoutes and curated_activities.json alignment...');

  expect(AppRoutes.somatic == '/home/somatic', 'AppRoutes.somatic must match /home/somatic');

  final file = File('assets/data/curated_activities.json');
  expect(file.existsSync(), 'assets/data/curated_activities.json must exist');

  final content = file.readAsStringSync();
  final List<dynamic> jsonList = jsonDecode(content);

  final somaticActivities = jsonList.where((item) =>
    (item['id'] as String).startsWith('act_somatic_')
  ).toList();

  expect(somaticActivities.length == 4, 'Must have exactly 4 somatic activities seeded');

  final expectedIds = [
    'act_somatic_heavy_body',
    'act_somatic_warm_hands',
    'act_somatic_mountain_posture',
    'act_somatic_mindful_pause',
  ];

  for (final id in expectedIds) {
    final activity = somaticActivities.firstWhere(
      (a) => a['id'] == id,
      orElse: () => null,
    );
    expect(activity != null, 'Catalog must contain activity $id');
    expect((activity['title'] as String).isNotEmpty, '$id must have title');
    expect((activity['description'] as String).isNotEmpty, '$id must have description');
    expect(activity['category'] == 'mindfulness', '$id category must be mindfulness');
    expect(activity['energyRequired'] == 1, '$id energyRequired must be low (1)');
    expect((activity['route'] as String).startsWith('/home/somatic?mode='), '$id route must point to /home/somatic');
    expect(activity['durationMinutes'] is int && activity['durationMinutes'] > 0, '$id duration must be valid');
  }

  print('✓ Curated activities catalog includes 4 aligned somatic centering activities.');
}

void testZeroNetworkCompliance() {
  print('\n5. Verifying Zero Network compliance...');

  final dir = Directory('lib/features/somatic');
  expect(dir.existsSync(), 'lib/features/somatic directory must exist');

  final files = dir.listSync(recursive: true).whereType<File>();
  for (final f in files) {
    if (!f.path.endsWith('.dart')) continue;
    final code = f.readAsStringSync();

    expect(!code.contains('package:http/'), 'Zero network violation: package:http in ${f.path}');
    expect(!code.contains('package:dio/'), 'Zero network violation: package:dio in ${f.path}');
    expect(!code.contains('HttpClient('), 'Zero network violation: HttpClient in ${f.path}');
    expect(!code.contains('http://') && !code.contains('https://'), 'Zero network violation: hardcoded remote URL in ${f.path}');
  }

  print('✓ Zero network compliance verified across all Somatic feature source files.');
}
