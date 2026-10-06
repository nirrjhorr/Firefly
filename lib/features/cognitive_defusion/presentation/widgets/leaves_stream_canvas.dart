import 'dart:math';
import 'package:flutter/material.dart';

import '../../domain/models/defusion_thought.dart';

/// Interactive woodland stream canvas rendering gentle flowing water ripples
/// and floating autumn leaves carrying user thoughts smoothly downstream.
class LeavesStreamCanvas extends StatefulWidget {
  const LeavesStreamCanvas({
    required this.thoughts,
    required this.onTapLeaf,
    super.key,
  });

  final List<DefusionThought> thoughts;
  final void Function(DefusionThought thought)? onTapLeaf;

  @override
  State<LeavesStreamCanvas> createState() => _LeavesStreamCanvasState();
}

class _LeavesStreamCanvasState extends State<LeavesStreamCanvas>
    with SingleTickerProviderStateMixin {
  late final AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: _LeavesStreamPainter(
            thoughts: widget.thoughts,
            wavePhase: _waveController.value * 2 * pi,
          ),
        );
      },
    );
  }
}

class _LeavesStreamPainter extends CustomPainter {
  _LeavesStreamPainter({
    required this.thoughts,
    required this.wavePhase,
  });

  final List<DefusionThought> thoughts;
  final double wavePhase;

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Stream Deep Background
    final rect = Offset.zero & size;
    final bgGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: const [
        Color(0xFF0F1816), // Dark evergreen water
        Color(0xFF13221E),
        Color(0xFF0D1714),
      ],
    );
    final bgPaint = Paint()..shader = bgGradient.createShader(rect);
    canvas.drawRect(rect, bgPaint);

    // 2. Draw Subtle Water Flow Currents / Ripples
    final ripplePaint = Paint()
      ..color = const Color(0xFF233B33).withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (int i = 0; i < 6; i++) {
      final path = Path();
      final yOffset = size.height * (i / 6.0);
      final currentPhase = wavePhase + (i * 0.8);

      path.moveTo(0, yOffset);
      for (double x = 0; x <= size.width; x += 30) {
        final waveY = yOffset + sin((x / 60) + currentPhase) * 6;
        path.lineTo(x, waveY);
      }
      canvas.drawPath(path, ripplePaint);
    }

    // 3. Draw Floating Leaves
    for (final thought in thoughts) {
      if (thought.isDissolved) continue;

      // Compute leaf position based on driftProgress (0.0 -> 1.0)
      final y = thought.driftProgress * (size.height + 60) - 40;
      final xBase = size.width * (0.25 + (thought.lane * 0.25));
      final wobbleX = sin(thought.driftProgress * 4 * pi + wavePhase) * 16;
      final x = xBase + (thought.horizontalOffset * size.width * 0.2) + wobbleX;

      final opacity = (1.0 - (thought.driftProgress * 0.4)).clamp(0.0, 1.0);
      _drawLeaf(canvas, Offset(x, y), thought, opacity);
    }
  }

  void _drawLeaf(Canvas canvas, Offset center, DefusionThought thought, double opacity) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(thought.tiltAngle + sin(thought.driftProgress * 2 * pi) * 0.1);

    // Autumn Leaf Palette: Warm Russet & Amber-Sage
    final leafPaint = Paint()
      ..color = const Color(0xFF7A4A28).withOpacity(opacity * 0.9)
      ..style = PaintingStyle.fill;

    final leafBorderPaint = Paint()
      ..color = const Color(0xFFA66B38).withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Organic Leaf Shape
    final path = Path();
    path.moveTo(0, -32);
    path.cubicTo(26, -18, 30, 18, 0, 32);
    path.cubicTo(-30, 18, -26, -18, 0, -32);
    path.close();

    canvas.drawPath(path, leafPaint);
    canvas.drawPath(path, leafBorderPaint);

    // Leaf center vein
    final veinPaint = Paint()
      ..color = const Color(0xFFB57D4A).withOpacity(opacity * 0.7)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(0, -28), const Offset(0, 28), veinPaint);

    // Thought snippet pill / text
    final textSpan = TextSpan(
      text: thought.text.length > 28
          ? '${thought.text.substring(0, 26)}...'
          : thought.text,
      style: TextStyle(
        color: const Color(0xFFF0EBE1).withOpacity(opacity),
        fontSize: 11,
        fontWeight: FontWeight.w500,
        fontFamily: 'Atkinson Hyperlegible',
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      maxLines: 2,
      textAlign: TextAlign.center,
    )..layout(maxWidth: 140);

    // Draw peaceful card behind text for readability
    final bgPillRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: const Offset(0, 48),
        width: textPainter.width + 16,
        height: textPainter.height + 8,
      ),
      const Radius.circular(10),
    );

    final pillBgPaint = Paint()
      ..color = const Color(0xFF1B2621).withOpacity(opacity * 0.85);
    final pillBorderPaint = Paint()
      ..color = const Color(0xFF384F45).withOpacity(opacity * 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawRRect(bgPillRect, pillBgPaint);
    canvas.drawRRect(bgPillRect, pillBorderPaint);

    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, 48 - (textPainter.height / 2)),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LeavesStreamPainter oldDelegate) {
    return oldDelegate.wavePhase != wavePhase ||
        oldDelegate.thoughts != thoughts;
  }
}
