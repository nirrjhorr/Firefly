import 'dart:convert';
import 'dart:io';

import '../../../lib/core/routing/app_routes.dart';
import '../../../lib/features/activities/domain/models/activity_category.dart';
import '../../../lib/features/cognitive_defusion/domain/models/defusion_mode.dart';
import '../../../lib/features/cognitive_defusion/domain/models/defusion_session_state.dart';
import '../../../lib/features/cognitive_defusion/domain/models/defusion_thought.dart';

void main() {
  stdout.writeln('=== Verifying Story 14.2: Cognitive Defusion Prompts & Thought Distance Suite ===');

  // 1. Verify DefusionMode Enum & Resolution
  assert(DefusionMode.values.length == 3, 'Expected 3 defusion modes');
  for (final mode in DefusionMode.values) {
    assert(mode.displayName.isNotEmpty, 'Display name must not be empty');
    assert(mode.description.isNotEmpty, 'Description must not be empty');
    assert(mode.iconKey.isNotEmpty, 'IconKey must not be empty');
    stdout.writeln('Mode: ${mode.name.padRight(18)} | Display: ${mode.displayName.padRight(24)} | Icon: ${mode.iconKey}');
  }

  assert(DefusionMode.fromString('leaves') == DefusionMode.leavesOnStream);
  assert(DefusionMode.fromString('STREAM') == DefusionMode.leavesOnStream);
  assert(DefusionMode.fromString('clouds') == DefusionMode.thoughtClouds);
  assert(DefusionMode.fromString('THOUGHTCLOUDS') == DefusionMode.thoughtClouds);
  assert(DefusionMode.fromString('labeling') == DefusionMode.thoughtLabeling);
  assert(DefusionMode.fromString('labelling') == DefusionMode.thoughtLabeling);
  assert(DefusionMode.fromString('unknown') == DefusionMode.leavesOnStream);
  stdout.writeln('✓ DefusionMode enum resolution and string matching verified.');

  // 2. Verify Curated Starter Prompts
  assert(kCuratedDefusionPrompts.length >= 10, 'Expected at least 10 starter prompts');
  for (final p in kCuratedDefusionPrompts) {
    assert(p.trim().isNotEmpty, 'Prompt must not be empty');
  }
  stdout.writeln('✓ Curated starter prompts validated (${kCuratedDefusionPrompts.length} prompts).');

  // 3. Verify DefusionThought Model
  final thought = DefusionThought.create(text: 'I must get everything right');
  assert(thought.id.startsWith('dt_'), 'ID format mismatch');
  assert(thought.text == 'I must get everything right', 'Text mismatch');
  assert(thought.driftProgress == 0.0, 'Initial progress must be 0');
  assert(!thought.isDissolved, 'Must not be dissolved initially');
  assert(thought.horizontalOffset >= -0.5 && thought.horizontalOffset <= 0.5, 'Offset out of bounds');

  final progressed = thought.copyWith(driftProgress: 0.5, isDissolved: true);
  assert(progressed.driftProgress == 0.5, 'Progress update failed');
  assert(progressed.isDissolved == true, 'Dissolved flag update failed');
  assert(progressed.id == thought.id, 'ID must remain invariant across copyWith');
  stdout.writeln('✓ DefusionThought immutable model lifecycle verified.');

  // 4. Verify 3-Tier Linguistic Defusion Text Transformation
  final state = DefusionSessionState.initial();
  assert(state.activeMode == DefusionMode.leavesOnStream, 'Initial mode mismatch');
  assert(state.labelingStep == 1, 'Initial labeling step must be 1');

  final customState = state.copyWith(
    labelingThoughtText: 'I am failing',
    labelingStep: 1,
  );
  assert(customState.formattedLabelingText == '"I am failing"', 'Step 1 text mismatch');

  final step2 = customState.copyWith(labelingStep: 2);
  assert(step2.formattedLabelingText.contains('I notice I am having the thought that'), 'Step 2 missing noticing phrase');
  assert(step2.formattedLabelingText.contains('"I am failing"'), 'Step 2 missing thought');

  final step3 = customState.copyWith(labelingStep: 3);
  assert(step3.formattedLabelingText.contains('story'), 'Step 3 missing story phrase');
  assert(step3.formattedLabelingText.contains('observing it'), 'Step 3 missing observer phrase');
  stdout.writeln('✓ 3-tier linguistic defusion step transformations verified.');

  // 5. Verify AppRoutes Integration
  assert(AppRoutes.defusion == '/home/defusion', 'Defusion route constant mismatch');
  stdout.writeln('✓ AppRoutes.defusion verified: ${AppRoutes.defusion}');

  // 6. Verify ActivityCategory.cognitiveDefusion
  final defusionCategory = ActivityCategory.fromString('cognitiveDefusion');
  assert(defusionCategory == ActivityCategory.cognitiveDefusion, 'Category resolution mismatch');
  assert(defusionCategory.displayName == 'Thought Distance', 'Category display mismatch');
  assert(defusionCategory.iconKey == 'cloud', 'Category icon mismatch');
  stdout.writeln('✓ ActivityCategory.cognitiveDefusion properties verified.');

  // 7. Verify JSON Catalog Entries
  final catalogFile = File('assets/data/curated_activities.json');
  assert(catalogFile.existsSync(), 'Catalog file must exist');
  final dynamic decoded = jsonDecode(catalogFile.readAsStringSync());
  assert(decoded is List, 'Catalog must be a list');
  final activities = (decoded as List).cast<Map<String, dynamic>>();

  final leavesActivity = activities.firstWhere(
    (a) => a['id'] == 'act_defusion_leaves_stream',
    orElse: () => throw Exception('act_defusion_leaves_stream missing from JSON catalog'),
  );
  assert(leavesActivity['category'] == 'cognitiveDefusion', 'Category mismatch for leaves');
  assert(leavesActivity['route'] == '/home/defusion?mode=leaves', 'Route mismatch for leaves');

  final cloudsActivity = activities.firstWhere(
    (a) => a['id'] == 'act_defusion_thought_clouds',
    orElse: () => throw Exception('act_defusion_thought_clouds missing from JSON catalog'),
  );
  assert(cloudsActivity['category'] == 'cognitiveDefusion', 'Category mismatch for clouds');
  assert(cloudsActivity['route'] == '/home/defusion?mode=clouds', 'Route mismatch for clouds');

  final labelingActivity = activities.firstWhere(
    (a) => a['id'] == 'act_defusion_thought_labeling',
    orElse: () => throw Exception('act_defusion_thought_labeling missing from JSON catalog'),
  );
  assert(labelingActivity['category'] == 'cognitiveDefusion', 'Category mismatch for labeling');
  assert(labelingActivity['route'] == '/home/defusion?mode=labeling', 'Route mismatch for labeling');

  stdout.writeln('✓ Curated activities act_defusion_leaves_stream, act_defusion_thought_clouds, and act_defusion_thought_labeling validated in JSON catalog.');

  stdout.writeln('=== ALL Story 14.2 Standalone Assertions PASSED successfully! (100% Validated) ===');
}
