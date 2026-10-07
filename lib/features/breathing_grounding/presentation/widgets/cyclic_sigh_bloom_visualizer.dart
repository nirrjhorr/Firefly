import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/breathing_session_state.dart';
import 'cyclic_sigh_bloom_painter.dart';

/// Widget embedding [CyclicSighBloomPainter] with responsive layout,
/// idle ambient resting pulse, and active respiration pacing.
class CyclicSighBloomVisualizer extends StatefulWidget {
  final double progress;
  final BreathingPhase phase;
  final bool isActive;
  final double size;
  final Widget? child;
  final bool? overrideReducedMotion;
  final Color? inhaleColor;
  final Color? exhaleColor;

  const CyclicSighBloomVisualizer({
    super.key,
    required this.progress,
    required this.phase,
    this.isActive = false,
    this.size = 260.0,
    this.child,
    this.overrideReducedMotion,
    this.inhaleColor,
    this.exhaleColor,
  });

  @override
  State<CyclicSighBloomVisualizer> createState() => _CyclicSighBloomVisualizerState();
}

class _CyclicSighBloomVisualizerState extends State<CyclicSighBloomVisualizer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ambientController;

  @override
  void initState() {
    super.initState();
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    if (!widget.isActive) {
      _ambientController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant CyclicSighBloomVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _ambientController.stop();
      } else {
        _ambientController.repeat();
      }
    }
  }

  @override
  void dispose() {
    _ambientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isReducedMotion = widget.overrideReducedMotion ??
        MediaQuery.maybeOf(context)?.disableAnimations ??
        false;

    return AnimatedBuilder(
      animation: _ambientController,
      builder: (context, _) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: CyclicSighBloomPainter(
              progress: widget.progress,
              phase: widget.phase,
              isActive: widget.isActive,
              ambientPulse: _ambientController.value,
              reducedMotion: isReducedMotion,
              inhaleColor: widget.inhaleColor ?? colors.actionSage,
              exhaleColor: widget.exhaleColor ?? colors.accentSecondary,
            ),
            child: widget.child != null ? Center(child: widget.child) : null,
          ),
        );
      },
    );
  }
}
