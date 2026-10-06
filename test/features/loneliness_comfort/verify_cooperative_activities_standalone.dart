import 'dart:convert';
import 'dart:io';

import '../../../lib/core/routing/app_routes.dart';
import '../../../lib/features/activities/domain/models/activity_category.dart';
import '../../../lib/features/loneliness_comfort/domain/models/cooperative_activity.dart';
import '../../../lib/features/loneliness_comfort/domain/models/loneliness_comfort_state.dart';
import '../../../lib/features/loneliness_comfort/domain/models/reach_out_contact.dart';
import '../../../lib/features/loneliness_comfort/domain/models/social_prediction_experiment.dart';

void main() {
  stdout.writeln('=== Verifying Story 15.2: Social Connection & Cooperative Activities ===');

  // 1. Verify CooperativeActivity Domain Model & Curated Catalog
  assert(kCuratedCooperativeActivities.length >= 4, 'Expected at least 4 curated cooperative activities');
  for (final act in kCuratedCooperativeActivities) {
    assert(act.id.isNotEmpty, 'ID must not be empty');
    assert(act.title.isNotEmpty, 'Title must not be empty');
    assert(act.subtitle.isNotEmpty, 'Subtitle must not be empty');
    assert(act.category.isNotEmpty, 'Category must not be empty');
    assert(act.iconKey.isNotEmpty, 'IconKey must not be empty');
    assert(act.description.isNotEmpty, 'Description must not be empty');
    assert(act.evidenceNote.isNotEmpty, 'Evidence note must not be empty');
    assert(act.suggestedInvitation.isNotEmpty, 'Suggested invitation must not be empty');
    stdout.writeln('Activity: ${act.id.padRight(22)} | Title: ${act.title.padRight(36)} | Games: ${act.suggestedGames.length}');
  }

  // Verify Parallel Quiet
  final parallelQuiet = kCuratedCooperativeActivities.firstWhere((a) => a.id == 'parallel_quiet');
  assert(parallelQuiet.category == 'Shared Presence', 'Category mismatch for parallel quiet');
  assert(parallelQuiet.suggestedInvitation.contains('parallel presence'), 'Invitation text mismatch');

  // Verify Appreciation Note
  final appreciationNote = kCuratedCooperativeActivities.firstWhere((a) => a.id == 'appreciation_note');
  assert(appreciationNote.suggestedInvitation.contains('No need to reply'), 'Invitation must explicitly release reply pressure');

  // Verify Cooperative Games
  final coopGames = kCuratedCooperativeActivities.firstWhere((a) => a.id == 'coop_games');
  assert(coopGames.suggestedGames.length >= 4, 'Expected at least 4 suggested games');
  assert(coopGames.suggestedGames.any((g) => g.contains('The Mind')), 'Suggested games should include The Mind');
  assert(coopGames.suggestedGames.any((g) => g.contains('Hanabi')), 'Suggested games should include Hanabi');
  assert(coopGames.suggestedGames.any((g) => g.contains('Forbidden Island')), 'Suggested games should include Forbidden Island');
  stdout.writeln('✓ Curated cooperative activities and evidence-supported games verified.');

  // 2. Verify Extended Reach-Out Templates
  assert(kDefaultReachOutTemplates.length >= 7, 'Expected at least 7 reach-out templates');
  assert(kDefaultReachOutTemplates.any((t) => t.contains('parallel presence')), 'Missing parallel presence template');
  assert(kDefaultReachOutTemplates.any((t) => t.contains('cooperative game')), 'Missing cooperative game template');
  assert(kDefaultReachOutTemplates.any((t) => t.contains('No need to reply at all')), 'Missing appreciation template');
  stdout.writeln('✓ Extended reach-out templates verified (${kDefaultReachOutTemplates.length} templates).');

  // 3. Verify SMS Intent URI Generation
  final testContact = ReachOutContact(
    id: 'contact_1',
    name: 'Maya',
    phoneNumber: '+1 (555) 019-2834',
    relationship: 'Sister',
    createdAtUnix: 1728240000,
  );

  final smsUri = LonelinessComfortState.buildSmsUri(
    phoneNumber: testContact.phoneNumber!,
    message: parallelQuiet.suggestedInvitation,
  );
  assert(smsUri.scheme == 'sms', 'URI scheme must be sms');
  assert(smsUri.path == '+1(555)019-2834', 'Phone number must be whitespace sanitized');
  assert(smsUri.queryParameters['body'] == parallelQuiet.suggestedInvitation, 'Message body mismatch');
  stdout.writeln('✓ Compliant offline SMS Intent URI generation verified: $smsUri');

  // 4. Verify Guess vs. Reality Experiment Integration
  final experiment = SocialPredictionExperiment(
    id: 'exp_1',
    contactId: testContact.id,
    contactName: testContact.name,
    predictedOutcome: SocialOutcome.wontRespond,
    predictedAtUnix: 1728240000,
    messageSnippet: parallelQuiet.suggestedInvitation,
  );
  assert(!experiment.isCompleted, 'Experiment must be initially pending');

  final completedWarm = experiment.copyWith(
    actualOutcome: SocialOutcome.warm,
    completedAtUnix: 1728243600,
  );
  assert(completedWarm.isCompleted, 'Experiment must be marked completed');
  assert(completedWarm.wasOutcomeEqualOrWarmer, 'Warm outcome must be warmer than wontRespond');

  final summary = SocialExperimentSummary.fromExperiments([completedWarm]);
  assert(summary.completedCount == 1, 'Completed count mismatch');
  assert(summary.actualWarmCount == 1, 'Warm count mismatch');
  assert(summary.warmerOrEqualPercentage == 100, 'Warmer percentage mismatch');
  stdout.writeln('✓ SocialPredictionExperiment lifecycle and statistical summary verified.');

  // 5. Verify AppRoutes & Activity Taxonomy Integration
  assert(AppRoutes.loneliness == '/home/loneliness', 'AppRoutes.loneliness mismatch');
  assert(ActivityCategory.social.name == 'social', 'ActivityCategory name mismatch');
  assert(ActivityCategory.social.displayName == 'Connection & Reaching Out', 'ActivityCategory displayName mismatch');
  assert(ActivityCategory.social.iconKey == 'person.2', 'ActivityCategory iconKey mismatch');
  stdout.writeln('✓ Routing constants and Activity Taxonomy alignment verified.');

  // 6. Verify JSON Catalog Entries
  final catalogFile = File('assets/data/curated_activities.json');
  assert(catalogFile.existsSync(), 'Catalog file must exist');
  final dynamic decoded = jsonDecode(catalogFile.readAsStringSync());
  assert(decoded is List, 'Catalog must be a list');
  final activities = (decoded as List).cast<Map<String, dynamic>>();

  final reachOutActivity = activities.firstWhere(
    (a) => a['id'] == 'act_social_reach_out',
    orElse: () => throw Exception('act_social_reach_out missing from JSON catalog'),
  );
  assert(reachOutActivity['category'] == 'social', 'Category mismatch for reach out');
  assert(reachOutActivity['route'] == '/home/loneliness', 'Route mismatch for reach out');

  final guessVsRealityActivity = activities.firstWhere(
    (a) => a['id'] == 'act_social_guess_vs_reality',
    orElse: () => throw Exception('act_social_guess_vs_reality missing from JSON catalog'),
  );
  assert(guessVsRealityActivity['category'] == 'social', 'Category mismatch for guess vs reality');

  stdout.writeln('✓ Curated activities act_social_reach_out and act_social_guess_vs_reality validated in JSON catalog.');

  stdout.writeln('=== ALL Story 15.2: Social Connection & Cooperative Activities Assertions PASSED successfully! (100% Validated) ===');
}
