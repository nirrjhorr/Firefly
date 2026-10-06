import 'dart:convert';
import 'dart:io';

import '../../../lib/core/routing/app_routes.dart';
import '../../../lib/features/activities/domain/models/activity_category.dart';
import '../../../lib/features/activities/domain/models/regulation_group.dart';
import '../../../lib/features/compassion/data/repositories/compassion_repository_impl.dart';
import '../../../lib/features/compassion/domain/models/compassion_exercise_type.dart';
import '../../../lib/features/compassion/domain/models/compassion_session.dart';
import '../../../lib/features/compassion/domain/models/self_compassion_component.dart';
import '../../../lib/features/compassion/domain/models/untangled_thought.dart';

void main() async {
  stdout.writeln('======================================================================');
  stdout.writeln('   FIREFLY EPIC 19: SELF-COMPASSION & THOUGHT UNTANGLER AUDIT        ');
  stdout.writeln('======================================================================');

  // -------------------------------------------------------------------------
  // 1. Domain Models & Neff 3-Component Framework Verification
  // -------------------------------------------------------------------------
  stdout.writeln('\n[1/6] Verifying Kristin Neff 3-Pillar Self-Compassion Protocol...');
  assert(SelfCompassionComponent.values.length == 3, 'Must have exactly 3 components');
  assert(SelfCompassionComponent.mindfulness.stepNumber == 1);
  assert(SelfCompassionComponent.commonHumanity.stepNumber == 2);
  assert(SelfCompassionComponent.selfKindness.stepNumber == 3);

  for (final component in SelfCompassionComponent.values) {
    assert(component.title.isNotEmpty, 'Title cannot be empty');
    assert(component.shortPhrase.isNotEmpty, 'Short phrase cannot be empty');
    assert(component.description.isNotEmpty, 'Description cannot be empty');
    assert(component.somaticPrompt.isNotEmpty, 'Somatic prompt cannot be empty');
    assert(component.affirmation.isNotEmpty, 'Affirmation cannot be empty');
    stdout.writeln('  ✓ Component ${component.stepNumber}: ${component.title.padRight(15)} | "${component.shortPhrase}"');
  }

  // -------------------------------------------------------------------------
  // 2. Exercise Types & Untangled Thought Serialization
  // -------------------------------------------------------------------------
  stdout.writeln('\n[2/6] Verifying Exercise Types & Serialization...');
  assert(CompassionExerciseType.values.length == 3);
  assert(CompassionExerciseType.selfCompassionBreak.estimatedMinutes == 3);
  assert(CompassionExerciseType.thoughtUntangler.estimatedMinutes == 4);

  final sampleThought = UntangledThought.create(
    triggerContext: 'Stumbled on words during team check-in.',
    harshCriticVoice: 'You are incompetent and everyone noticed.',
    commonHumanityPerspective: 'Everyone feels nervous or falters at times. It is part of being human.',
    compassionateFriendReframe: 'You were courageous to speak. You are worthy and capable.',
  );

  final thoughtJson = sampleThought.toJson();
  final restoredThought = UntangledThought.fromJson(thoughtJson);
  assert(restoredThought.id == sampleThought.id);
  assert(restoredThought.harshCriticVoice == sampleThought.harshCriticVoice);
  assert(restoredThought.compassionateFriendReframe == sampleThought.compassionateFriendReframe);
  stdout.writeln('  ✓ UntangledThought JSON roundtrip verified.');

  final sampleSession = CompassionSession.create(
    exerciseType: CompassionExerciseType.thoughtUntangler,
    preDistressRating: 5,
  ).copyWith(
    completedAt: DateTime.now(),
    postDistressRating: 2,
    untangledThought: sampleThought,
    reflectionNote: 'Hand-to-heart soothing touch calmed physical shaking.',
  );

  final sessionJson = sampleSession.toJson();
  final restoredSession = CompassionSession.fromJson(sessionJson);
  assert(restoredSession.id == sampleSession.id);
  assert(restoredSession.isCompleted);
  assert(restoredSession.preDistressRating == 5);
  assert(restoredSession.postDistressRating == 2);
  assert(restoredSession.untangledThought?.id == sampleThought.id);
  stdout.writeln('  ✓ CompassionSession JSON roundtrip verified.');

  // -------------------------------------------------------------------------
  // 3. Repository Contract & Data Isolation Verification
  // -------------------------------------------------------------------------
  stdout.writeln('\n[3/6] Verifying Repository Contract & Data Isolation...');
  final repo = CompassionRepositoryImpl();
  await repo.saveSession(sampleSession);
  final sessions = await repo.getRecentSessions();
  assert(sessions.length == 1);
  assert(sessions.first.id == sampleSession.id);

  await repo.saveUntangledThought(sampleThought);
  var thoughts = await repo.getUntangledThoughts();
  assert(thoughts.length == 1);
  assert(thoughts.first.id == sampleThought.id);

  await repo.deleteUntangledThought(sampleThought.id);
  thoughts = await repo.getUntangledThoughts();
  assert(thoughts.isEmpty);
  stdout.writeln('  ✓ CompassionRepository CRUD operations validated.');

  // -------------------------------------------------------------------------
  // 4. State Management & Provider Architecture Verification
  // -------------------------------------------------------------------------
  stdout.writeln('\n[4/6] Verifying Compassion Providers & Controller File Structure...');
  final providerFile = File('lib/features/compassion/presentation/providers/compassion_providers.dart');
  assert(providerFile.existsSync(), 'compassion_providers.dart must exist');
  final providerContent = providerFile.readAsStringSync();
  assert(providerContent.contains('class CompassionNotifier'), 'CompassionNotifier missing');
  assert(providerContent.contains('compassionNotifierProvider'), 'compassionNotifierProvider missing');
  assert(providerContent.contains('compassionRepositoryProvider'), 'compassionRepositoryProvider missing');
  assert(providerContent.contains('void nextStep()'), 'nextStep method missing');
  assert(providerContent.contains('void previousStep()'), 'previousStep method missing');
  assert(providerContent.contains('Future<void> completeSession()'), 'completeSession missing');
  stdout.writeln('  ✓ Riverpod state management, provider declarations, and methods verified.');

  // -------------------------------------------------------------------------
  // 5. Universal Route Integration, Screen UI & RightNowModal Fast Path
  // -------------------------------------------------------------------------
  stdout.writeln('\n[5/6] Verifying Universal Routes & Modal Anchors...');
  assert(AppRoutes.compassion == '/home/compassion');
  assert(AppRoutes.modalCompassion == '/compassion');

  final routerFile = File('lib/core/routing/app_router.dart');
  assert(routerFile.existsSync(), 'app_router.dart must exist');
  final routerContent = routerFile.readAsStringSync();
  assert(routerContent.contains('AppRoutes.compassion'), 'AppRoutes.compassion missing in router');
  assert(routerContent.contains('AppRoutes.modalCompassion'), 'AppRoutes.modalCompassion missing in router');
  assert(routerContent.contains('CompassionScreen'), 'CompassionScreen missing in router');
  stdout.writeln('  ✓ AppRoutes and AppRouter bindings verified.');

  final screenFile = File('lib/features/compassion/presentation/screens/compassion_screen.dart');
  assert(screenFile.existsSync(), 'compassion_screen.dart must exist');
  final screenContent = screenFile.readAsStringSync();
  assert(screenContent.contains('class CompassionScreen'), 'CompassionScreen widget missing');
  assert(screenContent.contains('SosOverlayButton'), 'SosOverlayButton missing from CompassionScreen');
  assert(screenContent.contains('FireflyNavHeader'), 'FireflyNavHeader missing from CompassionScreen');
  stdout.writeln('  ✓ CompassionScreen UI component with SOS protection verified.');

  final modalFile = File('lib/features/activities/presentation/widgets/right_now_modal.dart');
  assert(modalFile.existsSync(), 'right_now_modal.dart must exist');
  final modalContent = modalFile.readAsStringSync();
  assert(modalContent.contains("'hard_on_myself'"), 'hard_on_myself anchor missing in modal');
  assert(modalContent.contains('AppRoutes.compassion'), 'AppRoutes.compassion route missing in modal');
  stdout.writeln('  ✓ RightNowModal anchor "hard_on_myself" verified.');

  // -------------------------------------------------------------------------
  // 6. Curated Activity Catalog Seeding & Taxonomy Alignment
  // -------------------------------------------------------------------------
  stdout.writeln('\n[6/6] Verifying Curated Activities Catalog Seeding...');
  final catalogFile = File('assets/data/curated_activities.json');
  assert(catalogFile.existsSync(), 'curated_activities.json must exist');
  final catalogJson = jsonDecode(catalogFile.readAsStringSync()) as List<dynamic>;

  final breakActivity = catalogJson.firstWhere(
    (a) => a['id'] == 'act_self_compassion_break',
    orElse: () => null,
  );
  assert(breakActivity != null, 'act_self_compassion_break must be seeded in catalog');
  assert(breakActivity['title'] == 'Self-Compassion Break');
  assert(breakActivity['category'] == 'selfCompassion');
  assert(breakActivity['durationMinutes'] == 3);

  final untanglerActivity = catalogJson.firstWhere(
    (a) => a['id'] == 'act_thought_untangler',
    orElse: () => null,
  );
  assert(untanglerActivity != null, 'act_thought_untangler must be seeded in catalog');
  assert(untanglerActivity['title'] == 'Thought Untangler');
  assert(untanglerActivity['category'] == 'cognitiveDefusion');
  assert(untanglerActivity['durationMinutes'] == 4);

  // Taxonomy integration
  assert(ActivityCategory.values.contains(ActivityCategory.selfCompassion));
  assert(ActivityCategory.selfCompassion.regulationGroup == RegulationGroup.expression);
  assert(RegulationGroup.expression.matches(ActivityCategory.selfCompassion));
  stdout.writeln('  ✓ Catalog activities seeded (${catalogJson.length} total activities in library).');
  stdout.writeln('  ✓ ActivityCategory and RegulationGroup taxonomy alignment verified.');

  stdout.writeln('\n======================================================================');
  stdout.writeln('   SUCCESS: EPIC 19 (SELF-COMPASSION & THOUGHT UNTANGLER) 100% PASS   ');
  stdout.writeln('======================================================================');
}
