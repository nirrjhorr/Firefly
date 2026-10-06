import 'dart:math';

import '../../../lib/features/flow_puzzle/domain/models/constellation_pattern.dart';
import '../../../lib/features/flow_puzzle/domain/models/flow_puzzle_session_state.dart';
import '../../../lib/features/flow_puzzle/domain/models/flow_puzzle_type.dart';
import '../../../lib/features/flow_puzzle/domain/models/sliding_grid_state.dart';

void main() {
  print('=== Verifying Flow & Spatial Puzzles Integration (Story 13.2 / Epic 13) ===');

  // 1. Verify FlowPuzzleMode enum & properties
  assert(FlowPuzzleMode.values.length == 2, 'Expected 2 flow puzzle modes');
  for (final mode in FlowPuzzleMode.values) {
    assert(mode.displayName.isNotEmpty, 'Display name must not be empty');
    assert(mode.description.isNotEmpty, 'Description must not be empty');
    assert(mode.iconKey.isNotEmpty, 'IconKey must not be empty');
    print('Mode: ${mode.name.padRight(22)} | Display: ${mode.displayName.padRight(20)} | Icon: ${mode.iconKey}');
  }

  assert(FlowPuzzleMode.fromString('constellationconnect') == FlowPuzzleMode.constellationConnect);
  assert(FlowPuzzleMode.fromString('SPATIALSLIDING') == FlowPuzzleMode.spatialSliding);
  assert(FlowPuzzleMode.fromString('unknown') == FlowPuzzleMode.constellationConnect);
  print('✓ FlowPuzzleMode enum resolution verified.');

  // 2. Verify Curated Constellations & Geometry
  assert(kCuratedConstellations.length >= 6, 'Expected at least 6 curated constellations');
  for (final pattern in kCuratedConstellations) {
    assert(pattern.id.isNotEmpty && pattern.name.isNotEmpty && pattern.story.isNotEmpty);
    assert(pattern.nodeCount >= 5, 'Every constellation must have at least 5 stars');
    for (int i = 0; i < pattern.nodes.length; i++) {
      final node = pattern.nodes[i];
      assert(node.id == i + 1, 'Node IDs must be 1-based sequential');
      assert(node.x >= 0.0 && node.x <= 1.0, 'X must be normalized between 0 and 1');
      assert(node.y >= 0.0 && node.y <= 1.0, 'Y must be normalized between 0 and 1');
      assert(node.label.isNotEmpty, 'Node label must not be empty');
    }
  }
  print('✓ Curated constellations geometry validated (${kCuratedConstellations.length} constellations).');

  // Test Constellation Node JSON serialization
  final sampleNode = const ConstellationNode(id: 1, x: 0.25, y: 0.75, label: 'Alpha');
  final json = sampleNode.toJson();
  final deserialized = ConstellationNode.fromJson(json);
  assert(deserialized.id == 1 && deserialized.x == 0.25 && deserialized.y == 0.75 && deserialized.label == 'Alpha');
  print('✓ ConstellationNode JSON serialization round-trip verified.');

  // Test ConstellationPattern.fromString
  final cassiopeia = ConstellationPattern.fromString('cassiopeia');
  assert(cassiopeia.id == 'cassiopeia');
  final fallbackConstellation = ConstellationPattern.fromString('non_existent');
  assert(fallbackConstellation.id == kCuratedConstellations.first.id);
  print('✓ ConstellationPattern lookup and fallback verified.');

  // 3. Verify SlidingGridState Logic & Solvability
  final solvedGrid = SlidingGridState.solved();
  assert(solvedGrid.isSolved, 'Solved grid must report isSolved == true');
  assert(solvedGrid.emptyIndex == 8, 'Empty tile must be at index 8');

  // Adjacency tests from solved state (empty at index 8: row 2, col 2)
  assert(solvedGrid.canMove(7), 'Tile 7 (row 2, col 1) should be movable');
  assert(solvedGrid.canMove(5), 'Tile 5 (row 1, col 2) should be movable');
  assert(!solvedGrid.canMove(4), 'Tile 4 (center) is diagonal, should not be movable');
  assert(!solvedGrid.canMove(0), 'Tile 0 is opposite corner, should not be movable');
  assert(!solvedGrid.canMove(8), 'Empty spot itself should not be movable');
  print('✓ SlidingGridState adjacency rules verified.');

  // Move tile 7 (value 8) into empty space 8
  final movedGrid = solvedGrid.move(7);
  assert(!movedGrid.isSolved, 'Grid should no longer be solved after move');
  assert(movedGrid.emptyIndex == 7, 'Empty space moved to index 7');
  assert(movedGrid.tiles[8] == 8, 'Tile 8 now resides at index 8');
  assert(movedGrid.tiles[7] == 0, 'Index 7 is now empty');

  // Moving back restores solved state
  final restoredGrid = movedGrid.move(8);
  assert(restoredGrid.isSolved, 'Moving back should restore solved state');
  assert(restoredGrid == solvedGrid, 'Restored grid should equal original');
  print('✓ Tile swap and bidirectional move restoration verified.');

  // Center empty slot test (index 4)
  final centerEmptyGrid = SlidingGridState(
    tiles: [1, 2, 3, 4, 0, 5, 6, 7, 8],
  );
  assert(centerEmptyGrid.emptyIndex == 4);
  final centerMoves = centerEmptyGrid.validMoves();
  assert(centerMoves.length == 4, 'Center slot must have 4 orthogonal neighbors');
  assert(centerMoves.contains(1) && centerMoves.contains(3) && centerMoves.contains(5) && centerMoves.contains(7));
  print('✓ Center slot 4-way orthogonal valid moves verified.');

  // Row wrapping protection test (e.g. index 2 row 0 col 2, and index 3 row 1 col 0)
  final wrapTestGrid = SlidingGridState(
    tiles: [1, 2, 0, 3, 4, 5, 6, 7, 8], // empty at index 2 (row 0, col 2)
  );
  assert(!wrapTestGrid.canMove(3), 'Index 3 must NOT wrap across row boundaries to move into index 2');
  assert(wrapTestGrid.canMove(1), 'Index 1 can move horizontally into index 2');
  assert(wrapTestGrid.canMove(5), 'Index 5 can move vertically into index 2');
  print('✓ Horizontal row-wrapping boundary checks verified.');

  // Shuffling Solvability Test
  final rng = Random(42);
  final shuffled = solvedGrid.shuffleSolvable(steps: 30, random: rng);
  assert(!shuffled.isSolved, 'Shuffled grid should not be solved');
  assert(shuffled.tiles.length == 9);
  assert(shuffled.tiles.toSet().length == 9, 'All 9 distinct tile values 0..8 must exist');
  print('✓ Shuffled solvable grid integrity verified.');

  // 4. Verify FlowPuzzleSessionState
  var session = FlowPuzzleSessionState.initial();
  assert(session.mode == FlowPuzzleMode.constellationConnect);
  assert(session.connectedNodeIndices.isEmpty);
  assert(session.nextExpectedNodeId == 1);
  assert(session.progressFraction == 0.0);
  assert(!session.isCompleted);

  // Connect star 1
  session = session.copyWith(
    connectedNodeIndices: [0],
    totalInteractions: 1,
  );
  assert(session.nextExpectedNodeId == 2);
  assert(session.progressFraction > 0.0);
  assert(session.totalInteractions == 1);

  // Connect remaining stars of Cassiopeia (5 stars)
  final cass = session.activeConstellation;
  assert(cass.nodeCount == 5);
  session = session.copyWith(
    connectedNodeIndices: [0, 1, 2, 3, 4],
    isCompleted: true,
    totalInteractions: 5,
  );
  assert(session.isCompleted);
  assert(session.progressFraction == 1.0);
  print('✓ Constellation tracing session progression and completion verified.');

  // Test Sliding Grid Session Mode
  var gridSession = FlowPuzzleSessionState.initial(
    initialMode: FlowPuzzleMode.spatialSliding,
  ).copyWith(
    gridState: solvedGrid,
    isCompleted: true,
  );
  assert(gridSession.mode == FlowPuzzleMode.spatialSliding);
  assert(gridSession.progressFraction == 1.0);
  assert(gridSession.isCompleted);
  print('✓ Sliding grid session state and progress verified.');

  print('=== ALL Flow & Spatial Puzzles Assertions PASSED successfully! (100% Validated) ===');
}
