/// Types of gentle spatial and cognitive flow puzzles in Firefly.
enum FlowPuzzleMode {
  constellationConnect,
  spatialSliding;

  String get displayName {
    switch (this) {
      case FlowPuzzleMode.constellationConnect:
        return 'Constellation Flow';
      case FlowPuzzleMode.spatialSliding:
        return 'Harmony Tiles';
    }
  }

  String get description {
    switch (this) {
      case FlowPuzzleMode.constellationConnect:
        return 'Gently connect quiet stars to reveal serene celestial outlines.';
      case FlowPuzzleMode.spatialSliding:
        return 'Slowly slide tactile tiles into harmonious order with zero pressure.';
    }
  }

  String get iconKey {
    switch (this) {
      case FlowPuzzleMode.constellationConnect:
        return 'sparkles';
      case FlowPuzzleMode.spatialSliding:
        return 'square.grid.3x3';
    }
  }

  static FlowPuzzleMode fromString(String value) {
    return FlowPuzzleMode.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => FlowPuzzleMode.constellationConnect,
    );
  }
}
