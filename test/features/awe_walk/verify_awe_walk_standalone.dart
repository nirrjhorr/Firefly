import 'dart:convert';
import 'dart:io';

import '../../../lib/core/recommendation_engine/models/action_suggestion.dart';
import '../../../lib/core/routing/app_routes.dart';
import '../../../lib/features/awe_walk/data/repositories/awe_walk_repository_impl.dart';
import '../../../lib/features/awe_walk/domain/models/awe_prompt.dart';
import '../../../lib/features/awe_walk/domain/models/awe_walk_phase.dart';
import '../../../lib/features/awe_walk/domain/models/awe_walk_session.dart';

void main() async {
  stdout.writeln('======================================================================');
  stdout.writeln('      FIREFLY EPIC 22: AWE WALK PROTOCOL STANDALONE AUDIT            ');
  stdout.writeln('======================================================================');

  // -------------------------------------------------------------------------
  // 1. AweWalkPhase State Machine & Metadata
  // -------------------------------------------------------------------------
  stdout.writeln('\n[1/6] Verifying AweWalkPhase Enum & State Machine Order...');
  assert(AweWalkPhase.values.length == 5, 'Must have exactly 5 phases');
  assert(AweWalkPhase.preparation.stepNumber == 1, 'Prep must be step 1');
  assert(AweWalkPhase.vastness.stepNumber == 2, 'Vastness must be step 2');
  assert(AweWalkPhase.smallSelf.stepNumber == 3, 'SmallSelf must be step 3');
  assert(AweWalkPhase.gratitude.stepNumber == 4, 'Gratitude must be step 4');
  assert(AweWalkPhase.complete.stepNumber == 5, 'Complete must be step 5');

  for (final phase in AweWalkPhase.values) {
    assert(phase.title.isNotEmpty, 'Phase title must not be empty');
    assert(phase.shortLabel.isNotEmpty, 'Phase shortLabel must not be empty');
    assert(phase.guidancePrompt.isNotEmpty, 'Phase guidancePrompt must not be empty');
  }
  stdout.writeln('  ✓ 5 protocol phases verified with non-empty titles and guidance prompts.');

  // -------------------------------------------------------------------------
  // 2. AwePrompt Curated Catalog & Modalities
  // -------------------------------------------------------------------------
  stdout.writeln('\n[2/6] Verifying Curated AwePrompts & Sensory Modalities...');
  final prompts = AwePrompt.curatedPrompts;
  assert(prompts.length == 5, 'Must have 5 evidence-based prompts from Sturm et al. 2020');
  
  final ids = prompts.map((p) => p.id).toSet();
  assert(ids.length == 5, 'All prompt IDs must be unique');

  for (final p in prompts) {
    assert(p.title.isNotEmpty, 'Prompt title required');
    assert(p.instruction.isNotEmpty, 'Prompt instruction required');
    assert(p.reflectionCue.isNotEmpty, 'Reflection cue required');
    assert(p.suggestedSeconds > 0, 'Suggested seconds must be positive');
    assert(p.modality.displayName.isNotEmpty, 'Modality displayName required');

    // JSON round-trip
    final json = p.toJson();
    final restored = AwePrompt.fromJson(json);
    assert(restored.id == p.id, 'Prompt id must match after JSON cycle');
    assert(restored.title == p.title, 'Prompt title must match after JSON cycle');
    assert(restored.modality == p.modality, 'Prompt modality must match after JSON cycle');
  }
  stdout.writeln('  ✓ 5 curated prompts and JSON serialization validated.');

  // -------------------------------------------------------------------------
  // 3. AweWalkSession Domain Model & Invariants
  // -------------------------------------------------------------------------
  stdout.writeln('\n[3/6] Verifying AweWalkSession Invariants & Calculations...');
  final session5 = AweWalkSession.create(durationMinutes: 5);
  final session10 = AweWalkSession.create(durationMinutes: 10);
  final session15 = AweWalkSession.create(durationMinutes: 15);

  assert(session5.totalTargetSeconds == 300, '5 min = 300s');
  assert(session10.totalTargetSeconds == 600, '10 min = 600s');
  assert(session15.totalTargetSeconds == 900, '15 min = 900s');

  assert(session10.progressFraction == 0.0, 'Initial progress must be 0.0');
  assert(!session10.isComplete, 'Initial session is not complete');

  final halfway = session10.copyWith(elapsedSeconds: 300);
  assert((halfway.progressFraction - 0.5).abs() < 0.001, 'Halfway progress must be 0.5');

  final finished = session10.copyWith(
    elapsedSeconds: 650,
    currentPhase: AweWalkPhase.complete,
    completedPromptIds: ['awe_panoramic_horizon', 'awe_canopy_sky'],
    anchorDetail: 'Ancient moss pattern on wet granite',
    ratingShift: 2,
    completedAt: DateTime.now(),
  );
  assert(finished.progressFraction == 1.0, 'Progress must clamp to 1.0');
  assert(finished.isComplete, 'Finished session must be complete');

  // JSON round-trip for session
  final sessionJson = finished.toJson();
  final restoredSession = AweWalkSession.fromJson(sessionJson);
  assert(restoredSession.id == finished.id, 'Session id preserved');
  assert(restoredSession.targetDurationMinutes == 10, 'Target duration preserved');
  assert(restoredSession.currentPhase == AweWalkPhase.complete, 'Phase preserved');
  assert(restoredSession.completedPromptIds.length == 2, 'Completed prompts preserved');
  assert(restoredSession.anchorDetail == 'Ancient moss pattern on wet granite', 'Anchor preserved');
  assert(restoredSession.ratingShift == 2, 'Rating shift preserved');
  stdout.writeln('  ✓ Session calculations, clamping, and full JSON round-trip verified.');

  // -------------------------------------------------------------------------
  // 4. AweWalkRepository Offline Storage Operations
  // -------------------------------------------------------------------------
  stdout.writeln('\n[4/6] Verifying AweWalkRepository Offline Storage...');
  final repository = AweWalkRepositoryImpl();
  assert(repository.getCuratedPrompts().length == 5, 'Repository provides prompts');

  final initialRecent = await repository.getRecentSessions();
  assert(initialRecent.isEmpty, 'Initial repository has 0 sessions');
  assert(await repository.getCompletedCount() == 0, 'Initial completed count is 0');

  await repository.saveSession(finished);
  final afterSave = await repository.getRecentSessions();
  assert(afterSave.length == 1, 'Must have 1 saved session');
  assert(afterSave.first.id == finished.id, 'Saved session ID matches');
  assert(await repository.getCompletedCount() == 1, 'Completed count is now 1');

  // Upsert update
  final updatedFinished = finished.copyWith(anchorDetail: 'Updated pine canopy');
  await repository.saveSession(updatedFinished);
  final afterUpdate = await repository.getRecentSessions();
  assert(afterUpdate.length == 1, 'Session count remains 1 after update');
  assert(afterUpdate.first.anchorDetail == 'Updated pine canopy', 'Updated anchor saved');
  stdout.writeln('  ✓ Offline repository persistence and session upsert verified.');

  // -------------------------------------------------------------------------
  // 5. Activity Catalog & Curated JSON Seeding Verification
  // -------------------------------------------------------------------------
  stdout.writeln('\n[5/6] Verifying Activity Catalog Seeding (curated_activities.json)...');
  final catalogFile = File('assets/data/curated_activities.json');
  assert(await catalogFile.exists(), 'curated_activities.json must exist');

  final catalogContent = await catalogFile.readAsString();
  final List<dynamic> rawCatalog = jsonDecode(catalogContent) as List<dynamic>;

  stdout.writeln('  • Total catalog activities count: ${rawCatalog.length}');
  assert(rawCatalog.length == 76, 'Catalog must contain exactly 76 activities (75 prior + act_awe_walk)');

  final aweWalkEntry = rawCatalog.firstWhere(
    (e) => e['id'] == 'act_awe_walk',
    orElse: () => null,
  );
  assert(aweWalkEntry != null, 'act_awe_walk entry must be present in catalog');
  assert(aweWalkEntry['title'] == 'Awe Walk Protocol', 'Title matches');
  assert(aweWalkEntry['category'] == 'nature', 'Category is nature');
  assert(aweWalkEntry['energyRequired'] == 2, 'Energy requirement is 2');
  assert(aweWalkEntry['route'] == '/home/awe-walk', 'Route is /home/awe-walk');
  assert(aweWalkEntry['durationMinutes'] == 10, 'Duration is 10 min');
  assert(aweWalkEntry['guidanceType'] == 'stepper', 'Guidance type is stepper');
  assert(aweWalkEntry['evidenceLevel'] == 'verified', 'Evidence level is verified');

  final targetStates = List<String>.from(aweWalkEntry['targetStates'] as List<dynamic>);
  assert(targetStates.contains('racingThoughts'), 'Target state contains racingThoughts');
  assert(targetStates.contains('anxious'), 'Target state contains anxious');
  assert(targetStates.contains('overwhelmed'), 'Target state contains overwhelmed');

  final instructions = List<String>.from(aweWalkEntry['instructions'] as List<dynamic>);
  assert(instructions.length == 5, 'Must have 5 sequential instructions');
  stdout.writeln('  ✓ act_awe_walk verified in curated_activities.json with correct metadata.');

  // -------------------------------------------------------------------------
  // 6. Routing Constants & Recommendation Engine ActionType
  // -------------------------------------------------------------------------
  stdout.writeln('\n[6/6] Verifying Route Constants & ActionType Integration...');
  assert(AppRoutes.aweWalk == '/home/awe-walk', 'AppRoutes.aweWalk matches');
  assert(AppRoutes.modalAweWalk == '/awe-walk', 'AppRoutes.modalAweWalk matches');

  assert(ActionType.values.contains(ActionType.aweWalk), 'ActionType contains aweWalk');
  assert(ActionType.fromString('aweWalk') == ActionType.aweWalk, 'ActionType.fromString matches');

  stdout.writeln('  ✓ Routes and ActionType integration verified.');

  stdout.writeln('\n======================================================================');
  stdout.writeln('   SUCCESS: ALL EPIC 22 AWE WALK VERIFICATION CHECKS PASSED (100%)    ');
  stdout.writeln('======================================================================');
}
