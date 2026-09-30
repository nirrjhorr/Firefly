import 'package:flutter/material.dart';

abstract final class AppTypography {
  // ── Display ─────────────────────────────────────────────────────────────────
  static const displayXl = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 48,
    height: 1.1,
    letterSpacing: -0.96, // -0.02em * 48
    fontWeight: FontWeight.w700,
  );

  static const displayLg = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 36,
    height: 1.15,
    letterSpacing: -0.36, // -0.01em * 36
    fontWeight: FontWeight.w600,
  );

  static const displayMd = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 28,
    height: 1.2,
    letterSpacing: -0.14, // -0.005em * 28
    fontWeight: FontWeight.w500,
  );

  // ── Headings ─────────────────────────────────────────────────────────────────
  static const headingLg = TextStyle(
    fontFamily: 'AtkinsonHyperlegible',
    fontSize: 22,
    height: 1.3,
    letterSpacing: 0,
    fontWeight: FontWeight.w700,
  );

  static const headingMd = TextStyle(
    fontFamily: 'AtkinsonHyperlegible',
    fontSize: 18,
    height: 1.35,
    letterSpacing: 0,
    fontWeight: FontWeight.w700,
  );

  // ── Body ─────────────────────────────────────────────────────────────────────
  static const bodyLg = TextStyle(
    fontFamily: 'AtkinsonHyperlegible',
    fontSize: 17,
    height: 1.55,
    letterSpacing: 0.17, // 0.01em * 17
    fontWeight: FontWeight.w400,
  );

  static const bodyMd = TextStyle(
    fontFamily: 'AtkinsonHyperlegible',
    fontSize: 15,
    height: 1.55,
    letterSpacing: 0.15,
    fontWeight: FontWeight.w400,
  );

  static const bodySm = TextStyle(
    fontFamily: 'AtkinsonHyperlegible',
    fontSize: 13,
    height: 1.5,
    letterSpacing: 0.195,
    fontWeight: FontWeight.w400,
  );

  // ── Labels ───────────────────────────────────────────────────────────────────
  static const labelLg = TextStyle(
    fontFamily: 'AtkinsonHyperlegible',
    fontSize: 16,
    height: 1.4,
    letterSpacing: 0.32, // 0.02em * 16
    fontWeight: FontWeight.w700,
  );

  static const labelMd = TextStyle(
    fontFamily: 'AtkinsonHyperlegible',
    fontSize: 14,
    height: 1.4,
    letterSpacing: 0.42, // 0.03em * 14
    fontWeight: FontWeight.w700,
  );

  static const caption = TextStyle(
    fontFamily: 'AtkinsonHyperlegible',
    fontSize: 12,
    height: 1.5,
    letterSpacing: 0.48, // 0.04em * 12
    fontWeight: FontWeight.w400,
  );

  static const monoSm = TextStyle(
    fontFamily: 'JetBrainsMono',
    fontSize: 12,
    height: 1.4,
    letterSpacing: 0,
    fontWeight: FontWeight.w400,
  );

  /// Maps AppTypography to Flutter's Material TextTheme
  static TextTheme toTextTheme(Color defaultColor) => TextTheme(
        displayLarge: displayXl.copyWith(color: defaultColor),
        displayMedium: displayLg.copyWith(color: defaultColor),
        displaySmall: displayMd.copyWith(color: defaultColor),
        headlineLarge: headingLg.copyWith(color: defaultColor),
        headlineMedium: headingMd.copyWith(color: defaultColor),
        bodyLarge: bodyLg.copyWith(color: defaultColor),
        bodyMedium: bodyMd.copyWith(color: defaultColor),
        bodySmall: bodySm.copyWith(color: defaultColor),
        labelLarge: labelLg.copyWith(color: defaultColor),
        labelMedium: labelMd.copyWith(color: defaultColor),
        labelSmall: caption.copyWith(color: defaultColor),
      );
}

/// Dynamic type scale caps to prevent layout breaks on large accessibility scales
abstract final class TypographyScaleConstraints {
  static const double displayTextMaxScale = 1.4;
  static const double bodyTextMaxScale = 2.0;
}
