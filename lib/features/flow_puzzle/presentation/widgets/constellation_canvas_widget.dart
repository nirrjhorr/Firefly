import 'dart:math';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/radius_tokens.dart';
import '../../domain/models/constellation_pattern.dart';

/// Interactive custom canvas widget rendering gentle constellation star patterns.
class ConstellationCanvasWidget extends StatefulWidget {
  const ConstellationCanvasWidget({
    super.key,
    required this.pattern,
    required this.connectedNodeIndices,
    required this.nextExpectedNodeId,
    required this.isCompleted,
    required this.onNodeTapped,
  });

  final ConstellationPattern pattern;
  final List<int> connectedNodeIndices;
  final int nextExpectedNodeId;
  final bool isCompleted;
  final ValueChanged<int> onNodeTapped;

  @override
  State<ConstellationCanvasWidget> createState() => _ConstellationCanvasWidgetState();
}

class _ConstellationCanvasWidgetState extends State<ConstellationCanvasWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  int? _findNodeAtOffset(Offset localPos, Size size) {
    const hitRadius = 38.0; // Generous touch target
    for (int i = 0; i < widget.pattern.nodes.length; i++) {
      final node = widget.pattern.nodes[i];
      final nodePos = Offset(node.x * size.width, node.y * size.height);
      if ((localPos - nodePos).distance <= hitRadius) {
        return i;
      }
    }
    return null;
  }

  void _handlePointerEvent(Offset localPos, Size size) {
    final hitIndex = _findNodeAtOffset(localPos, size);
    if (hitIndex != null) {
      widget.onNodeTapped(hitIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final canvasSize = Size(constraints.maxWidth, constraints.maxHeight);

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) => _handlePointerEvent(details.localPosition, canvasSize),
          onPanUpdate: (details) => _handlePointerEvent(details.localPosition, canvasSize),
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, _) {
              return CustomPaint(
                size: canvasSize,
                painter: _ConstellationPainter(
                  pattern: widget.pattern,
                  connectedNodeIndices: widget.connectedNodeIndices,
                  nextExpectedNodeId: widget.nextExpectedNodeId,
                  isCompleted: widget.isCompleted,
                  pulseFactor: _pulseController.value,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _ConstellationPainter extends CustomPainter {
  _ConstellationPainter({
    required this.pattern,
    required this.connectedNodeIndices,
    required this.nextExpectedNodeId,
    required this.isCompleted,
    required this.pulseFactor,
  });

  final ConstellationPattern pattern;
  final List<int> connectedNodeIndices;
  final int nextExpectedNodeId;
  final bool isCompleted;
  final double pulseFactor;

  // Curated distant background stars for astronomical depth
  static final List<Offset> _ambientStars = [
    const Offset(0.12, 0.15),
    const Offset(0.85, 0.18),
    const Offset(0.08, 0.42),
    const Offset(0.92, 0.48),
    const Offset(0.15, 0.85),
    const Offset(0.82, 0.82),
    const Offset(0.48, 0.10),
    const Offset(0.55, 0.92),
    const Offset(0.35, 0.18),
    const Offset(0.68, 0.78),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw serene deep night sky background
    final bgPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.9,
        colors: [
          const Color(0xFF161C22),
          const Color(0xFF0F1316),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(RadiusTokens.lg),
    );
    canvas.drawRRect(rrect, bgPaint);

    // 2. Draw subtle background ambient stars
    final ambientPaint = Paint()
      ..color = Colors.white.withOpacity(0.18)
      ..style = PaintingStyle.fill;
    for (final star in _ambientStars) {
      canvas.drawCircle(Offset(star.dx * size.width, star.dy * size.height), 1.2, ambientPaint);
    }

    // 3. Draw connected line paths
    if (connectedNodeIndices.length > 1) {
      // Glow under-path
      final glowPaint = Paint()
        ..color = const Color(0xFFE8B86D).withOpacity(0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.0
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

      // Core luminous line
      final linePaint = Paint()
        ..color = isCompleted ? const Color(0xFF82A796) : const Color(0xFFE8B86D)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round;

      final path = Path();
      final firstNode = pattern.nodes[connectedNodeIndices.first];
      path.moveTo(firstNode.x * size.width, firstNode.y * size.height);

      for (int i = 1; i < connectedNodeIndices.length; i++) {
        final node = pattern.nodes[connectedNodeIndices[i]];
        path.lineTo(node.x * size.width, node.y * size.height);
      }

      canvas.drawPath(path, glowPaint);
      canvas.drawPath(path, linePaint);
    }

    // 4. Draw individual nodes / stars
    final visitedSet = connectedNodeIndices.toSet();

    for (int i = 0; i < pattern.nodes.length; i++) {
      final node = pattern.nodes[i];
      final center = Offset(node.x * size.width, node.y * size.height);
      final isVisited = visitedSet.contains(i);
      final isNext = node.id == nextExpectedNodeId && !isCompleted;

      if (isVisited) {
        // Star has been visited & anchored
        final auraColor = isCompleted
            ? const Color(0xFF82A796).withOpacity(0.4)
            : const Color(0xFFE8B86D).withOpacity(0.35);
        canvas.drawCircle(center, 12.0, Paint()..color = auraColor);
        canvas.drawCircle(center, 5.0, Paint()..color = const Color(0xFFFBFBFB));
      } else if (isNext) {
        // Next expected star: pulsing inviting halo
        final pulseRadius = 14.0 + (pulseFactor * 8.0);
        final haloPaint = Paint()
          ..color = const Color(0xFF82A796).withOpacity(0.25 + (pulseFactor * 0.20))
          ..style = PaintingStyle.fill;
        canvas.drawCircle(center, pulseRadius, haloPaint);

        final corePaint = Paint()
          ..color = const Color(0xFF82A796)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(center, 6.0, corePaint);
      } else {
        // Quiet unvisited star
        final dimPaint = Paint()
          ..color = const Color(0xFF5A6672)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(center, 4.0, dimPaint);
      }

      // Draw label number with high contrast
      final textSpan = TextSpan(
        text: node.label,
        style: TextStyle(
          color: isVisited
              ? const Color(0xFFE8B86D)
              : isNext
                  ? const Color(0xFF82A796)
                  : const Color(0xFF8A98A5),
          fontSize: 12.0,
          fontWeight: isNext || isVisited ? FontWeight.bold : FontWeight.normal,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      // Position label slightly below the star node
      final textOffset = Offset(
        center.dx - (textPainter.width / 2),
        center.dy + 12.0,
      );
      textPainter.paint(canvas, textOffset);
    }
  }

  @override
  bool shouldRepaint(covariant _ConstellationPainter oldDelegate) {
    return oldDelegate.pattern != pattern ||
        oldDelegate.connectedNodeIndices.length != connectedNodeIndices.length ||
        oldDelegate.nextExpectedNodeId != nextExpectedNodeId ||
        oldDelegate.isCompleted != isCompleted ||
        oldDelegate.pulseFactor != pulseFactor;
  }
}
