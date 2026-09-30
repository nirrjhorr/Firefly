import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/routing/app_routes.dart';

/// Persistent 1-tap Safety Plan emergency overlay trigger.
/// Single-tap: Navigates immediately to Stanley-Brown Safety Plan.
/// Long-press (>= 600ms): Triggers rapid panic blank exit and state purge.
class SosOverlayButton extends StatefulWidget {
  const SosOverlayButton({super.key});

  @override
  State<SosOverlayButton> createState() => _SosOverlayButtonState();
}

class _SosOverlayButtonState extends State<SosOverlayButton> {
  Timer? _longPressTimer;
  Timer? _hapticWarningTimer;

  void _onTapDown(TapDownDetails _) {
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
    _cancelTimers();
  }

  void _onTapCancel() {
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Emergency Safety Plan',
      hint:
          'Tap for offline safety plan. Long press 600 milliseconds to trigger rapid panic app lock and blank screen.',
      button: true,
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          onTap: () {
            HapticFeedback.selectionClick();
            context.push(AppRoutes.safetyPlan);
          },
          child: Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .errorContainer
                  .withOpacity(0.20),
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.error.withOpacity(0.45),
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.shield_outlined,
              size: 24,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ),
      ),
    );
  }
}
