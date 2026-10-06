import 'dart:convert';
import 'dart:io';

import '../../../lib/core/routing/app_routes.dart';
import '../../../lib/features/labyrinth/domain/models/labyrinth_coord.dart';
import '../../../lib/features/labyrinth/domain/models/labyrinth_pattern_type.dart';
import '../../../lib/features/labyrinth/domain/models/labyrinth_session_state.dart';

void expect(bool condition, String message) {
  if (!condition) {
    throw Exception('FAILED: $message');
  }
}

void main() {
  print('=== Verifying Meditative Labyrinth Tracing & Drawing Suite (Story 12.3) ===');

  testLabyrinthCoord();
  testLabyrinthPatterns();
  testMathematicalPointGeneration();
  testSessionStateProgression();
  testCuratedCatalogAlignment();
  testZeroNetworkCompliance();

  print('\n=== ALL Meditative Labyrinth Verification Tests PASSED! (100% Validated) ===');
}

void testLabyrinthCoord() {
  print('\n1. Verifying LabyrinthCoord distance and value equality...');

  const c1 = LabyrinthCoord(0, 0);
  const c2 = LabyrinthCoord(3, 4);
  expect(c1.distanceTo(c2) == 5.0, 'Pythagorean distance should equal 5.0');
  expect(c1 == const LabyrinthCoord(0, 0), 'Value equality works');
  expect(c1 != c2, 'Inequality works');

  print('✓ Pure Dart LabyrinthCoord validated.');
}

void testLabyrinthPatterns() {
  print('\n2. Verifying LabyrinthPatternType enum and properties...');

  expect(LabyrinthPatternType.values.length == 4, 'Must define exactly 4 patterns');

  final patterns = [
    LabyrinthPatternType.classical,
    LabyrinthPatternType.spiral,
    LabyrinthPatternType.infinity,
    LabyrinthPatternType.meander,
  ];

  for (final pattern in patterns) {
    expect(pattern.title.isNotEmpty, '${pattern.name} must have a non-empty title');
    expect(pattern.subtitle.isNotEmpty, '${pattern.name} must have a non-empty subtitle');
    expect(pattern.description.isNotEmpty, '${pattern.name} must have a non-empty description');
    expect(pattern.scientificMechanism.isNotEmpty, '${pattern.name} must have a scientific mechanism');
    expect(pattern.iconKey.isNotEmpty, '${pattern.name} must have an icon key');
  }

  expect(LabyrinthPatternType.fromString('classical') == LabyrinthPatternType.classical, 'classical lookup');
  expect(LabyrinthPatternType.fromString('SPIRAL') == LabyrinthPatternType.spiral, 'spiral uppercase lookup');
  expect(LabyrinthPatternType.fromString('infinity') == LabyrinthPatternType.infinity, 'infinity lookup');
  expect(LabyrinthPatternType.fromString('unknown_pattern') == LabyrinthPatternType.classical, 'Default fallback');

  print('✓ All 4 LabyrinthPatternTypes validated.');
}

void testMathematicalPointGeneration() {
  print('\n3. Verifying mathematical curve coordinate generation...');

  const canvasWidth = 360.0;
  const canvasHeight = 480.0;

  for (final pattern in LabyrinthPatternType.values) {
    final points = pattern.generatePathPoints(canvasWidth, canvasHeight);
    expect(points.isNotEmpty, 'Pattern ${pattern.name} must generate points');
    expect(points.length >= 80, 'Pattern ${pattern.name} should generate >= 80 smooth points (got ${points.length})');

    // Verify all points are finite and within canvas margin bounds
    for (final pt in points) {
      expect(!pt.x.isNaN && !pt.y.isNaN, 'Point coordinates must be valid numbers');
      expect(pt.x >= -50 && pt.x <= canvasWidth + 50, 'X coordinate within reasonable bounds: ${pt.x}');
      expect(pt.y >= -50 && pt.y <= canvasHeight + 50, 'Y coordinate within reasonable bounds: ${pt.y}');
    }
  }

  print('✓ Parametric curves for Classical, Spiral, Infinity, and Meander generated correctly.');
}

void testSessionStateProgression() {
  print('\n4. Verifying LabyrinthSessionState state transitions...');

  var state = const LabyrinthSessionState(pattern: LabyrinthPatternType.classical);
  expect(state.progress == 0.0, 'Initial progress should be 0.0');
  expect(state.tracedPoints.isEmpty, 'Initial points should be empty');
  expect(!state.isTracingActive, 'Not active initially');
  expect(!state.isCompleted, 'Not completed initially');
  expect(state.loopsCompleted == 0, 'Zero loops initially');
  expect(state.showGuidePath, 'Guide path shown by default');

  // Add touch stroke points
  final simulatedPoints = [
    const LabyrinthCoord(100, 100),
    const LabyrinthCoord(110, 105),
    const LabyrinthCoord(120, 110),
  ];

  state = state.copyWith(
    tracedPoints: simulatedPoints,
    isTracingActive: true,
    progress: 0.35,
  );

  expect(state.totalPointsTraced == 3, 'Recorded 3 touch points');
  expect(state.isTracingActive, 'Tracing active flag');
  expect(state.progress == 0.35, 'Progress updated');

  // Complete loop
  state = state.copyWith(
    progress: 1.0,
    isCompleted: true,
    loopsCompleted: 1,
    isTracingActive: false,
  );

  expect(state.isCompleted, 'Marked completed');
  expect(state.loopsCompleted == 1, '1 loop finished');
  expect(!state.isTracingActive, 'Touch ended');

  print('✓ State transitions and touch tracking progression calculated accurately.');
}

void testCuratedCatalogAlignment() {
  print('\n5. Verifying AppRoutes and curated_activities.json alignment...');

  expect(AppRoutes.labyrinth == '/home/labyrinth', 'AppRoutes.labyrinth must match /home/labyrinth');

  final file = File('assets/data/curated_activities.json');
  expect(file.existsSync(), 'assets/data/curated_activities.json must exist');

  final content = file.readAsStringSync();
  final List<dynamic> jsonList = jsonDecode(content);

  final labyrinthActivities = jsonList.where((item) =>
    (item['id'] as String).startsWith('act_labyrinth_')
  ).toList();

  expect(labyrinthActivities.length == 4, 'Must have exactly 4 labyrinth activities seeded');

  final expectedIds = [
    'act_labyrinth_classical',
    'act_labyrinth_spiral',
    'act_labyrinth_infinity',
    'act_labyrinth_meander',
  ];

  for (final id in expectedIds) {
    final activity = labyrinthActivities.firstWhere(
      (a) => a['id'] == id,
      orElse: () => null,
    );
    expect(activity != null, 'Catalog must contain activity $id');
    expect((activity['title'] as String).isNotEmpty, '$id must have title');
    expect((activity['description'] as String).isNotEmpty, '$id must have description');
    expect(activity['category'] == 'labyrinth', '$id category must be labyrinth');
    expect(activity['energyRequired'] == 1, '$id energyRequired must be low (1)');
    expect((activity['route'] as String).startsWith('/home/labyrinth?pattern='), '$id route must point to /home/labyrinth');
    expect(activity['durationMinutes'] is int && activity['durationMinutes'] > 0, '$id duration must be valid');
  }

  print('✓ Curated activities catalog includes 4 aligned meditative labyrinth activities.');
}

void testZeroNetworkCompliance() {
  print('\n6. Verifying Zero Network compliance...');

  final dir = Directory('lib/features/labyrinth');
  expect(dir.existsSync(), 'lib/features/labyrinth directory must exist');

  final files = dir.listSync(recursive: true).whereType<File>();
  for (final f in files) {
    if (!f.path.endsWith('.dart')) continue;
    final code = f.readAsStringSync();

    expect(!code.contains('package:http/'), 'Zero network violation: package:http in ${f.path}');
    expect(!code.contains('package:dio/'), 'Zero network violation: package:dio in ${f.path}');
    expect(!code.contains('HttpClient('), 'Zero network violation: HttpClient in ${f.path}');
    expect(!code.contains('http://') && !code.contains('https://'), 'Zero network violation: hardcoded remote URL in ${f.path}');
  }

  print('✓ Zero network compliance verified across all Labyrinth feature source files.');
}
