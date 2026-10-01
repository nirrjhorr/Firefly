import 'package:flutter/services.dart';
import '../../../../core/contracts/haptics_port.dart';

typedef HapticTrigger = Future<void> Function();

/// Concrete implementation of [HapticsPort] using Flutter's native [HapticFeedback].
class FlutterHapticsAdapter implements HapticsPort {
  final HapticTrigger _lightImpact;
  final HapticTrigger _selectionClick;

  FlutterHapticsAdapter({
    HapticTrigger? lightImpact,
    HapticTrigger? selectionClick,
  })  : _lightImpact = lightImpact ?? HapticFeedback.lightImpact,
        _selectionClick = selectionClick ?? HapticFeedback.selectionClick;

  @override
  Future<void> phaseTransitionInhale() async {
    try {
      await _lightImpact();
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await _lightImpact();
    } catch (_) {
      // Silent failure: haptics errors must never crash or interrupt respiration
    }
  }

  @override
  Future<void> phaseTransitionExhale() async {
    try {
      await _lightImpact();
    } catch (_) {
      // Silent failure
    }
  }

  @override
  Future<void> groundingConfirm() async {
    try {
      await _selectionClick();
    } catch (_) {
      // Silent failure
    }
  }
}
