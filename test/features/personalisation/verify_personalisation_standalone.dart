import 'dart:io';

import '../../../lib/core/database/daos/activities_dao.dart';
import '../../../lib/core/recommendation_engine/models/action_suggestion.dart';
import '../../../lib/core/recommendation_engine/models/affect_state.dart';
import '../../../lib/core/recommendation_engine/recommendation_engine.dart';
import '../../../lib/core/routing/app_routes.dart';
import '../../../lib/features/activities/domain/models/activity_effectiveness_log.dart';
import '../../../lib/features/personalisation/data/repositories/personalisation_repository_impl.dart';
import '../../../lib/features/personalisation/domain/models/activity_affinity.dart';
import '../../../lib/features/personalisation/domain/models/personal_regulation_profile.dart';
import '../../../lib/features/personalisation/domain/services/personal_effectiveness_engine.dart';

void main() async {
  stdout.writeln('======================================================================');
  stdout.writeln('   FIREFLY EPIC 21: PERSONAL REGULATION EFFECTIVENESS AUDIT          ');
  stdout.writeln('======================================================================');

  // -------------------------------------------------------------------------
  // 1. Mathematical Scoring & Bayesian Sample Damping
  // -------------------------------------------------------------------------
  stdout.writeln('\n[1/5] Verifying Mathematical Scoring & Damped Affinity...');

  // Cold start / empty
  final emptyProfile = PersonalEffectivenessEngine.buildProfile([]);
  assert(emptyProfile.isEmpty, 'Empty profile must be empty');
  assert(emptyProfile.totalMomentsOfCare == 0, 'Total moments must be 0');
  assert(emptyProfile.calmingRate == 0.0, 'Calming rate must be 0');
  stdout.writeln('  ✓ Cold start verified: Empty profile has zero moments and zero calming rate.');

  // Single log (+2 rating, state: "anxious")
  final now = DateTime.now();
  final log1 = ActivityEffectivenessLog(
    id: 'log-1',
    activityId: 'act_cyclic_sighing',
    stateAtStart: 'anxious',
    rating: 2,
    durationSeconds: 120,
    timestamp: now,
  );

  final affinities1 = PersonalEffectivenessEngine.calculateAffinities([log1]);
  assert(affinities1.length == 1, 'Must have 1 affinity group');
  final aff1 = affinities1.first;
  assert(aff1.sampleCount == 1, 'Sample count must be 1');
  assert(aff1.averageRating == 2.0, 'Average rating must be 2.0');
  // Damped score: (2.0 / 2.0) * (1 / (1 + 1)) = 0.5
  assert((aff1.affinityScore - 0.5).abs() < 0.001, 'Damped score must be 0.5');
  assert(aff1.positiveCount == 1, 'Positive count must be 1');
  assert(aff1.negativeCount == 0, 'Negative count must be 0');
  stdout.writeln('  ✓ Single log damping verified: score = 0.5 (scaled & damped from rating +2).');

  // Multi-session convergence (+2 and +2)
  final log2 = ActivityEffectivenessLog(
    id: 'log-2',
    activityId: 'act_cyclic_sighing',
    stateAtStart: 'anxious',
    rating: 2,
    durationSeconds: 120,
    timestamp: now.add(const Duration(minutes: 5)),
  );

  final affinities2 = PersonalEffectivenessEngine.calculateAffinities([log1, log2]);
  final aff2 = affinities2.first;
  assert(aff2.sampleCount == 2, 'Sample count must be 2');
  // Damped score: (2.0 / 2.0) * (2 / (2 + 1)) = 0.6667
  assert((aff2.affinityScore - (2.0 / 3.0)).abs() < 0.001, 'Score must approach asymptote');
  stdout.writeln('  ✓ Multi-session convergence verified: 2 identical sessions increase score to ~0.67.');

  // Negative rating suppression (-2 rating)
  final logNegative = ActivityEffectivenessLog(
    id: 'log-neg',
    activityId: 'act_unhelpful_action',
    stateAtStart: 'anxious',
    rating: -2,
    durationSeconds: 60,
    timestamp: now,
  );
  final affinitiesNeg = PersonalEffectivenessEngine.calculateAffinities([logNegative]);
  final affNeg = affinitiesNeg.first;
  assert(affNeg.affinityScore < 0, 'Negative rating must produce negative score');
  assert(affNeg.negativeCount == 1, 'Negative count must be 1');

  final profileWithNeg = PersonalEffectivenessEngine.buildProfile([log1, logNegative]);
  final anxiousPractices = profileWithNeg.topPracticesByState['anxious'] ?? [];
  assert(!anxiousPractices.any((a) => a.activityId == 'act_unhelpful_action'), 'Negative practices must not be in top calming list');
  stdout.writeln('  ✓ Unhelpful practice suppression verified: negative ratings never promoted in top calming list.');

  // -------------------------------------------------------------------------
  // 2. Domain Model JSON Roundtrip Integrity
  // -------------------------------------------------------------------------
  stdout.writeln('\n[2/5] Verifying JSON Serialization & Roundtrip...');

  final sampleAffinity = ActivityAffinity(
    activityId: 'act_54321',
    targetState: 'overwhelmed',
    sampleCount: 4,
    averageRating: 1.75,
    affinityScore: 0.70,
    lastPracticed: DateTime(2026, 10, 6, 20, 0),
    positiveCount: 4,
    negativeCount: 0,
    neutralCount: 0,
  );

  final jsonMap = sampleAffinity.toJson();
  final reconstructed = ActivityAffinity.fromJson(jsonMap);
  assert(reconstructed.activityId == sampleAffinity.activityId, 'ActivityId must match');
  assert(reconstructed.targetState == sampleAffinity.targetState, 'TargetState must match');
  assert(reconstructed.sampleCount == sampleAffinity.sampleCount, 'SampleCount must match');
  assert(reconstructed.affinityScore == sampleAffinity.affinityScore, 'AffinityScore must match');
  assert(reconstructed.positiveCount == sampleAffinity.positiveCount, 'PositiveCount must match');
  stdout.writeln('  ✓ ActivityAffinity JSON roundtrip verified.');

  final sampleProfile = PersonalRegulationProfile(
    affinities: [sampleAffinity],
    topPracticesByState: {'overwhelmed': [sampleAffinity]},
    overallTopPractices: [sampleAffinity],
    totalMomentsOfCare: 4,
    calmingSessionCount: 4,
    calmingRate: 1.0,
    lastUpdated: DateTime(2026, 10, 6, 21, 0),
  );

  final profileJson = sampleProfile.toJson();
  final reconstructedProfile = PersonalRegulationProfile.fromJson(profileJson);
  assert(reconstructedProfile.totalMomentsOfCare == 4, 'Moments of care must match');
  assert(reconstructedProfile.calmingRate == 1.0, 'Calming rate must match');
  assert(reconstructedProfile.topPracticesByState['overwhelmed']?.length == 1, 'Top by state must match');
  stdout.writeln('  ✓ PersonalRegulationProfile JSON roundtrip verified.');

  // -------------------------------------------------------------------------
  // 3. Recommendation Engine Personal Affinity Weighting
  // -------------------------------------------------------------------------
  stdout.writeln('\n[3/5] Verifying Recommendation Engine Personalization...');

  const affect = AffectState(
    moodCategory: 'anxious',
    energyLevel: 3,
    anxietyLevel: 5, // High anxiety
    lonelinessLevel: 1,
  );

  // Cold start evaluation
  final defaultSuggestion = RecommendationEngine.evaluate(affect);
  assert(defaultSuggestion.actionType == ActionType.breathing, 'Must recommend breathing');
  assert(!defaultSuggestion.isPersonalized, 'Cold start must not be marked personalized');
  assert(defaultSuggestion.personalizedReason == null, 'Cold start must have null reason');
  stdout.writeln('  ✓ Cold start fallback: returns cyclic sighing breathing with zero personalization tag.');

  // Personal affinity available for breathing
  final personalizedSuggestion = RecommendationEngine.evaluate(
    affect,
    personalAffinities: {
      'breathing': 0.65,
      'grounding': 0.40,
    },
    personalizedReasons: {
      'breathing': 'Consistently settled your body when feeling anxious',
    },
  );

  assert(personalizedSuggestion.actionType == ActionType.breathing, 'Must recommend breathing');
  assert(personalizedSuggestion.isPersonalized, 'Must be marked personalized');
  assert(personalizedSuggestion.personalizedReason != null, 'Must have personalized reason');
  assert(personalizedSuggestion.personalizedReason!.contains('Consistently settled'), 'Reason must match');
  assert(personalizedSuggestion.affinityScore == 0.65, 'Affinity score must match');
  assert(personalizedSuggestion.alternativeSuggestions.first.actionType == ActionType.grounding, 'Grounding must be first alternative');
  stdout.writeln('  ✓ Personal evidence badging: primary suggestion decorated with affinity and reason.');
  stdout.writeln('  ✓ Alternatives reordering: higher affinity options sorted to front.');

  // Alternative promotion when candidate has no affinity but an alternative has proven strong relief (> 0.45)
  const moderateState = AffectState(
    moodCategory: 'here',
    energyLevel: 3,
    anxietyLevel: 2,
    lonelinessLevel: 2,
  );
  final promotedSuggestion = RecommendationEngine.evaluate(
    moderateState,
    personalAffinities: {
      'tinySteps': 0.05,
      'focus': 0.60, // Strong proven relief with focus
    },
    personalizedReasons: {
      'focus': 'Previously settled your mind when overwhelmed',
    },
  );
  assert(promotedSuggestion.actionType == ActionType.focus, 'Must promote focus to primary');
  assert(promotedSuggestion.isPersonalized, 'Must be marked personalized');
  stdout.writeln('  ✓ Autonomous promotion: proven calming practice promoted to primary recommendation.');

  // -------------------------------------------------------------------------
  // 4. Repository Contract & Data Access Audit
  // -------------------------------------------------------------------------
  stdout.writeln('\n[4/5] Verifying PersonalisationRepository & ActivitiesDao Contract...');

  final dao = InMemoryActivitiesDao();
  final repo = PersonalisationRepositoryImpl(dao);

  // Initially empty
  final initialProfile = await repo.getProfile();
  assert(initialProfile.isEmpty, 'Initial profile must be empty');

  // Log 3 sessions
  await dao.logEffectiveness(
    ActivityEffectivenessLog(
      id: 'log-1',
      activityId: 'act_cyclic_sighing',
      stateAtStart: 'anxious',
      rating: 2,
      durationSeconds: 120,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    ),
  );
  await dao.logEffectiveness(
    ActivityEffectivenessLog(
      id: 'log-2',
      activityId: 'act_cyclic_sighing',
      stateAtStart: 'anxious',
      rating: 1,
      durationSeconds: 120,
      timestamp: DateTime.now(),
    ),
  );
  await dao.logEffectiveness(
    ActivityEffectivenessLog(
      id: 'log-3',
      activityId: 'act_three_priorities',
      stateAtStart: 'scattered',
      rating: 2,
      durationSeconds: 180,
      timestamp: DateTime.now(),
    ),
  );

  final updatedProfile = await repo.getProfile();
  assert(updatedProfile.totalMomentsOfCare == 3, 'Must have 3 moments of care');
  assert(updatedProfile.calmingSessionCount == 3, 'Must have 3 calming sessions');
  assert(updatedProfile.calmingRate == 1.0, 'Calming rate must be 1.0');
  assert(updatedProfile.topPracticesByState.containsKey('anxious'), 'Must group anxious');
  assert(updatedProfile.topPracticesByState.containsKey('scattered'), 'Must group scattered');
  stdout.writeln('  ✓ Profile aggregation verified: 3 moments of care aggregated across states.');

  // State-specific query
  final anxiousAffinities = await repo.getAffinitiesForState('anxious');
  assert(anxiousAffinities.length == 1, 'Must have 1 anxious affinity');
  assert(anxiousAffinities.first.activityId == 'act_cyclic_sighing', 'Must be cyclic sighing');
  stdout.writeln('  ✓ State-specific affinity query validated.');

  // Clear history (100% privacy reset)
  await repo.clearHistory();
  final clearedProfile = await repo.getProfile();
  assert(clearedProfile.isEmpty, 'Profile must be empty after clear');
  assert(clearedProfile.totalMomentsOfCare == 0, 'Moments must be 0');
  stdout.writeln('  ✓ Privacy reset verified: all logs cleared on demand.');

  // -------------------------------------------------------------------------
  // 5. Route Constants & Navigation Bindings Audit
  // -------------------------------------------------------------------------
  stdout.writeln('\n[5/5] Verifying Route Constants & Navigation Bindings...');

  assert(AppRoutes.profile == '/home/profile', 'Profile route must match');
  assert(AppRoutes.modalProfile == '/profile', 'Modal profile route must match');
  stdout.writeln('  ✓ AppRoutes.profile and AppRoutes.modalProfile confirmed.');

  // Expanded ActionType checks
  assert(ActionType.values.contains(ActionType.focus), 'ActionType must contain focus');
  assert(ActionType.values.contains(ActionType.compassion), 'ActionType must contain compassion');
  assert(ActionType.values.contains(ActionType.reset), 'ActionType must contain reset');
  assert(ActionType.fromString('focus') == ActionType.focus, 'FromString must parse focus');
  assert(ActionType.fromString('unknown_type') == ActionType.breathing, 'Fallback must be breathing');
  stdout.writeln('  ✓ ActionType expanded and safely falls back on unknown input.');

  // Verify file existence of PersonalProfileScreen
  final screenFile = File('lib/features/personalisation/presentation/screens/personal_profile_screen.dart');
  assert(screenFile.existsSync(), 'PersonalProfileScreen file must exist');
  final screenContent = screenFile.readAsStringSync();
  assert(screenContent.contains('PersonalProfileScreen'), 'Must declare PersonalProfileScreen');
  assert(screenContent.contains('FireflyNavHeader'), 'Must use FireflyNavHeader');
  assert(screenContent.contains('FireflyCard'), 'Must use FireflyCard');
  assert(screenContent.contains('SosOverlayButton'), 'Must include SosOverlayButton');
  stdout.writeln('  ✓ PersonalProfileScreen token discipline & component standards confirmed.');

  stdout.writeln('\n======================================================================');
  stdout.writeln('   SUCCESS: EPIC 21 (PERSONAL REGULATION AFFINITY) 100% PASS          ');
  stdout.writeln('======================================================================\n');
}
