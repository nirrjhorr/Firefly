import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../domain/models/somatic_exercise_mode.dart';

/// Serene organic pulse aura visualizer for somatic centering exercises (Story 12.2).
/// Pulses at a natural resting parasympathetic cadence (~0.1 Hz) without jarring flashes.
class SomaticVisualizerWidget extends StatefulWidget {
  const SomaticVisualizerWidget({
    super.key,
    required this.mode,
    this.size = 200.0,
  });

  final SomaticExerciseMode mode;
  final double size;

  @override
  State<SomaticVisualizerWidget> createState() =>
      _SomaticVisualizerWidgetState();
}

class _SomaticVisualizerWidgetState extends State<SomaticVisualizerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  (Color, Color, Color) _getModePalette(SomaticExerciseMode mode) {
    switch (mode) {
      case SomaticExerciseMode.heavyBody:
        return (
          const Color(0xFF8D6E63), // warm earth amber
          const Color(0xFF5D4037),
          const Color(0xFFD7CCC8),
        );
      case SomaticExerciseMode.warmHands:
        return (
          const Color(0xFFE07A5F), // soothing hearth peach
          const Color(0xFFD46849),
          const Color(0xFFFFD166),
        );
      case SomaticExerciseMode.mountainPosture:
        return (
          const Color(0xFF5B7065), // rooted slate granite
          const Color(0xFF394E44),
          const Color(0xFF94A89D),
        );
      case SomaticExerciseMode.mindfulPause:
        return (
          const Color(0xFF6E9987), // calm sage
          const Color(0xFF4A7C59),
          const Color(0xFFA8D5BA),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.of(context).disableAnimations;
    final (primaryColor, darkColor, lightColor) = _getModePalette(widget.mode);

    if (disableAnimations) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: _PulseAuraPainter(
            animationValue: 0.5,
            primaryColor: primaryColor,
            darkColor: darkColor,
            lightColor: lightColor,
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _PulseAuraPainter(
              animationValue: _pulseController.value,
              primaryColor: primaryColor,
              darkColor: darkColor,
              lightColor: lightColor,
            ),
          ),
        );
      },
    );
  }
}

class _PulseAuraPainter extends CustomPainter {
  const _PulseAuraPainter({
    required this.animationValue,
    required this.primaryColor,
    required this.darkColor,
    required this.lightColor,
  });

  final double animationValue;
  final Color primaryColor;
  final Color darkColor;
  final Color lightColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = math.min(size.width, size.height) * 0.28;

    // Outer gentle aura ring (subtle expansion)
    final outerExpansion = 1.0 + (0.28 * math.sin(animationValue * math.pi));
    final outerPaint = Paint()
      ..color = primaryColor.withOpacity(0.12 * (1.0 - animationValue * 0.3))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, baseRadius * outerExpansion * 1.5, outerPaint);

    // Mid pulse glow ring
    final midExpansion = 1.0 + (0.18 * math.sin((animationValue + 0.2) * math.pi));
    final midPaint = Paint()
      ..color = lightColor.withOpacity(0.22)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, baseRadius * midExpansion * 1.25, midPaint);

    // Inner core sphere with gentle gradient
    final innerPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          lightColor.withOpacity(0.85),
          primaryColor.withOpacity(0.70),
          darkColor.withOpacity(0.55),
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: baseRadius));
    canvas.drawCircle(center, baseRadius, innerPaint);

    // Center focal point
    final focalPaint = Paint()
      ..color = Colors.white.withOpacity(0.35 + (0.15 * animationValue))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, baseRadius * 0.28, focalPaint);
  }

  @override
  bool shouldRepaint(covariant _PulseAuraPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.primaryColor != primaryColor;
  }
}
