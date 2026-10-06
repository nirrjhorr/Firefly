import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
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
    final colors = context.colors;
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
          inhaleColor: inhaleColor ?? colors.actionSage,
          exhaleColor: exhaleColor ?? colors.accentSecondary,
        ),
        child: child != null ? Center(child: child) : null,
      ),
    );
  }
}
