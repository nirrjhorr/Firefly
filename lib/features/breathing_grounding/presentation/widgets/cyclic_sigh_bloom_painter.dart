import 'package:flutter/material.dart';
import '../../domain/models/breathing_session_state.dart';

/// CustomPainter rendering an organic, multi-layered bloom visualizer
/// that expands and contracts smoothly with cyclic sighing respiration cadences.
class CyclicSighBloomPainter extends CustomPainter {
  final double progress;
  final BreathingPhase phase;
  final bool reducedMotion;
  final Color inhaleColor;
  final Color exhaleColor;

  static const double minRadius = 50.0;
  static const double maxRadius = 120.0;
  static const double staticRadius = 85.0;

  // Cached paint object to prevent garbage collection churn during 60/120fps animations
  final Paint _paint = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.fill;

  CyclicSighBloomPainter({
    required this.progress,
    required this.phase,
    this.reducedMotion = false,
    this.inhaleColor = const Color(0xFF4A7862), // Serene sage
    this.exhaleColor = const Color(0xFF3B5B6C), // Dusk blue
  });

  /// Computes the visual radius based on breathing phase, progress, and accessibility settings.
  double computeRadius() {
    if (reducedMotion) {
      return staticRadius;
    }

    final curvedProgress = Curves.easeInOutCubic.transform(progress.clamp(0.0, 1.0));
    if (phase == BreathingPhase.inhale) {
      return minRadius + (maxRadius - minRadius) * curvedProgress;
    } else {
      return maxRadius - (maxRadius - minRadius) * curvedProgress;
    }
  }

  /// Computes the active tint color transitioning between sage (inhale) and dusk blue (exhale).
  Color computeActiveColor() {
    if (reducedMotion) {
      return inhaleColor;
    }

    final curvedProgress = Curves.easeInOut.transform(progress.clamp(0.0, 1.0));
    if (phase == BreathingPhase.inhale) {
      return Color.lerp(exhaleColor, inhaleColor, curvedProgress) ?? inhaleColor;
    } else {
      return Color.lerp(inhaleColor, exhaleColor, curvedProgress) ?? exhaleColor;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = computeRadius();
    final activeColor = computeActiveColor();

    // Ring 1 (Outer glow aura: 135% radius, 8% opacity)
    _paint.color = activeColor.withOpacity(0.08);
    canvas.drawCircle(center, baseRadius * 1.35, _paint);

    // Ring 2 (Middle ambient glow: 118% radius, 20% opacity)
    _paint.color = activeColor.withOpacity(0.20);
    canvas.drawCircle(center, baseRadius * 1.18, _paint);

    // Ring 3 (Inner bloom ring: 100% radius, 35% opacity)
    _paint.color = activeColor.withOpacity(0.35);
    canvas.drawCircle(center, baseRadius, _paint);

    // Center nucleus core: 70% radius, 75% opacity with gentle depth
    _paint.color = activeColor.withOpacity(0.75);
    canvas.drawCircle(center, baseRadius * 0.70, _paint);
  }

  @override
  bool shouldRepaint(covariant CyclicSighBloomPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.phase != phase ||
        oldDelegate.reducedMotion != reducedMotion ||
        oldDelegate.inhaleColor != inhaleColor ||
        oldDelegate.exhaleColor != exhaleColor;
  }
}
