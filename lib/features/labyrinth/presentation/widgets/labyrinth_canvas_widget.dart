import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/labyrinth_coord.dart';
import '../../domain/models/labyrinth_pattern_type.dart';
import '../../domain/models/labyrinth_session_state.dart';

/// Interactive canvas rendering the geometric guide labyrinth and the user's luminous touch trail (Story 12.3).
class LabyrinthCanvasWidget extends StatelessWidget {
  const LabyrinthCanvasWidget({
    super.key,
    required this.state,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
  });

  final LabyrinthSessionState state;
  final ValueChanged<Offset> onPanStart;
  final void Function(Offset, List<LabyrinthCoord>) onPanUpdate;
  final VoidCallback onPanEnd;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final guidePoints = state.pattern.generatePathPoints(width, height);

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: (details) => onPanStart(details.localPosition),
          onPanUpdate: (details) =>
              onPanUpdate(details.localPosition, guidePoints),
          onPanEnd: (_) => onPanEnd(),
          onPanCancel: onPanEnd,
          child: CustomPaint(
            size: Size(width, height),
            painter: _LabyrinthPainter(
              pattern: state.pattern,
              guidePoints: guidePoints,
              tracedPoints: state.tracedPoints,
              showGuidePath: state.showGuidePath,
              isCompleted: state.isCompleted,
              isTracingActive: state.isTracingActive,
              themeColors: colors,
            ),
          ),
        );
      },
    );
  }
}

class _LabyrinthPainter extends CustomPainter {
  const _LabyrinthPainter({
    required this.pattern,
    required this.guidePoints,
    required this.tracedPoints,
    required this.showGuidePath,
    required this.isCompleted,
    required this.isTracingActive,
    required this.themeColors,
  });

  final LabyrinthPatternType pattern;
  final List<LabyrinthCoord> guidePoints;
  final List<LabyrinthCoord> tracedPoints;
  final bool showGuidePath;
  final bool isCompleted;
  final bool isTracingActive;
  final ThemeColors themeColors;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // 1. Draw central calm resting pool
    final centerRadius = 24.0;
    final centerGlow = Paint()
      ..color = isCompleted
          ? themeColors.primary.withOpacity(0.35)
          : themeColors.primary.withOpacity(0.12)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, centerRadius * (isCompleted ? 1.4 : 1.0), centerGlow);

    final centerBorder = Paint()
      ..color = themeColors.primary.withOpacity(0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, centerRadius, centerBorder);

    // 2. Draw background guide track
    if (showGuidePath && guidePoints.isNotEmpty) {
      final guidePath = Path()..moveTo(guidePoints.first.x, guidePoints.first.y);
      for (int i = 1; i < guidePoints.length; i++) {
        guidePath.lineTo(guidePoints[i].x, guidePoints[i].y);
      }

      // Outer soft track glow
      final trackBackground = Paint()
        ..color = themeColors.outline.withOpacity(0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(guidePath, trackBackground);

      // Inner thin guideline
      final trackCore = Paint()
        ..color = themeColors.outline.withOpacity(0.40)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(guidePath, trackCore);

      // Entry dot
      final entryPaint = Paint()
        ..color = themeColors.primary.withOpacity(0.65)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(guidePoints.first.x, guidePoints.first.y), 6.0, entryPaint);
    }

    // 3. Draw user's traced finger trail with fading gradient
    if (tracedPoints.length >= 2) {
      final trailPath = Path()..moveTo(tracedPoints.first.x, tracedPoints.first.y);
      for (int i = 1; i < tracedPoints.length; i++) {
        trailPath.lineTo(tracedPoints[i].x, tracedPoints[i].y);
      }

      // Outer luminous glow
      final outerGlow = Paint()
        ..color = const Color(0xFFF4A261).withOpacity(0.30) // warm hearth gold glow
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(trailPath, outerGlow);

      // Inner luminous stroke
      final innerGlow = Paint()
        ..color = const Color(0xFFFFE3B3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(trailPath, innerGlow);

      // Fingertip cursor point
      final tip = Offset(tracedPoints.last.x, tracedPoints.last.y);
      final cursorGlow = Paint()
        ..color = const Color(0xFFFFD166).withOpacity(0.50)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(tip, 14.0, cursorGlow);

      final cursorCore = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(tip, 5.0, cursorCore);
    }
  }

  @override
  bool shouldRepaint(covariant _LabyrinthPainter oldDelegate) {
    return oldDelegate.tracedPoints.length != tracedPoints.length ||
        oldDelegate.showGuidePath != showGuidePath ||
        oldDelegate.isCompleted != isCompleted ||
        oldDelegate.pattern != pattern ||
        oldDelegate.isTracingActive != isTracingActive;
  }
}
