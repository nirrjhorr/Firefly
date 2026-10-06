import 'constellation_pattern.dart';
import 'flow_puzzle_type.dart';
import 'sliding_grid_state.dart';

/// Immutable session state model for Flow & Spatial Puzzles (Story 13.2).
class FlowPuzzleSessionState {
  const FlowPuzzleSessionState({
    required this.mode,
    required this.activeConstellation,
    required this.connectedNodeIndices,
    required this.gridState,
    this.moveCount = 0,
    this.elapsedSeconds = 0,
    this.totalInteractions = 0,
    this.isCompleted = false,
  });

  final FlowPuzzleMode mode;
  final ConstellationPattern activeConstellation;
  final List<int> connectedNodeIndices;
  final SlidingGridState gridState;
  final int moveCount;
  final int elapsedSeconds;
  final int totalInteractions;
  final bool isCompleted;

  factory FlowPuzzleSessionState.initial({FlowPuzzleMode? initialMode}) {
    final mode = initialMode ?? FlowPuzzleMode.constellationConnect;
    return FlowPuzzleSessionState(
      mode: mode,
      activeConstellation: kCuratedConstellations.first,
      connectedNodeIndices: const [],
      gridState: SlidingGridState.solved().shuffleSolvable(steps: 20),
    );
  }

  /// 1-based ID of the next star required in sequence for Constellation Flow.
  int get nextExpectedNodeId => connectedNodeIndices.length + 1;

  /// Progress fraction (0.0 to 1.0) for current puzzle mode.
  double get progressFraction {
    switch (mode) {
      case FlowPuzzleMode.constellationConnect:
        final total = activeConstellation.nodeCount;
        if (total == 0) return 0.0;
        return (connectedNodeIndices.length / total).clamp(0.0, 1.0);
      case FlowPuzzleMode.spatialSliding:
        return gridState.isSolved ? 1.0 : 0.0;
    }
  }

  FlowPuzzleSessionState copyWith({
    FlowPuzzleMode? mode,
    ConstellationPattern? activeConstellation,
    List<int>? connectedNodeIndices,
    SlidingGridState? gridState,
    int? moveCount,
    int? elapsedSeconds,
    int? totalInteractions,
    bool? isCompleted,
  }) {
    return FlowPuzzleSessionState(
      mode: mode ?? this.mode,
      activeConstellation: activeConstellation ?? this.activeConstellation,
      connectedNodeIndices: connectedNodeIndices ?? this.connectedNodeIndices,
      gridState: gridState ?? this.gridState,
      moveCount: moveCount ?? this.moveCount,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      totalInteractions: totalInteractions ?? this.totalInteractions,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
