import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/routing/app_routes.dart';
import '../../core/theme/animation_tokens.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/icon_tokens.dart';
import '../../core/theme/spacing_tokens.dart';

/// Persistent 1-tap Safety Plan emergency overlay trigger.
/// Single-tap: Navigates immediately to Stanley-Brown Safety Plan.
/// Long-press (>= 600ms): Triggers rapid panic blank exit and state purge.
class SosOverlayButton extends StatefulWidget {
  const SosOverlayButton({super.key});

  @override
  State<SosOverlayButton> createState() => _SosOverlayButtonState();
}

class _SosOverlayButtonState extends State<SosOverlayButton>
    with SingleTickerProviderStateMixin {
  Timer? _longPressTimer;
  Timer? _hapticWarningTimer;
  late final AnimationController _pressController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: MotionTokens.micro,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeOut),
    );
  }

  void _onTapDown(TapDownDetails _) {
    _pressController.forward();
    // 400ms haptic warning
    _hapticWarningTimer = Timer(const Duration(milliseconds: 400), () {
      HapticFeedback.heavyImpact();
    });

    // 600ms panic trigger
    _longPressTimer = Timer(const Duration(milliseconds: 600), () {
      _executePanic();
    });
  }

  void _onTapUp(TapUpDetails _) {
    _pressController.reverse();
    _cancelTimers();
  }

  void _onTapCancel() {
    _pressController.reverse();
    _cancelTimers();
  }

  void _cancelTimers() {
    _hapticWarningTimer?.cancel();
    _longPressTimer?.cancel();
    _hapticWarningTimer = null;
    _longPressTimer = null;
  }

  void _executePanic() {
    _cancelTimers();
    HapticFeedback.vibrate();
    context.go(AppRoutes.panicBlank);
  }

  @override
  void dispose() {
    _cancelTimers();
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      label: 'Emergency Safety Plan',
      hint:
          'Tap for offline safety plan. Long press 600 milliseconds to trigger rapid panic app lock and blank screen.',
      button: true,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          onTap: () {
            HapticFeedback.selectionClick();
            context.push(AppRoutes.safetyPlan);
          },
          child: Container(
            width: SpacingTokens.sosButtonSize,
            height: SpacingTokens.sosButtonSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.crisisCoralSurface,
              shape: BoxShape.circle,
              border: Border.all(
                color: colors.crisisCoral.withOpacity(0.50),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.20),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              AppIcons.emergencyShield,
              size: IconSizeTokens.standard,
              color: colors.crisisCoral,
            ),
          ),
        ),
      ),
    );
  }
}
