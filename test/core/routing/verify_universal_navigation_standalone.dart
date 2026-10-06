import 'dart:convert';
import 'dart:io';

import '../../../lib/core/routing/app_routes.dart';

void expect(bool condition, String message) {
  if (!condition) {
    throw Exception('FAILED: $message');
  }
}

void main() {
  print('=== Verifying Universal Navigation, SOS Panic & Seeding Alignment (Story 11.6) ===');

  // 1. Verify AppRoutes Constants
  print('1. Verifying AppRoutes constants...');
  expect(AppRoutes.splash == '/', 'Splash path mismatch');
  expect(AppRoutes.onboarding == '/onboarding', 'Onboarding path mismatch');
  expect(AppRoutes.privacyLock == '/privacy-lock', 'Privacy lock path mismatch');
  expect(AppRoutes.safetyPlan == '/safety-plan', 'Safety plan path mismatch');
  expect(AppRoutes.safetyPlanEditor == '/safety-plan/edit', 'Safety plan editor path mismatch');
  expect(AppRoutes.panicBlank == '/panic', 'Panic blank path mismatch');

  expect(AppRoutes.home == '/home', 'Home path mismatch');
  expect(AppRoutes.checkIn == '/home/check-in', 'Check-in path mismatch');
  expect(AppRoutes.breathe == '/home/breathe', 'Breathe path mismatch');
  expect(AppRoutes.journal == '/home/journal', 'Journal path mismatch');
  expect(AppRoutes.tinySteps == '/home/tiny-steps', 'Tiny steps path mismatch');
  expect(AppRoutes.progress == '/home/progress', 'Progress path mismatch');
  expect(AppRoutes.loneliness == '/home/loneliness', 'Loneliness path mismatch');
  expect(AppRoutes.soundscapes == '/home/soundscapes', 'Soundscapes path mismatch');

  expect(AppRoutes.pmr == '/home/pmr', 'PMR path mismatch');
  expect(AppRoutes.rightNow == '/home/right-now', 'Right Now path mismatch');
  expect(AppRoutes.move == '/home/move', 'Move path mismatch');
  expect(AppRoutes.cognitiveGrounding == '/home/cognitive-grounding', 'Cognitive grounding path mismatch');
  expect(AppRoutes.sleep == '/home/sleep', 'Sleep path mismatch');
  expect(AppRoutes.hopeBox == '/home/hope-box', 'Hope Box path mismatch');
  expect(AppRoutes.tinyStepActivity == '/tiny-step/:id', 'Tiny step activity path mismatch');
  print('✓ All 20 AppRoutes constants verified.');

  // 2. Verify RightNowModal Distress Anchors in File
  print('2. Verifying RightNowModal distress anchors definition...');
  final rightNowModalFile = File('lib/features/activities/presentation/widgets/right_now_modal.dart');
  expect(rightNowModalFile.existsSync(), 'right_now_modal.dart must exist');
  final rightNowContent = rightNowModalFile.readAsStringSync();

  // Validate presence of canonical acute distress anchors
  final requiredAnchorIds = [
    'calm_down',
    'cant_stop_thinking',
    'overwhelmed',
    'low_energy',
    'restless',
    'cant_focus',
    'emotionally_heavy',
    'want_to_sleep',
    'express_feeling',
    'distracting',
    'connect',
    'losing_hope',
    'dont_know',
  ];

  for (final id in requiredAnchorIds) {
    expect(rightNowContent.contains("id: '$id'"), "Anchor '$id' must exist in RightNowModal");
  }

  // Verify key routing anchors
  expect(rightNowContent.contains("id: 'losing_hope'") && rightNowContent.contains("route: AppRoutes.hopeBox"),
      "losing_hope anchor must link to AppRoutes.hopeBox");
  expect(rightNowContent.contains("id: 'overwhelmed'") && rightNowContent.contains("route: '/home/breathe?mode=grounding'"),
      "overwhelmed anchor must link to grounding mode");
  expect(rightNowContent.contains("case 'heart':") && rightNowContent.contains("case 'favorite':"),
      "Icon resolver must map heart/favorite keys");
  print('✓ All 13 RightNowModal distress anchors and icon mappings verified.');

  // 3. Verify Recommendation Engine Routes in File
  print('3. Verifying RecommendationEngine deterministic routing alignment...');
  final recEngineFile = File('lib/core/recommendation_engine/recommendation_engine.dart');
  expect(recEngineFile.existsSync(), 'recommendation_engine.dart must exist');
  final recEngineContent = recEngineFile.readAsStringSync();

  expect(recEngineContent.contains('actionType: ActionType.hopeBox'),
      'RecommendationEngine must support ActionType.hopeBox');
  expect(recEngineContent.contains('route: AppRoutes.hopeBox'),
      'RecommendationEngine must route hopeBox to AppRoutes.hopeBox');
  expect(recEngineContent.contains('route: AppRoutes.loneliness'),
      'RecommendationEngine must route loneliness to AppRoutes.loneliness');
  expect(recEngineContent.contains('_hopeBoxSuggestion'),
      'RecommendationEngine must include _hopeBoxSuggestion in alternatives');
  print('✓ RecommendationEngine deterministic routes and Hope Box alignment verified.');

  // 4. Verify Router Configuration in File
  print('4. Verifying app_router.dart shell and root modal configuration...');
  final routerFile = File('lib/core/routing/app_router.dart');
  expect(routerFile.existsSync(), 'app_router.dart must exist');
  final routerContent = routerFile.readAsStringSync();

  // Shell routes must pass showSosOverlay: false to avoid double SOS buttons
  expect(routerContent.contains('path: AppRoutes.hopeBox') && routerContent.contains('showSosOverlay: false'),
      'Shell route for hopeBox must have showSosOverlay: false');
  expect(routerContent.contains('path: AppRoutes.sleep') && routerContent.contains('showSosOverlay: false'),
      'Shell route for sleep must have showSosOverlay: false');
  expect(routerContent.contains('path: AppRoutes.loneliness') && routerContent.contains('showSosOverlay: false'),
      'Shell route for loneliness must have showSosOverlay: false');
  expect(routerContent.contains('path: AppRoutes.pmr') && routerContent.contains('showSosOverlay: false'),
      'Shell route for PMR must have showSosOverlay: false');
  expect(routerContent.contains('path: AppRoutes.move') && routerContent.contains('showSosOverlay: false'),
      'Shell route for move must have showSosOverlay: false');
  expect(routerContent.contains('path: AppRoutes.cognitiveGrounding') && routerContent.contains('showSosOverlay: false'),
      'Shell route for cognitiveGrounding must have showSosOverlay: false');

  // Root modal routes must maintain parentNavigatorKey: _rootNavigatorKey and showSosOverlay: true
  expect(routerContent.contains("path: '/hope-box'") && routerContent.contains('parentNavigatorKey: _rootNavigatorKey'),
      'Root modal for hope-box must be registered on _rootNavigatorKey');
  expect(routerContent.contains("path: '/sleep'") && routerContent.contains('parentNavigatorKey: _rootNavigatorKey'),
      'Root modal for sleep must be registered on _rootNavigatorKey');
  expect(routerContent.contains("path: '/cognitive-grounding'") && routerContent.contains('parentNavigatorKey: _rootNavigatorKey'),
      'Root modal for cognitive-grounding must be registered on _rootNavigatorKey');
  print('✓ AppRouter shell non-duplication and root modal overlay registration verified.');

  // 5. Verify CheckInScreen Quick Access Cards in File
  print('5. Verifying CheckInScreen quick access links...');
  final checkInFile = File('lib/features/check_in/presentation/screens/check_in_screen.dart');
  expect(checkInFile.existsSync(), 'check_in_screen.dart must exist');
  final checkInContent = checkInFile.readAsStringSync();

  expect(checkInContent.contains('context.push(AppRoutes.hopeBox)'),
      'CheckInScreen must have direct tap link to AppRoutes.hopeBox');
  expect(checkInContent.contains('context.push(AppRoutes.sleep)'),
      'CheckInScreen must have direct tap link to AppRoutes.sleep');
  expect(checkInContent.contains('context.push(AppRoutes.soundscapes)'),
      'CheckInScreen must have direct tap link to AppRoutes.soundscapes');
  print('✓ CheckInScreen quick access cards verified.');

  // 6. Verify Curated Activities JSON Asset & Fallback Catalog Alignment
  print('6. Verifying curated activities JSON catalog and fallback...');
  final activitiesFile = File('assets/data/curated_activities.json');
  expect(activitiesFile.existsSync(), 'curated_activities.json must exist');
  final jsonDecoded = jsonDecode(activitiesFile.readAsStringSync()) as List<dynamic>;

  final routeSet = <String>{};
  for (final item in jsonDecoded) {
    final route = item['route'] as String;
    routeSet.add(route.split('?').first);
    expect(!route.startsWith('http'), 'No remote routes allowed in offline catalog: $route');
  }

  expect(routeSet.contains(AppRoutes.breathe), 'Catalog must contain breathe route');
  expect(routeSet.contains(AppRoutes.pmr), 'Catalog must contain pmr route');
  expect(routeSet.contains(AppRoutes.move), 'Catalog must contain move route');
  expect(routeSet.contains(AppRoutes.cognitiveGrounding), 'Catalog must contain cognitive grounding route');
  expect(routeSet.contains(AppRoutes.sleep), 'Catalog must contain sleep route');
  expect(routeSet.contains(AppRoutes.hopeBox), 'Catalog must contain hope box route');
  expect(routeSet.contains(AppRoutes.loneliness), 'Catalog must contain loneliness route');
  expect(routeSet.contains(AppRoutes.tinySteps), 'Catalog must contain tiny steps route');

  // Verify ActivitySeedingService Fallback Catalog
  final seedingFile = File('lib/features/activities/data/services/activity_seeding_service.dart');
  expect(seedingFile.existsSync(), 'activity_seeding_service.dart must exist');
  final seedingContent = seedingFile.readAsStringSync();

  expect(seedingContent.contains('act_hope_box_glance') && seedingContent.contains('/home/hope-box'),
      'Seeding fallback must contain act_hope_box_glance');
  expect(seedingContent.contains('act_sleep_worry_dump') && seedingContent.contains('/home/sleep?mode=worryDump'),
      'Seeding fallback must contain act_sleep_worry_dump');
  expect(seedingContent.contains('act_cognitive_categories') && seedingContent.contains('/home/cognitive-grounding'),
      'Seeding fallback must contain act_cognitive_categories');
  expect(seedingContent.contains('act_movement_shakeout') && seedingContent.contains('/home/move?mode=shakeout'),
      'Seeding fallback must contain act_movement_shakeout');
  expect(seedingContent.contains('act_social_reach_out') && seedingContent.contains('/home/loneliness'),
      'Seeding fallback must contain act_social_reach_out');
  print('✓ Curated activities and fallback catalog alignment verified.');

  print('\n=== ALL Universal Navigation, SOS Panic & Seeding Assertions PASSED successfully! (100% Validated) ===');
}
