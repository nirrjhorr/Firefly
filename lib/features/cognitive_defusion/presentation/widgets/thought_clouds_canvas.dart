import 'dart:math';
import 'package:flutter/material.dart';

import '../../domain/models/defusion_thought.dart';

/// Canvas rendering twilight sky and organic drifting clouds bearing thoughts,
/// allowing user to tap to dissolve thoughts into mist.
class ThoughtCloudsCanvas extends StatefulWidget {
  const ThoughtCloudsCanvas({
    required this.thoughts,
    required this.onTapCloud,
    super.key,
  });

  final List<DefusionThought> thoughts;
  final void Function(DefusionThought thought)? onTapCloud;

  @override
  State<ThoughtCloudsCanvas> createState() => _ThoughtCloudsCanvasState();
}

class _ThoughtCloudsCanvasState extends State<ThoughtCloudsCanvas>
    with SingleTickerProviderStateMixin {
  late final AnimationController _driftController;

  @override
  void initState() {
    super.initState();
    _driftController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _driftController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _driftController,
      builder: (context, child) {
        return GestureDetector(
          onTapUp: (details) {
            _handleCanvasTap(details.localPosition, context.size ?? Size.zero);
          },
          child: CustomPaint(
            size: Size.infinite,
            painter: _ThoughtCloudsPainter(
              thoughts: widget.thoughts,
              driftPhase: _driftController.value * 2 * pi,
            ),
          ),
        );
      },
    );
  }

  void _handleCanvasTap(Offset tapPos, Size size) {
    if (widget.onTapCloud == null || size.isEmpty) return;

    for (final thought in widget.thoughts) {
      if (thought.isDissolved) continue;

      final y = size.height * (0.2 + (thought.lane * 0.25));
      final x = ((thought.driftProgress + thought.horizontalOffset) % 1.2) * size.width;
      final cloudCenter = Offset(x, y);

      if ((tapPos - cloudCenter).distance < 60) {
        widget.onTapCloud!(thought);
        break;
      }
    }
  }
}

class _ThoughtCloudsPainter extends CustomPainter {
  _ThoughtCloudsPainter({
    required this.thoughts,
    required this.driftPhase,
  });

  final List<DefusionThought> thoughts;
  final double driftPhase;

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Twilight Night Sky Background
    final rect = Offset.zero & size;
    final bgGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: const [
        Color(0xFF090D12),
        Color(0xFF111822),
        Color(0xFF0D1219),
      ],
    );
    final bgPaint = Paint()..shader = bgGradient.createShader(rect);
    canvas.drawRect(rect, bgPaint);

    // 2. Draw Gentle Ambient Stars
    final starPaint = Paint()..color = Colors.white.withOpacity(0.3);
    for (int i = 0; i < 24; i++) {
      final sx = ((i * 37) % size.width);
      final sy = ((i * 53) % size.height);
      final twinkle = (sin(driftPhase + i) * 0.3 + 0.7).clamp(0.2, 1.0);
      canvas.drawCircle(Offset(sx, sy), 1.2, starPaint..color = Colors.white.withOpacity(twinkle * 0.35));
    }

    // 3. Draw Drifting Clouds
    for (final thought in thoughts) {
      if (thought.isDissolved) continue;

      final y = size.height * (0.2 + (thought.lane * 0.25));
      final x = ((thought.driftProgress + thought.horizontalOffset) % 1.2) * size.width;
      final opacity = (1.0 - (thought.driftProgress * 0.3)).clamp(0.0, 1.0);

      _drawCloud(canvas, Offset(x, y), thought, opacity);
    }
  }

  void _drawCloud(Canvas canvas, Offset center, DefusionThought thought, double opacity) {
    canvas.save();
    canvas.translate(center.dx, center.dy);

    // Soft organic cloud puff shapes
    final cloudPaint = Paint()
      ..color = const Color(0xFF2C394B).withOpacity(opacity * 0.7)
      ..style = PaintingStyle.fill;

    final cloudHighlightPaint = Paint()
      ..color = const Color(0xFF435B76).withOpacity(opacity * 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final path = Path();
    path.addOval(Rect.fromCenter(center: const Offset(-24, 6), width: 50, height: 36));
    path.addOval(Rect.fromCenter(center: const Offset(24, 6), width: 54, height: 38));
    path.addOval(Rect.fromCenter(center: const Offset(0, -6), width: 64, height: 44));
    path.addOval(Rect.fromCenter(center: const Offset(0, 10), width: 80, height: 34));

    canvas.drawPath(path, cloudPaint);
    canvas.drawPath(path, cloudHighlightPaint);

    // Thought text inside cloud
    final textSpan = TextSpan(
      text: thought.text.length > 32
          ? '${thought.text.substring(0, 30)}...'
          : thought.text,
      style: TextStyle(
        color: const Color(0xFFE2E8F0).withOpacity(opacity),
        fontSize: 12,
        fontWeight: FontWeight.w500,
        fontFamily: 'Atkinson Hyperlegible',
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      maxLines: 2,
      textAlign: TextAlign.center,
    )..layout(maxWidth: 130);

    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ThoughtCloudsPainter oldDelegate) {
    return oldDelegate.driftPhase != driftPhase ||
        oldDelegate.thoughts != thoughts;
  }
}
