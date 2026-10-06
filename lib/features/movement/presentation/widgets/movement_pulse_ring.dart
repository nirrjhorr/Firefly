import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/movement_session_state.dart';

/// Low-stimulation organic circular visualizer with rhythmic cadence pulsing.
class MovementPulseRing extends StatefulWidget {
  final MovementSessionState state;
  final VoidCallback? onTap;

  const MovementPulseRing({
    super.key,
    required this.state,
    this.onTap,
  });

  @override
  State<MovementPulseRing> createState() => _MovementPulseRingState();
}

class _MovementPulseRingState extends State<MovementPulseRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    final bpm = widget.state.activity.cadenceBpm ?? 30;
    final pulseDurationMs = (60000 / bpm).round().clamp(600, 3000);

    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: pulseDurationMs),
    );

    _scaleAnimation = Tween<double>(begin: 0.94, end: 1.04).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOutSine,
      ),
    );

    if (widget.state.status == MovementSessionStatus.active) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant MovementPulseRing oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update animation duration if cadence changes
    if (oldWidget.state.activity.cadenceBpm != widget.state.activity.cadenceBpm) {
      final bpm = widget.state.activity.cadenceBpm ?? 30;
      final pulseDurationMs = (60000 / bpm).round().clamp(600, 3000);
      _pulseController.duration = Duration(milliseconds: pulseDurationMs);
    }

    // React to status changes
    if (widget.state.status == MovementSessionStatus.active &&
        !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (widget.state.status != MovementSessionStatus.active &&
        _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.animateTo(0.0, duration: const Duration(milliseconds: 300));
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final state = widget.state;
    final isRunning = state.status == MovementSessionStatus.active;
    final isCompleted = state.status == MovementSessionStatus.completed;

    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: SizedBox(
          width: 240,
          height: 240,
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              final scale = isRunning ? _scaleAnimation.value : 1.0;
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Ambient background glow
                  Container(
                    width: 220 * scale,
                    height: 220 * scale,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          colors.actionSage.withOpacity(isRunning ? 0.18 : 0.08),
                          colors.actionSage.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),

                  // Circular progress track
                  CustomPaint(
                    size: const Size(200, 200),
                    painter: _RingPainter(
                      progress: state.progress,
                      trackColor: colors.bgSurfaceElevated.withOpacity(0.8),
                      progressColor: isCompleted ? colors.actionSage : colors.actionSage,
                      strokeWidth: 8.0,
                    ),
                  ),

                  // Inner content
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Time display
                      Text(
                        state.formattedDisplayTime,
                        style: typography.displayLarge.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Status subtext
                      Text(
                        isCompleted
                            ? 'Complete'
                            : isRunning
                                ? (state.activity.isOpenEnded ? 'Pacing' : 'Remaining')
                                : state.status == MovementSessionStatus.paused
                                    ? 'Paused'
                                    : 'Ready',
                        style: typography.labelMedium.copyWith(
                          color: colors.textSecondary,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  _RingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Active progress arc
    if (progress > 0.0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      const startAngle = -math.pi / 2;
      final sweepAngle = 2 * math.pi * progress;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor;
  }
}
