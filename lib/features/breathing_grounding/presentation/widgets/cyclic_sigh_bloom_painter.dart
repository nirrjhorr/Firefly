import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../domain/models/breathing_session_state.dart';

/// CustomPainter rendering an organic, multi-layered concentric bloom visualizer
/// that adapts dynamically to respiration pacing (Inhale, Hold, Exhale) and idle ambient pulse.
class CyclicSighBloomPainter extends CustomPainter {
  final double progress;
  final BreathingPhase phase;
  final bool isActive;
  final double ambientPulse;
  final bool reducedMotion;
  final Color inhaleColor;
  final Color exhaleColor;
  final Color holdColor;

  static const double minRadius = 54.0;   // ~47% base scale
  static const double maxRadius = 115.0;  // 100% full scale
  static const double staticRadius = 80.0;

  final Paint _paint = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.fill;

  CyclicSighBloomPainter({
    required this.progress,
    required this.phase,
    this.isActive = false,
    this.ambientPulse = 0.0,
    this.reducedMotion = false,
    this.inhaleColor = const Color(0xFF4A7862), // Serene sage
    this.exhaleColor = const Color(0xFF3B5B6C), // Dusk blue
    this.holdColor = const Color(0xFFD99B65),   // Warm amber
  });

  /// Computes the visual radius based on active breathing phase or idle ambient resting state.
  double computeRadius() {
    if (reducedMotion) {
      return staticRadius;
    }

    if (!isActive) {
      // Idle resting state: ~50% scale with soft ambient pulse
      final idlePulseOffset = math.sin(ambientPulse * math.pi * 2) * 4.0;
      return minRadius + idlePulseOffset;
    }

    final curvedProgress = Curves.easeInOutCubic.transform(progress.clamp(0.0, 1.0));
    switch (phase) {
      case BreathingPhase.inhale:
        return minRadius + (maxRadius - minRadius) * curvedProgress;
      case BreathingPhase.inhaleHold:
        // Subtle organic shimmer/wave while holding lungs full
        final shimmer = math.sin(curvedProgress * math.pi * 2) * 3.5;
        return maxRadius + shimmer;
      case BreathingPhase.exhale:
        return maxRadius - (maxRadius - minRadius) * curvedProgress;
      case BreathingPhase.exhaleHold:
        // Resting minimum radius with slight stillness pulse
        final pulse = math.sin(curvedProgress * math.pi * 2) * 2.0;
        return minRadius + pulse;
    }
  }

  /// Computes the active tint color transitioning between phases.
  Color computeActiveColor() {
    if (reducedMotion || !isActive) {
      return inhaleColor;
    }

    final curvedProgress = Curves.easeInOut.transform(progress.clamp(0.0, 1.0));
    switch (phase) {
      case BreathingPhase.inhale:
        return Color.lerp(exhaleColor, inhaleColor, curvedProgress) ?? inhaleColor;
      case BreathingPhase.inhaleHold:
        return Color.lerp(inhaleColor, holdColor, curvedProgress * 0.5) ?? inhaleColor;
      case BreathingPhase.exhale:
        return Color.lerp(inhaleColor, exhaleColor, curvedProgress) ?? exhaleColor;
      case BreathingPhase.exhaleHold:
        return Color.lerp(exhaleColor, holdColor, curvedProgress * 0.3) ?? exhaleColor;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final activeColor = computeActiveColor();
    final radius = computeRadius();

    if (!reducedMotion) {
      // Outer aura ring 3 (softest ambient glow)
      _paint.color = activeColor.withOpacity(isActive ? 0.06 : 0.04);
      canvas.drawCircle(center, radius * 1.36, _paint);

      // Outer aura ring 2
      _paint.color = activeColor.withOpacity(isActive ? 0.10 : 0.07);
      canvas.drawCircle(center, radius * 1.24, _paint);

      // Inner halo ring 1
      _paint.color = activeColor.withOpacity(isActive ? 0.16 : 0.11);
      canvas.drawCircle(center, radius * 1.12, _paint);
    }

    // Core organic bloom sphere
    _paint.color = activeColor.withOpacity(isActive ? 0.88 : 0.75);
    canvas.drawCircle(center, radius, _paint);

    // Subtle center highlight
    if (!reducedMotion) {
      _paint.color = Colors.white.withOpacity(0.12);
      canvas.drawCircle(center, radius * 0.4, _paint);
    }
  }

  @override
  bool shouldRepaint(covariant CyclicSighBloomPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.phase != phase ||
        oldDelegate.isActive != isActive ||
        oldDelegate.ambientPulse != ambientPulse ||
        oldDelegate.reducedMotion != reducedMotion ||
        oldDelegate.inhaleColor != inhaleColor ||
        oldDelegate.exhaleColor != exhaleColor ||
        oldDelegate.holdColor != holdColor;
  }
}
