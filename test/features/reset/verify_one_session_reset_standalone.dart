import 'dart:convert';
import 'dart:io';

import '../../../lib/core/routing/app_routes.dart';
import '../../../lib/features/one_session_reset/data/repositories/reset_repository_impl.dart';
import '../../../lib/features/one_session_reset/domain/models/reset_distress_anchor.dart';
import '../../../lib/features/one_session_reset/domain/models/reset_phase.dart';
import '../../../lib/features/one_session_reset/domain/models/reset_session.dart';

void main() async {
  stdout.writeln('=== Verifying Epic 18: Single-Session Intervention (One-Session Reset) ===');

  // 1. Verify ResetPhase Progression & Contracts
  assert(ResetPhase.values.length == 5, 'Expected exactly 5 reset phases');
  assert(ResetPhase.anchor.stepNumber == 1, 'Anchor must be step 1');
  assert(ResetPhase.regulate.stepNumber == 2, 'Regulate must be step 2');
  assert(ResetPhase.reframe.stepNumber == 3, 'Reframe must be step 3');
  assert(ResetPhase.commit.stepNumber == 4, 'Commit must be step 4');
  assert(ResetPhase.complete.stepNumber == 5, 'Complete must be step 5');

  assert(!ResetPhase.anchor.hasPrevious, 'Anchor phase cannot have a previous step');
  assert(ResetPhase.anchor.hasNext, 'Anchor phase must have next step');
  assert(ResetPhase.regulate.hasPrevious, 'Regulate phase must have previous step');
  assert(ResetPhase.commit.hasNext, 'Commit phase must have next step');
  assert(!ResetPhase.complete.hasNext, 'Complete phase cannot have next step');

  for (final phase in ResetPhase.values) {
    assert(phase.title.isNotEmpty, 'Phase title must not be empty');
    assert(phase.shortLabel.isNotEmpty, 'Phase shortLabel must not be empty');
    assert(phase.guidancePrompt.isNotEmpty, 'Phase guidancePrompt must not be empty');
    stdout.writeln('Phase ${phase.stepNumber}: ${phase.title.padRight(22)} | Prompt: ${phase.guidancePrompt.substring(0, 35)}...');
  }
  stdout.writeln('✓ ResetPhase enum sequence and navigation constraints verified.');

  // 2. Verify ResetDistressAnchor Definitions
  assert(ResetDistressAnchor.values.length == 6, 'Expected 6 distress anchors');
  for (final anchor in ResetDistressAnchor.values) {
    assert(anchor.label.isNotEmpty, 'Anchor label must not be empty');
    assert(anchor.subtitle.isNotEmpty, 'Anchor subtitle must not be empty');
    assert(anchor.suggestedTechniqueName.isNotEmpty, 'Anchor technique must not be empty');
    assert(anchor.iconKey.isNotEmpty, 'Anchor iconKey must not be empty');
    stdout.writeln('Anchor: ${anchor.name.padRight(18)} | Technique: ${anchor.suggestedTechniqueName}');
  }
  stdout.writeln('✓ ResetDistressAnchor definitions and somatic pairings verified.');

  // 3. Verify ResetSession Data Model & JSON Roundtrip
  final initialSession = ResetSession.create();
  assert(initialSession.id.startsWith('reset_'), 'Session ID prefix mismatch');
  assert(initialSession.currentPhase == ResetPhase.anchor, 'Initial phase must be anchor');
  assert(!initialSession.isCompleted, 'New session must not be completed');

  final populatedSession = initialSession.copyWith(
    anchor: ResetDistressAnchor.racingThoughts,
    selectedTechnique: ResetDistressAnchor.racingThoughts.suggestedTechniqueName,
    reframeReflection: 'I do not have to solve everything tonight.',
    microCommitment: 'Drink one cool glass of water',
    effectivenessRating: 'muchBetter',
    completedAt: DateTime.now(),
    currentPhase: ResetPhase.complete,
  );

  assert(populatedSession.isCompleted, 'Session with completedAt must report isCompleted == true');

  final jsonMap = populatedSession.toJson();
  final roundtripSession = ResetSession.fromJson(jsonMap);

  assert(roundtripSession.id == populatedSession.id, 'ID roundtrip mismatch');
  assert(roundtripSession.anchor == populatedSession.anchor, 'Anchor roundtrip mismatch');
  assert(roundtripSession.selectedTechnique == populatedSession.selectedTechnique, 'Technique roundtrip mismatch');
  assert(roundtripSession.reframeReflection == populatedSession.reframeReflection, 'Reframe roundtrip mismatch');
  assert(roundtripSession.microCommitment == populatedSession.microCommitment, 'Commitment roundtrip mismatch');
  assert(roundtripSession.effectivenessRating == populatedSession.effectivenessRating, 'Rating roundtrip mismatch');
  assert(roundtripSession.currentPhase == populatedSession.currentPhase, 'Phase roundtrip mismatch');
  stdout.writeln('✓ ResetSession JSON serialization & deserialization roundtrip verified.');

  // 4. Verify ResetRepository Implementation
  final repository = ResetRepositoryImpl();
  await repository.saveResetSession(populatedSession);

  final list = await repository.getRecentResetSessions(limit: 5);
  assert(list.length == 1, 'Expected 1 saved session');
  assert(list.first.id == populatedSession.id, 'Retrieved session mismatch');

  // Updating session
  final updatedSession = populatedSession.copyWith(effectivenessRating: 'aLittleBetter');
  await repository.saveResetSession(updatedSession);
  final updatedList = await repository.getRecentResetSessions(limit: 5);
  assert(updatedList.length == 1, 'Expected still 1 session after update');
  assert(updatedList.first.effectivenessRating == 'aLittleBetter', 'Updated rating mismatch');
  stdout.writeln('✓ ResetRepositoryImpl operations verified.');

  // 5. Verify AppRoutes Constants
  assert(AppRoutes.reset == '/home/reset', 'AppRoutes.reset route mismatch');
  assert(AppRoutes.modalReset == '/reset', 'AppRoutes.modalReset route mismatch');
  stdout.writeln('✓ AppRoutes constants (/home/reset, /reset) verified.');

  // 6. Verify Catalog Seeding
  final catalogFile = File('assets/data/curated_activities.json');
  assert(catalogFile.existsSync(), 'curated_activities.json must exist');
  final rawJson = jsonDecode(catalogFile.readAsStringSync()) as List<dynamic>;

  final resetActivity = rawJson.firstWhere(
    (a) => a['id'] == 'act_one_session_reset',
    orElse: () => null,
  );
  assert(resetActivity != null, 'act_one_session_reset must exist in curated_activities.json');
  assert(resetActivity['route'] == AppRoutes.reset, 'Catalog route must match AppRoutes.reset');
  assert(resetActivity['title'] == 'One-Session Reset', 'Catalog title mismatch');
  stdout.writeln('✓ Catalog seeding in curated_activities.json verified (${rawJson.length} total activities).');

  stdout.writeln('\n=============================================================');
  stdout.writeln('SUCCESS: Epic 18 (One-Session Reset Engine) 100% VALIDATED!');
  stdout.writeln('=============================================================');
}
