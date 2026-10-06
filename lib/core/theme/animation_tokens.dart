import 'package:flutter/material.dart';

/// Motion token catalog adhering to trauma-informed pacing and accessibility.
abstract final class MotionTokens {
  /// Resolves the animation duration against the system's reduced motion setting.
  /// If animations are disabled, returns Duration.zero.
  static Duration resolve(Duration full, BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    return reduceMotion ? Duration.zero : full;
  }

  static const instant = Duration.zero;
  static const micro = Duration(milliseconds: 80);
  static const quick = Duration(milliseconds: 150);
  static const standard = Duration(milliseconds: 300);
  static const deliberate = Duration(milliseconds: 500);
  static const breathShort = Duration(milliseconds: 800);
  static const breathInhale = Duration(milliseconds: 4000);
  static const breathExhale = Duration(milliseconds: 8000);
  static const ambientLoop = Duration(milliseconds: 12000);

  static const normal = standard;
  static const fast = quick;
  static const screenTransition = deliberate;

  // ── Canonical Easing Curves (Apple HIG & Fluid Springs) ─────────────────────
  /// Fluid Apple deceleration curve for entering surfaces and modal presentations
  static const Curve enterCurve = Cubic(0.16, 1.0, 0.3, 1.0);
  static const Curve emphasizedCurve = enterCurve;

  /// Swift, responsive exit curve for dismissed sheets and canceled states
  static const Curve exitCurve = Cubic(0.4, 0.0, 1.0, 1.0);

  /// Apple standard interactive easing curve
  static const Curve standardEasing = Cubic(0.2, 0.0, 0.0, 1.0);
  static const Curve standardCurve = standardEasing;

  /// Direct manipulation button press scale (Emil Kowalski / Apple HIG)
  static const double buttonPressScale = 0.97;

  /// Subtle card press scale
  static const double cardPressScale = 0.985;

  /// Tactile tile press scale
  static const double tilePressScale = 0.95;
}

/// Compatibility alias class for animations
abstract final class AnimationTokens {
  static const instant = MotionTokens.instant;
  static const micro = MotionTokens.micro;
  static const fast = MotionTokens.quick;
  static const quick = MotionTokens.quick;
  static const medium = MotionTokens.standard;
  static const normal = MotionTokens.standard;
  static const standard = MotionTokens.standard;
  static const slow = MotionTokens.deliberate;
  static const deliberate = MotionTokens.deliberate;
  static const breathShort = MotionTokens.breathShort;
  static const breathInhale = MotionTokens.breathInhale;
  static const breathExhale = MotionTokens.breathExhale;
  static const ambientLoop = MotionTokens.ambientLoop;
  static const standardCurve = MotionTokens.standardEasing;
  static const emphasizedCurve = MotionTokens.enterCurve;
}


