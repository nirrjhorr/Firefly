import 'dart:math';

/// Immutable domain model for a tranquil 3x3 sliding tile puzzle grid.
/// Empty slot is represented by 0. Solved configuration is [1, 2, 3, 4, 5, 6, 7, 8, 0].
class SlidingGridState {
  SlidingGridState({
    required this.tiles,
  }) : assert(tiles.length == 9, 'Grid must have exactly 9 elements');

  final List<int> tiles;

  static const List<int> solvedTiles = [1, 2, 3, 4, 5, 6, 7, 8, 0];

  factory SlidingGridState.solved() => SlidingGridState(tiles: solvedTiles);

  int get emptyIndex => tiles.indexOf(0);

  bool get isSolved {
    for (int i = 0; i < 9; i++) {
      if (tiles[i] != solvedTiles[i]) return false;
    }
    return true;
  }

  /// Whether the tile at [index] can slide into the empty space.
  bool canMove(int index) {
    if (index < 0 || index >= 9 || index == emptyIndex) return false;
    final row = index ~/ 3;
    final col = index % 3;
    final emptyRow = emptyIndex ~/ 3;
    final emptyCol = emptyIndex % 3;

    final isHorizontalNeighbor = row == emptyRow && (col - emptyCol).abs() == 1;
    final isVerticalNeighbor = col == emptyCol && (row - emptyRow).abs() == 1;

    return isHorizontalNeighbor || isVerticalNeighbor;
  }

  /// Swaps the tile at [index] with the empty space if valid.
  SlidingGridState move(int index) {
    if (!canMove(index)) return this;
    final nextTiles = List<int>.from(tiles);
    final eIdx = emptyIndex;
    nextTiles[eIdx] = nextTiles[index];
    nextTiles[index] = 0;
    return SlidingGridState(tiles: nextTiles);
  }

  /// Finds all tile indices that can currently move into the empty spot.
  List<int> validMoves() {
    final moves = <int>[];
    for (int i = 0; i < 9; i++) {
      if (canMove(i)) moves.add(i);
    }
    return moves;
  }

  /// Shuffles the grid by performing [steps] random legal moves.
  /// This guarantees 100% mathematical solvability without permutation parity traps.
  SlidingGridState shuffleSolvable({int steps = 24, Random? random}) {
    final rng = random ?? Random();
    var current = isSolved ? this : SlidingGridState.solved();
    int lastMovedTile = -1;

    for (int i = 0; i < steps; i++) {
      final moves = current.validMoves();
      // Avoid immediately undoing the previous move to ensure good dispersal
      final filteredMoves = moves.where((m) => current.tiles[m] != lastMovedTile).toList();
      final candidates = filteredMoves.isNotEmpty ? filteredMoves : moves;
      final chosen = candidates[rng.nextInt(candidates.length)];
      lastMovedTile = current.tiles[chosen];
      current = current.move(chosen);
    }

    return current;
  }

  Map<String, dynamic> toJson() => {'tiles': tiles};

  factory SlidingGridState.fromJson(Map<String, dynamic> json) =>
      SlidingGridState(tiles: List<int>.from(json['tiles'] as List));

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SlidingGridState &&
          other.tiles.length == tiles.length &&
          List.generate(9, (i) => other.tiles[i] == tiles[i]).every((e) => e);

  @override
  int get hashCode => tiles.fold(0, (prev, elem) => prev ^ elem.hashCode);
}
