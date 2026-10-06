import 'dart:math' as math;
import 'labyrinth_coord.dart';

/// The 4 geometric contemplative tracing patterns in Firefly (Story 12.3).
enum LabyrinthPatternType {
  /// Unicursal 7-circuit Cretan labyrinth path winding inward to center.
  classical,

  /// Concentric continuous Archimedean spiral pulling awareness inward.
  spiral,

  /// Bilateral flowing figure-8 infinity loop for alternating hemispheric relaxation.
  infinity,

  /// Rhythmic serpentine Greek meander wave pattern.
  meander;

  String get title {
    switch (this) {
      case LabyrinthPatternType.classical:
        return 'Classical Cretan Labyrinth';
      case LabyrinthPatternType.spiral:
        return 'Concentric Inward Spiral';
      case LabyrinthPatternType.infinity:
        return 'Rhythmic Infinity Loop';
      case LabyrinthPatternType.meander:
        return 'Harmonic Meander Waves';
    }
  }

  String get subtitle {
    switch (this) {
      case LabyrinthPatternType.classical:
        return 'Ancient unicursal path to calm center';
      case LabyrinthPatternType.spiral:
        return 'Continuous settling into stillness';
      case LabyrinthPatternType.infinity:
        return 'Flowing bilateral motor soothing';
      case LabyrinthPatternType.meander:
        return 'Steady rhythmic geometric waves';
    }
  }

  String get description {
    switch (this) {
      case LabyrinthPatternType.classical:
        return 'Trace your finger through the single unbroken path. There are no dead ends or wrong turns—simply follow the windings until you rest in the center.';
      case LabyrinthPatternType.spiral:
        return 'Follow the smooth inward curve from outer periphery to inner focal point, watching thoughts narrow into calm stillness.';
      case LabyrinthPatternType.infinity:
        return 'Trace an effortless figure-8 loop in continuous rhythm. Bilateral motor repetition gently eases anxious autonomic tension.';
      case LabyrinthPatternType.meander:
        return 'Guide your finger through alternating geometric crests and valleys, providing predictable, steady tactile grounding.';
    }
  }

  String get scientificMechanism {
    switch (this) {
      case LabyrinthPatternType.classical:
        return 'Unicursal motor tracking activates open-monitoring meditation without cognitive load.';
      case LabyrinthPatternType.spiral:
        return 'Centripetal visuomotor tracking reduces peripheral visual scanning hyper-vigilance.';
      case LabyrinthPatternType.infinity:
        return 'Bilateral tactile movement fosters interhemispheric somatic co-regulation.';
      case LabyrinthPatternType.meander:
        return 'Rhythmic motor pacing down-regulates autonomic sympathetic drive.';
    }
  }

  String get iconKey {
    switch (this) {
      case LabyrinthPatternType.classical:
        return 'fingerprint';
      case LabyrinthPatternType.spiral:
        return 'cyclone';
      case LabyrinthPatternType.infinity:
        return 'all_inclusive';
      case LabyrinthPatternType.meander:
        return 'waves';
    }
  }

  /// Generates parameterized geometric path coordinates scaled to given dimensions.
  List<LabyrinthCoord> generatePathPoints(double width, double height) {
    final centerX = width / 2;
    final centerY = height / 2;
    final radius = math.min(width, height) * 0.42;
    final points = <LabyrinthCoord>[];

    switch (this) {
      case LabyrinthPatternType.classical:
        // Classical multi-circuit winding path inward
        const totalSteps = 120;
        for (int i = 0; i <= totalSteps; i++) {
          final t = i / totalSteps;
          final turns = 4.5;
          final angle = t * turns * 2 * math.pi;
          // Radius narrows inward with gentle undulating circuit amplitude
          final r = radius * (1.0 - t * 0.88) + (math.sin(t * 12 * math.pi) * (radius * 0.04));
          final x = centerX + r * math.cos(angle);
          final y = centerY + r * math.sin(angle);
          points.add(LabyrinthCoord(x, y));
        }
        break;

      case LabyrinthPatternType.spiral:
        // Archimedean inward spiral
        const totalSteps = 140;
        for (int i = 0; i <= totalSteps; i++) {
          final t = i / totalSteps;
          final turns = 5.0;
          final angle = t * turns * 2 * math.pi;
          final r = radius * (1.0 - (t * 0.92));
          final x = centerX + r * math.cos(angle);
          final y = centerY + r * math.sin(angle);
          points.add(LabyrinthCoord(x, y));
        }
        break;

      case LabyrinthPatternType.infinity:
        // Lemniscate of Bernoulli (figure-8)
        const totalSteps = 120;
        final a = radius * 1.15;
        for (int i = 0; i <= totalSteps; i++) {
          final t = (i / totalSteps) * 2 * math.pi;
          final denom = 1 + math.sin(t) * math.sin(t);
          final x = centerX + (a * math.cos(t)) / denom;
          final y = centerY + (a * math.sin(t) * math.cos(t)) / denom;
          points.add(LabyrinthCoord(x, y));
        }
        break;

      case LabyrinthPatternType.meander:
        // Rhythmic alternating meander waves
        const totalSteps = 100;
        final waveWidth = radius * 1.8;
        final startX = centerX - waveWidth / 2;
        for (int i = 0; i <= totalSteps; i++) {
          final t = i / totalSteps;
          final x = startX + t * waveWidth;
          final y = centerY + math.sin(t * 6 * math.pi) * (radius * 0.65);
          points.add(LabyrinthCoord(x, y));
        }
        break;
    }

    return points;
  }

  static LabyrinthPatternType fromString(String value) {
    final normalized = value.trim().toLowerCase();
    for (final pattern in LabyrinthPatternType.values) {
      if (pattern.name.toLowerCase() == normalized) {
        return pattern;
      }
    }
    return LabyrinthPatternType.classical;
  }
}
