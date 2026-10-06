import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/constellation_pattern.dart';
import '../../domain/models/flow_puzzle_session_state.dart';
import '../../domain/models/flow_puzzle_type.dart';
import '../../domain/models/sliding_grid_state.dart';

/// Provider for Flow & Spatial Puzzles controller.
final flowPuzzleControllerProvider =
    StateNotifierProvider<FlowPuzzleController, FlowPuzzleSessionState>((ref) {
  return FlowPuzzleController();
});

/// Riverpod StateNotifier managing tactile interaction, node connections, and tile sliding.
class FlowPuzzleController extends StateNotifier<FlowPuzzleSessionState> {
  FlowPuzzleController({FlowPuzzleMode? initialMode})
      : super(FlowPuzzleSessionState.initial(initialMode: initialMode));

  /// Switches active puzzle modality.
  void setMode(FlowPuzzleMode mode) {
    if (state.mode == mode) return;
    HapticFeedback.selectionClick();
    state = state.copyWith(
      mode: mode,
      isCompleted: false,
    );
  }

  /// Sets the active constellation pattern and resets connections.
  void setConstellation(ConstellationPattern pattern) {
    if (state.activeConstellation.id == pattern.id) return;
    HapticFeedback.selectionClick();
    state = state.copyWith(
      activeConstellation: pattern,
      connectedNodeIndices: const [],
      isCompleted: false,
    );
  }

  /// Attempts to connect to the node at [nodeIndex].
  /// In non-clinical design, tapping the next expected star connects it.
  /// If tapping the first star, it initializes the sequence.
  bool connectNode(int nodeIndex) {
    final pattern = state.activeConstellation;
    if (nodeIndex < 0 || nodeIndex >= pattern.nodes.length) return false;
    final node = pattern.nodes[nodeIndex];

    // Check if this node is the next expected one
    if (node.id == state.nextExpectedNodeId) {
      HapticFeedback.selectionClick();
      final updated = List<int>.from(state.connectedNodeIndices)..add(nodeIndex);
      final isNowCompleted = updated.length == pattern.nodeCount;

      if (isNowCompleted) {
        HapticFeedback.mediumImpact();
      }

      state = state.copyWith(
        connectedNodeIndices: updated,
        totalInteractions: state.totalInteractions + 1,
        isCompleted: isNowCompleted,
      );
      return true;
    }

    return false;
  }

  /// Resets the current constellation tracing without changing the pattern.
  void resetConstellation() {
    HapticFeedback.lightImpact();
    state = state.copyWith(
      connectedNodeIndices: const [],
      isCompleted: false,
    );
  }

  /// Undoes the last connected star.
  void undoLastNode() {
    if (state.connectedNodeIndices.isEmpty) return;
    HapticFeedback.lightImpact();
    final updated = List<int>.from(state.connectedNodeIndices)..removeLast();
    state = state.copyWith(
      connectedNodeIndices: updated,
      isCompleted: false,
    );
  }

  /// Slides a tile at [tileIndex] into the adjacent empty space.
  bool slideTile(int tileIndex) {
    if (!state.gridState.canMove(tileIndex)) return false;

    HapticFeedback.selectionClick();
    final nextGrid = state.gridState.move(tileIndex);
    final solved = nextGrid.isSolved;

    if (solved) {
      HapticFeedback.mediumImpact();
    }

    state = state.copyWith(
      gridState: nextGrid,
      moveCount: state.moveCount + 1,
      totalInteractions: state.totalInteractions + 1,
      isCompleted: solved,
    );
    return true;
  }

  /// Shuffles the 3x3 grid with guaranteed legal solvable moves.
  void shuffleGrid({int steps = 24}) {
    HapticFeedback.lightImpact();
    state = state.copyWith(
      gridState: state.gridState.shuffleSolvable(steps: steps),
      moveCount: 0,
      isCompleted: false,
    );
  }

  /// Gently restores the grid to its solved tranquil order.
  void resetGrid() {
    HapticFeedback.lightImpact();
    state = state.copyWith(
      gridState: SlidingGridState.solved(),
      moveCount: 0,
      isCompleted: true,
    );
  }

  /// Increments soft session timer.
  void tickTimer() {
    state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
  }
}
