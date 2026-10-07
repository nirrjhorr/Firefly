import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/routing/app_routes.dart';
import '../../core/theme/animation_tokens.dart';
import '../../core/theme/spacing_tokens.dart';

/// CustomPainter rendering a glowing, organic firefly vector glyph.
class FireflyIconPainter extends CustomPainter {
  const FireflyIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..isAntiAlias = true;

    // 1. Glowing Abdomen (lower luminous lantern)
    final abdomenCenter = Offset(center.dx, center.dy + 3.5);
    final glowPaint = Paint()
      ..color = const Color(0xFF4ADE80).withOpacity(0.55)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawCircle(abdomenCenter, 6.5, glowPaint);

    final abdomenPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFDCFCE7), Color(0xFF4ADE80), Color(0xFF16A34A)],
      ).createShader(Rect.fromCircle(center: abdomenCenter, radius: 5.5));
    canvas.drawOval(
      Rect.fromCenter(center: abdomenCenter, width: 9.0, height: 11.0),
      abdomenPaint,
    );

    // 2. Thorax & Head
    paint.color = const Color(0xFF052E16);
    paint.shader = null;
    canvas.drawCircle(Offset(center.dx, center.dy - 3.0), 3.2, paint);
    canvas.drawCircle(Offset(center.dx, center.dy - 7.0), 2.4, paint);

    // 3. Translucent Luminous Wings
    final wingPaint = Paint()
      ..color = const Color(0xFF86EFAC).withOpacity(0.55)
      ..style = PaintingStyle.fill;

    // Left wing
    final leftWingPath = Path()
      ..moveTo(center.dx - 1.0, center.dy - 4.0)
      ..cubicTo(
        center.dx - 9.0,
        center.dy - 9.0,
        center.dx - 11.0,
        center.dy + 1.0,
        center.dx - 2.0,
        center.dy + 3.0,
      )
      ..close();
    canvas.drawPath(leftWingPath, wingPaint);

    // Right wing
    final rightWingPath = Path()
      ..moveTo(center.dx + 1.0, center.dy - 4.0)
      ..cubicTo(
        center.dx + 9.0,
        center.dy - 9.0,
        center.dx + 11.0,
        center.dy + 1.0,
        center.dx + 2.0,
        center.dy + 3.0,
      )
      ..close();
    canvas.drawPath(rightWingPath, wingPaint);

    // 4. Subtle Antennae
    final antennaPaint = Paint()
      ..color = const Color(0xFF4ADE80).withOpacity(0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    final leftAntenna = Path()
      ..moveTo(center.dx - 1.0, center.dy - 7.5)
      ..quadraticBezierTo(
        center.dx - 3.5,
        center.dy - 11.5,
        center.dx - 5.5,
        center.dy - 10.5,
      );
    canvas.drawPath(leftAntenna, antennaPaint);

    final rightAntenna = Path()
      ..moveTo(center.dx + 1.0, center.dy - 7.5)
      ..quadraticBezierTo(
        center.dx + 3.5,
        center.dy - 11.5,
        center.dx + 5.5,
        center.dy - 10.5,
      );
    canvas.drawPath(rightAntenna, antennaPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Draggable neon green floating action button with firefly icon for Stanley-Brown Safety Plan.
/// Supports free drag gesture, horizontal edge snapping, and safe crash-proof tap handling.
class SosOverlayButton extends StatefulWidget {
  const SosOverlayButton({super.key});

  @override
  State<SosOverlayButton> createState() => _SosOverlayButtonState();
}

class _SosOverlayButtonState extends State<SosOverlayButton>
    with TickerProviderStateMixin {
  late final AnimationController _pressController;
  late final Animation<double> _scaleAnimation;
  late final AnimationController _snapController;
  Animation<double>? _snapAnimation;

  double? _x;
  double? _y;
  bool _isDragging = false;
  Offset _dragStartGlobal = Offset.zero;

  static const double _buttonSize = SpacingTokens.sosButtonSize; // 56.0
  static const double _edgeInset = 16.0;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: MotionTokens.micro,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _pressController, curve: MotionTokens.enterCurve),
    );

    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_x == null || _y == null) {
      final size = MediaQuery.of(context).size;
      final padding = MediaQuery.of(context).padding;
      _x = size.width - _buttonSize - _edgeInset;
      _y = size.height - padding.bottom - SpacingTokens.navBarHeight - _buttonSize - 20.0;
    }
  }

  @override
  void dispose() {
    _pressController.dispose();
    _snapController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    _snapController.stop();
    _dragStartGlobal = details.globalPosition;
    _isDragging = false;
    _pressController.forward();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final movedDist = (details.globalPosition - _dragStartGlobal).distance;
    if (movedDist > 4.0) {
      _isDragging = true;
    }

    final media = MediaQuery.of(context);
    final size = media.size;
    final padding = media.padding;

    final minY = padding.top + 16.0;
    final maxY = size.height - padding.bottom - SpacingTokens.navBarHeight - _buttonSize - 12.0;

    setState(() {
      _x = ((_x ?? 0) + details.delta.dx).clamp(0.0, size.width - _buttonSize);
      _y = ((_y ?? 0) + details.delta.dy).clamp(minY, math.max(minY, maxY));
    });
  }

  void _onPanEnd(DragEndDetails details) {
    _pressController.reverse();

    final size = MediaQuery.of(context).size;
    final currentX = _x ?? (size.width - _buttonSize - _edgeInset);
    final targetX = (currentX + _buttonSize / 2 < size.width / 2)
        ? _edgeInset
        : (size.width - _buttonSize - _edgeInset);

    _snapAnimation = Tween<double>(begin: currentX, end: targetX).animate(
      CurvedAnimation(parent: _snapController, curve: Curves.easeOutCubic),
    )..addListener(() {
        setState(() {
          _x = _snapAnimation!.value;
        });
      });

    _snapController.forward(from: 0.0);
  }

  void _onPanCancel() {
    _pressController.reverse();
  }

  void _handleTap() {
    if (_isDragging) return;
    HapticFeedback.selectionClick();
    try {
      context.push(AppRoutes.safetyPlan);
    } catch (e) {
      debugPrint('Navigation to safety plan error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final posX = _x ?? (size.width - _buttonSize - _edgeInset);
    final posY = _y ?? (size.height - padding.bottom - SpacingTokens.navBarHeight - _buttonSize - 20.0);

    return Positioned(
      left: posX,
      top: posY,
      child: Semantics(
        label: 'Firefly Safety Plan',
        hint: 'Tap for Stanley-Brown Safety Plan. Drag to reposition.',
        button: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          onPanCancel: _onPanCancel,
          onTap: _handleTap,
          onLongPress: () {
            HapticFeedback.mediumImpact();
            _handleTap();
          },
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: _buttonSize,
              height: _buttonSize,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF0F291E), // Deep neon-tinted sanctuary canvas
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF22C55E), // Neon emerald glow
                  width: 1.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF22C55E).withOpacity(0.35),
                    blurRadius: 14,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.40),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const SizedBox(
                width: 28,
                height: 28,
                child: CustomPaint(
                  painter: FireflyIconPainter(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
