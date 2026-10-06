import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/labyrinth_coord.dart';
import '../../domain/models/labyrinth_pattern_type.dart';
import '../../domain/models/labyrinth_session_state.dart';

/// Provider for Meditative Labyrinth Tracing session controller.
final labyrinthControllerProvider =
    StateNotifierProvider<LabyrinthController, LabyrinthSessionState>((ref) {
  return LabyrinthController();
});

/// Riverpod StateNotifier controlling finger touch tracing, path progress, and tactile feedback.
class LabyrinthController extends StateNotifier<LabyrinthSessionState> {
  LabyrinthController()
      : super(const LabyrinthSessionState(pattern: LabyrinthPatternType.classical));

  int _lastHapticNode = -1;

  /// Switches tracing pattern and clears existing stroke trail.
  void setPattern(LabyrinthPatternType pattern) {
    if (state.pattern == pattern) return;
    state = LabyrinthSessionState(
      pattern: pattern,
      showGuidePath: state.showGuidePath,
      elapsedSeconds: state.elapsedSeconds,
    );
    _lastHapticNode = -1;
  }

  /// Begins a touch tracing stroke.
  void onPanStart(Offset point) {
    final coord = LabyrinthCoord(point.dx, point.dy);
    state = state.copyWith(
      isTracingActive: true,
      tracedPoints: [...state.tracedPoints, coord],
    );
  }

  /// Updates stroke with new point and calculates proximity progress along the guide path.
  void onPanUpdate(Offset point, List<LabyrinthCoord> guidePoints) {
    final coord = LabyrinthCoord(point.dx, point.dy);
    final updatedPoints = List<LabyrinthCoord>.from(state.tracedPoints)..add(coord);

    // Keep memory clean: cap maximum points at 400 to maintain 60fps performance
    if (updatedPoints.length > 400) {
      updatedPoints.removeRange(0, updatedPoints.length - 400);
    }

    // Find closest guide node to current fingertip
    double progress = state.progress;
    if (guidePoints.isNotEmpty) {
      double minDistance = double.infinity;
      int closestIndex = 0;

      for (int i = 0; i < guidePoints.length; i++) {
        final d = guidePoints[i].distanceTo(coord);
        if (d < minDistance) {
          minDistance = d;
          closestIndex = i;
        }
      }

      // Proximity threshold of 60dp: if user is close enough, advance progress
      if (minDistance < 60.0) {
        final nodeProgress = (closestIndex / (guidePoints.length - 1)).clamp(0.0, 1.0);
        if (nodeProgress > progress) {
          progress = nodeProgress;
        }

        // Trigger gentle haptic tick every ~20% of path traversed
        final hapticStep = (closestIndex ~/ 20);
        if (hapticStep != _lastHapticNode) {
          _lastHapticNode = hapticStep;
          _triggerGentleHaptic();
        }
      }
    }

    final isDone = progress >= 0.95;
    final loops = isDone && !state.isCompleted
        ? state.loopsCompleted + 1
        : state.loopsCompleted;

    state = state.copyWith(
      tracedPoints: updatedPoints,
      progress: progress,
      isCompleted: state.isCompleted || isDone,
      loopsCompleted: loops,
    );
  }

  /// Concludes active touch stroke.
  void onPanEnd() {
    state = state.copyWith(isTracingActive: false);
  }

  /// Clears user's finger trail to start fresh.
  void clearTrail() {
    state = state.copyWith(
      tracedPoints: const [],
      progress: 0.0,
      isCompleted: false,
    );
    _lastHapticNode = -1;
  }

  /// Toggles visibility of the background guide path.
  void toggleGuidePath() {
    state = state.copyWith(showGuidePath: !state.showGuidePath);
  }

  /// Increments elapsed seconds.
  void tickTimer() {
    state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
  }

  Future<void> _triggerGentleHaptic() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (_) {
      // Safe fallback on unsupported platforms
    }
  }
}
