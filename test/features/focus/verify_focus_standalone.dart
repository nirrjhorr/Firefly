import 'dart:convert';
import 'dart:io';

import '../../../lib/core/routing/app_routes.dart';
import '../../../lib/features/activities/domain/models/activity_category.dart';
import '../../../lib/features/activities/domain/models/regulation_group.dart';
import '../../../lib/features/focus/data/repositories/focus_repository_impl.dart';
import '../../../lib/features/focus/domain/models/brain_dump_item.dart';
import '../../../lib/features/focus/domain/models/focus_mode.dart';
import '../../../lib/features/focus/domain/models/focus_priority.dart';
import '../../../lib/features/focus/domain/models/focus_session.dart';

void main() async {
  stdout.writeln('======================================================================');
  stdout.writeln('   FIREFLY EPIC 20: FOCUS & MENTAL ORGANISATION AUDIT                ');
  stdout.writeln('======================================================================');

  // -------------------------------------------------------------------------
  // 1. Domain Models & Mode Verification
  // -------------------------------------------------------------------------
  stdout.writeln('\n[1/6] Verifying Focus Modes & Cognitive Models...');
  assert(FocusMode.values.length == 3, 'Must have 3 focus modes');
  assert(FocusMode.threePriorities.displayName == 'Three Priorities');
  assert(FocusMode.focusTimer.displayName == 'Focus Companion');
  assert(FocusMode.brainDump.displayName == 'Brain Dump');

  for (final mode in FocusMode.values) {
    assert(mode.displayName.isNotEmpty);
    assert(mode.subtitle.isNotEmpty);
    stdout.writeln('  ✓ FocusMode: ${mode.displayName.padRight(18)} | "${mode.subtitle}"');
  }

  // -------------------------------------------------------------------------
  // 2. Cognitive Throttling & 3-Slot Ceiling Enforcement
  // -------------------------------------------------------------------------
  stdout.writeln('\n[2/6] Verifying Three Priorities Rule-of-3 Throttling...');
  final p1 = FocusPriority.create(title: 'Review quiet reflection note', orderIndex: 0);
  final p2 = FocusPriority.create(title: 'Water the jade plant', orderIndex: 1);
  final p3 = FocusPriority.create(title: 'Reply to friendly message', orderIndex: 2);
  final p4 = FocusPriority.create(title: 'Excess task attempting to exceed ceiling', orderIndex: 5);

  assert(p1.orderIndex == 0);
  assert(p2.orderIndex == 1);
  assert(p3.orderIndex == 2);
  assert(p4.orderIndex == 2, 'orderIndex must clamp to maximum 2');

  stdout.writeln('  ✓ Maximum 3-slot priority ceiling verified.');

  // -------------------------------------------------------------------------
  // 3. JSON Serialization & Roundtrip
  // -------------------------------------------------------------------------
  stdout.writeln('\n[3/6] Verifying JSON Serialization & Roundtrip...');
  final pJson = p1.toJson();
  final restoredP = FocusPriority.fromJson(pJson);
  assert(restoredP.id == p1.id);
  assert(restoredP.title == p1.title);
  assert(restoredP.orderIndex == p1.orderIndex);
  stdout.writeln('  ✓ FocusPriority JSON roundtrip verified.');

  final dumpItem = BrainDumpItem.create(rawText: 'Organize desk clutter and bills');
  final dumpJson = dumpItem.toJson();
  final restoredDump = BrainDumpItem.fromJson(dumpJson);
  assert(restoredDump.id == dumpItem.id);
  assert(restoredDump.rawText == dumpItem.rawText);
  stdout.writeln('  ✓ BrainDumpItem JSON roundtrip verified.');

  final session = FocusSession.create(
    durationMinutes: 15,
    priorityId: p1.id,
    priorityTitle: p1.title,
    ambientSoundId: 'rain',
  );
  assert(session.durationMinutes == 15);
  assert(session.remainingSeconds == 900);
  assert(session.formattedTime == '15:00');

  final sessionJson = session.toJson();
  final restoredSession = FocusSession.fromJson(sessionJson);
  assert(restoredSession.id == session.id);
  assert(restoredSession.formattedTime == '15:00');
  assert(restoredSession.priorityId == p1.id);
  stdout.writeln('  ✓ FocusSession JSON roundtrip verified.');

  // -------------------------------------------------------------------------
  // 4. Repository Contract & Data Isolation Verification
  // -------------------------------------------------------------------------
  stdout.writeln('\n[4/6] Verifying Repository Contract & Hard Ceiling Operations...');
  final repo = FocusRepositoryImpl();

  // Save 3 priorities
  await repo.savePriority(p1);
  await repo.savePriority(p2);
  await repo.savePriority(p3);
  var priorities = await repo.getPriorities();
  assert(priorities.length == 3, 'Should hold 3 priorities');

  // Attempting to add 4th should respect 3-item ceiling
  await repo.savePriority(FocusPriority.create(title: 'Fourth item', orderIndex: 3));
  priorities = await repo.getPriorities();
  assert(priorities.length == 3, 'Must not exceed 3 priorities');

  // Toggle completion
  await repo.togglePriorityCompletion(p1.id);
  priorities = await repo.getPriorities();
  final completed = priorities.firstWhere((p) => p.id == p1.id);
  assert(completed.isCompleted == true);

  // Delete
  await repo.deletePriority(p2.id);
  priorities = await repo.getPriorities();
  assert(priorities.length == 2);

  // Brain Dump operations
  await repo.addBrainDumpItem(dumpItem);
  var dumps = await repo.getBrainDumpItems();
  assert(dumps.length == 1);
  assert(dumps.first.rawText == dumpItem.rawText);

  await repo.toggleParkBrainDumpItem(dumpItem.id);
  dumps = await repo.getBrainDumpItems();
  assert(dumps.first.isParked == true);

  await repo.deleteBrainDumpItem(dumpItem.id);
  dumps = await repo.getBrainDumpItems();
  assert(dumps.isEmpty);

  // Save session
  await repo.saveSession(session);
  final sessions = await repo.getRecentSessions();
  assert(sessions.length == 1);
  assert(sessions.first.id == session.id);

  stdout.writeln('  ✓ FocusRepository CRUD & cognitive throttling validated.');

  // -------------------------------------------------------------------------
  // 5. Universal Routes & Navigation Bindings
  // -------------------------------------------------------------------------
  stdout.writeln('\n[5/6] Verifying Universal Routes & Navigation Bindings...');
  assert(AppRoutes.focus == '/home/focus');
  assert(AppRoutes.modalFocus == '/focus');

  final routerFile = File('lib/core/routing/app_router.dart');
  assert(routerFile.existsSync(), 'app_router.dart must exist');
  final routerContent = routerFile.readAsStringSync();
  assert(routerContent.contains('FocusScreen'), 'FocusScreen must be imported in router');
  assert(routerContent.contains('AppRoutes.modalFocus'), 'modalFocus must be registered in router');
  assert(routerContent.contains('AppRoutes.focus'), 'focus must be registered in router');
  stdout.writeln('  ✓ AppRoutes.focus and AppRoutes.modalFocus verified in AppRouter.');

  final screenFile = File('lib/features/focus/presentation/screens/focus_screen.dart');
  assert(screenFile.existsSync(), 'focus_screen.dart must exist');
  final screenContent = screenFile.readAsStringSync();
  assert(screenContent.contains('FireflyNavHeader'), 'Must use FireflyNavHeader');
  assert(screenContent.contains('FireflyCard'), 'Must use FireflyCard');
  assert(screenContent.contains('FireflyButton'), 'Must use FireflyButton');
  assert(screenContent.contains('MotionTokens'), 'Must use MotionTokens');
  assert(screenContent.contains('SosOverlayButton'), 'Must have persistent SOS overlay');
  stdout.writeln('  ✓ FocusScreen token discipline & component standards confirmed.');

  // -------------------------------------------------------------------------
  // 6. Curated Activities Catalog Seeding & Taxonomy Alignment
  // -------------------------------------------------------------------------
  stdout.writeln('\n[6/6] Verifying Curated Activities Catalog Seeding...');
  final catalogFile = File('assets/data/curated_activities.json');
  assert(catalogFile.existsSync(), 'curated_activities.json must exist');
  final catalogJson = jsonDecode(catalogFile.readAsStringSync()) as List<dynamic>;

  final threePrioritiesAct = catalogJson.firstWhere(
    (a) => a['id'] == 'act_three_priorities',
    orElse: () => null,
  );
  assert(threePrioritiesAct != null, 'act_three_priorities must be seeded');
  assert(threePrioritiesAct['route'] == '/home/focus?mode=threePriorities');
  assert(threePrioritiesAct['category'] == 'focus');

  final focusTimerAct = catalogJson.firstWhere(
    (a) => a['id'] == 'act_serene_focus_timer',
    orElse: () => null,
  );
  assert(focusTimerAct != null, 'act_serene_focus_timer must be seeded');
  assert(focusTimerAct['route'] == '/home/focus?mode=focusTimer');
  assert(focusTimerAct['category'] == 'focus');

  assert(ActivityCategory.focus.regulationGroup == RegulationGroup.flow);
  assert(ActivityCategory.focus.displayName == 'Focus & Mental Clarity');

  stdout.writeln('  ✓ Seeded activities verified (Total activities in library: ${catalogJson.length}).');
  stdout.writeln('  ✓ ActivityCategory.focus mapped strictly to RegulationGroup.flow (Group 4).');

  // Check RightNowModal anchor
  final modalFile = File('lib/features/activities/presentation/widgets/right_now_modal.dart');
  assert(modalFile.existsSync());
  final modalContent = modalFile.readAsStringSync();
  assert(modalContent.contains('scattered_mind'), 'RightNowModal must have scattered_mind anchor');
  assert(modalContent.contains('AppRoutes.focus'), 'RightNowModal must route to AppRoutes.focus');
  stdout.writeln('  ✓ RightNowModal anchor "scattered_mind" verified.');

  stdout.writeln('\n======================================================================');
  stdout.writeln('   SUCCESS: EPIC 20 (FOCUS & MENTAL ORGANISATION) 100% PASS          ');
  stdout.writeln('======================================================================');
}
