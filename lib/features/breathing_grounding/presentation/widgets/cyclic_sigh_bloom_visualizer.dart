import 'package:flutter/material.dart';
import '../../domain/models/breathing_session_state.dart';
import 'cyclic_sigh_bloom_painter.dart';

/// Widget embedding [CyclicSighBloomPainter] with responsive layout,
/// center child alignment, and accessibility-compliant reduced motion detection.
class CyclicSighBloomVisualizer extends StatelessWidget {
  final double progress;
  final BreathingPhase phase;
  final double size;
  final Widget? child;
  final bool? overrideReducedMotion;
  final Color? inhaleColor;
  final Color? exhaleColor;

  const CyclicSighBloomVisualizer({
    super.key,
    required this.progress,
    required this.phase,
    this.size = 320.0,
    this.child,
    this.overrideReducedMotion,
    this.inhaleColor,
    this.exhaleColor,
  });

  @override
  Widget build(BuildContext context) {
    final isReducedMotion = overrideReducedMotion ??
        MediaQuery.maybeOf(context)?.disableAnimations ??
        false;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: CyclicSighBloomPainter(
          progress: progress,
          phase: phase,
          reducedMotion: isReducedMotion,
          inhaleColor: inhaleColor ?? const Color(0xFF4A7862),
          exhaleColor: exhaleColor ?? const Color(0xFF3B5B6C),
        ),
        child: child != null ? Center(child: child) : null,
      ),
    );
  }
}
