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

  static const headingSm = TextStyle(
    fontFamily: 'AtkinsonHyperlegible',
    fontSize: 16,
    height: 1.35,
    letterSpacing: 0,
    fontWeight: FontWeight.w700,
  );

  static const labelSm = TextStyle(
    fontFamily: 'AtkinsonHyperlegible',
    fontSize: 12,
    height: 1.4,
    letterSpacing: 0.36,
    fontWeight: FontWeight.w700,
  );

  // ── Compatibility Aliases ────────────────────────────────────────────────────
  static const headlineSm = headingMd;
  static const headlineLg = headingLg;
  static const headlineMedium = headingMd;
  static const headlineSmall = headingSm;
  static const headingSmall = headingSm;
  static const displaySm = displayMd;
  static const displayLarge = displayLg;
  static const titleLarge = headingLg;
  static const titleMedium = headingMd;
  static const titleSmall = headingSm;
  static const bodyLarge = bodyLg;
  static const bodyMedium = bodyMd;
  static const bodySmall = bodySm;
  static const labelLarge = labelLg;
  static const labelMedium = labelMd;
  static const labelSmall = labelSm;
  static const labelXs = labelSm;
  static const captionSm = caption;
  static const monoMedium = monoSm;
  static const button = labelLg;

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

/// Instance token dictionary for accessing typography tokens via context
class AppTypographyTokens {
  const AppTypographyTokens();

  TextStyle get displayXl => AppTypography.displayXl;
  TextStyle get displayLg => AppTypography.displayLg;
  TextStyle get displayLarge => AppTypography.displayLg;
  TextStyle get displayMd => AppTypography.displayMd;
  TextStyle get displayMedium => AppTypography.displayMd;
  TextStyle get headingLg => AppTypography.headingLg;
  TextStyle get headingMd => AppTypography.headingMd;
  TextStyle get headlineMedium => AppTypography.headingMd;
  TextStyle get headingSm => AppTypography.headingSm;
  TextStyle get headlineSmall => AppTypography.headingSm;
  TextStyle get titleLarge => AppTypography.headingLg;
  TextStyle get titleMedium => AppTypography.headingMd;
  TextStyle get titleSmall => AppTypography.headingSm;
  TextStyle get bodyLg => AppTypography.bodyLg;
  TextStyle get bodyLarge => AppTypography.bodyLg;
  TextStyle get bodyMd => AppTypography.bodyMd;
  TextStyle get bodyMedium => AppTypography.bodyMd;
  TextStyle get bodySm => AppTypography.bodySm;
  TextStyle get bodySmall => AppTypography.bodySm;
  TextStyle get labelLg => AppTypography.labelLg;
  TextStyle get labelLarge => AppTypography.labelLg;
  TextStyle get labelMd => AppTypography.labelMd;
  TextStyle get labelMedium => AppTypography.labelMd;
  TextStyle get labelSm => AppTypography.labelSm;
  TextStyle get labelSmall => AppTypography.labelSm;
}

/// Convenience typography accessors on BuildContext
extension BuildContextTypographyX on BuildContext {
  AppTypographyTokens get typography => const AppTypographyTokens();
  TextStyle get displayMedium => AppTypography.displayMd;
  TextStyle get headlineSmall => AppTypography.headingSm;
  TextStyle get titleMedium => AppTypography.headingMd;
  TextStyle get titleSmall => AppTypography.headingSm;
  TextStyle get bodyLarge => AppTypography.bodyLg;
  TextStyle get bodyMedium => AppTypography.bodyMd;
  TextStyle get bodySmall => AppTypography.bodySm;
  TextStyle get labelLarge => AppTypography.labelLg;
  TextStyle get labelMedium => AppTypography.labelMd;
  TextStyle get labelSmall => AppTypography.labelSm;
}

