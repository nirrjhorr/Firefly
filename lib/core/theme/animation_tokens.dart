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
}
