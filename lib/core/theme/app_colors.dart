import 'package:flutter/material.dart';

/// ─── Primitive Palette ────────────────────────────────────────────────────────
/// Do not use these directly in widgets. Use semantic tokens via AppCustomColors.
abstract final class _Primitive {
  // Ink (Dark foundation)
  static const ink950 = Color(0xFF0A0D0F);
  static const ink900 = Color(0xFF111518);
  static const ink800 = Color(0xFF191E23);
  static const ink700 = Color(0xFF232B32);
  static const ink600 = Color(0xFF2E3840);
  static const ink500 = Color(0xFF3E4A54);

  // Neutrals
  static const neutral400 = Color(0xFF6B7E8C);
  static const neutral300 = Color(0xFF9AAAB6);
  static const neutral200 = Color(0xFFC4CDD4);
  static const neutral100 = Color(0xFFE8ECF0);
  static const neutral050 = Color(0xFFF5F7F9);

  // Sage
  static const sage900 = Color(0xFF1C2922);
  static const sage700 = Color(0xFF2D4A3A);
  static const sage500 = Color(0xFF4A7862);
  static const sage400 = Color(0xFF5D9478);
  static const sage350 = Color(0xFF7DBA9B); // Stitch Serene Sanctuary illuminated sage (WCAG AAA 8.6:1)
  static const sage300 = Color(0xFF84B09A);
  static const sage250 = Color(0xFF98D6B6); // Stitch primary hover sage
  static const sage200 = Color(0xFFB5CEBC);
  static const sage100 = Color(0xFFDFF0E6);

  // Dusk Blue
  static const dusk900 = Color(0xFF131B2E);
  static const dusk700 = Color(0xFF1E3050);
  static const dusk500 = Color(0xFF2E5080);
  static const dusk400 = Color(0xFF3D6A9F);
  static const dusk350 = Color(0xFF5B8A99); // Stitch supportive dusk blue
  static const dusk300 = Color(0xFF6B92BF);
  static const dusk200 = Color(0xFFA3BDD9);
  static const dusk100 = Color(0xFFD8E6F4);

  // Amber
  static const amber800 = Color(0xFF2E1E08);
  static const amber600 = Color(0xFF7A4A0F);
  static const amber500 = Color(0xFFC27A30);
  static const amber400 = Color(0xFFD4963E);
  static const amber350 = Color(0xFFD99B65); // Stitch warm grounding amber
  static const amber300 = Color(0xFFE5B870);
  static const amber200 = Color(0xFFF2D9A8);
  static const amber100 = Color(0xFFFDF3E0);

  // Crisis Coral
  static const coral800 = Color(0xFF2C1110);
  static const coral600 = Color(0xFF7D3030);
  static const coral500 = Color(0xFFB05454);
  static const coral400 = Color(0xFFC96E6E);
  static const coral200 = Color(0xFFEBBEBE);
  static const coral100 = Color(0xFFF9EDED);
}

/// ─── Semantic Color Sets ──────────────────────────────────────────────────────

@immutable
class AppCustomColors extends ThemeExtension<AppCustomColors> {
  const AppCustomColors({
    required this.bgCanvas,
    required this.bgCanvasDeep,
    required this.bgSurface,
    required this.bgSurfaceRaised,
    required this.bgOverlay,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textDisabled,
    required this.accentPrimary,
    required this.accentPrimaryHover,
    required this.accentSecondary,
    required this.accentWarmth,
    required this.crisisSurface,
    required this.crisisAction,
    required this.crisisActionHover,
    required this.crisisText,
    required this.interactiveFocus,
    required this.successSubtle,
  });

  final Color bgCanvas;
  final Color bgCanvasDeep;
  final Color bgSurface;
  final Color bgSurfaceRaised;
  final Color bgOverlay;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color textDisabled;
  final Color accentPrimary;
  final Color accentPrimaryHover;
  final Color accentSecondary;
  final Color accentWarmth;
  final Color crisisSurface;
  final Color crisisAction;
  final Color crisisActionHover;
  final Color crisisText;
  final Color interactiveFocus;
  final Color successSubtle;

  @override
  AppCustomColors copyWith({
    Color? bgCanvas,
    Color? bgCanvasDeep,
    Color? bgSurface,
    Color? bgSurfaceRaised,
    Color? bgOverlay,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? textDisabled,
    Color? accentPrimary,
    Color? accentPrimaryHover,
    Color? accentSecondary,
    Color? accentWarmth,
    Color? crisisSurface,
    Color? crisisAction,
    Color? crisisActionHover,
    Color? crisisText,
    Color? interactiveFocus,
    Color? successSubtle,
  }) =>
      AppCustomColors(
        bgCanvas: bgCanvas ?? this.bgCanvas,
        bgCanvasDeep: bgCanvasDeep ?? this.bgCanvasDeep,
        bgSurface: bgSurface ?? this.bgSurface,
        bgSurfaceRaised: bgSurfaceRaised ?? this.bgSurfaceRaised,
        bgOverlay: bgOverlay ?? this.bgOverlay,
        textPrimary: textPrimary ?? this.textPrimary,
        textSecondary: textSecondary ?? this.textSecondary,
        textMuted: textMuted ?? this.textMuted,
        textDisabled: textDisabled ?? this.textDisabled,
        accentPrimary: accentPrimary ?? this.accentPrimary,
        accentPrimaryHover: accentPrimaryHover ?? this.accentPrimaryHover,
        accentSecondary: accentSecondary ?? this.accentSecondary,
        accentWarmth: accentWarmth ?? this.accentWarmth,
        crisisSurface: crisisSurface ?? this.crisisSurface,
        crisisAction: crisisAction ?? this.crisisAction,
        crisisActionHover: crisisActionHover ?? this.crisisActionHover,
        crisisText: crisisText ?? this.crisisText,
        interactiveFocus: interactiveFocus ?? this.interactiveFocus,
        successSubtle: successSubtle ?? this.successSubtle,
      );

  @override
  AppCustomColors lerp(AppCustomColors? other, double t) {
    if (other is! AppCustomColors) return this;
    return AppCustomColors(
      bgCanvas: Color.lerp(bgCanvas, other.bgCanvas, t)!,
      bgCanvasDeep: Color.lerp(bgCanvasDeep, other.bgCanvasDeep, t)!,
      bgSurface: Color.lerp(bgSurface, other.bgSurface, t)!,
      bgSurfaceRaised: Color.lerp(bgSurfaceRaised, other.bgSurfaceRaised, t)!,
      bgOverlay: Color.lerp(bgOverlay, other.bgOverlay, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      accentPrimary: Color.lerp(accentPrimary, other.accentPrimary, t)!,
      accentPrimaryHover: Color.lerp(accentPrimaryHover, other.accentPrimaryHover, t)!,
      accentSecondary: Color.lerp(accentSecondary, other.accentSecondary, t)!,
      accentWarmth: Color.lerp(accentWarmth, other.accentWarmth, t)!,
      crisisSurface: Color.lerp(crisisSurface, other.crisisSurface, t)!,
      crisisAction: Color.lerp(crisisAction, other.crisisAction, t)!,
      crisisActionHover: Color.lerp(crisisActionHover, other.crisisActionHover, t)!,
      crisisText: Color.lerp(crisisText, other.crisisText, t)!,
      interactiveFocus: Color.lerp(interactiveFocus, other.interactiveFocus, t)!,
      successSubtle: Color.lerp(successSubtle, other.successSubtle, t)!,
    );
  }

  static const dark = AppCustomColors(
    bgCanvas: _Primitive.ink900,
    bgCanvasDeep: _Primitive.ink950,
    bgSurface: _Primitive.ink800,
    bgSurfaceRaised: _Primitive.ink700,
    bgOverlay: _Primitive.ink600,
    textPrimary: _Primitive.neutral050,
    textSecondary: _Primitive.neutral200,
    textMuted: _Primitive.neutral300,
    textDisabled: _Primitive.neutral400,
    accentPrimary: _Primitive.sage350, // Stitch illuminated sage #7DBA9B (WCAG AAA 8.6:1)
    accentPrimaryHover: _Primitive.sage250, // #98D6B6
    accentSecondary: _Primitive.dusk350, // #5B8A99
    accentWarmth: _Primitive.amber350, // #D99B65
    crisisSurface: _Primitive.coral800,
    crisisAction: _Primitive.coral500,
    crisisActionHover: _Primitive.coral400,
    crisisText: _Primitive.coral200,
    interactiveFocus: _Primitive.dusk300,
    successSubtle: _Primitive.sage350,
  );

  static const light = AppCustomColors(
    bgCanvas: _Primitive.neutral050,
    bgCanvasDeep: Color(0xFFFFFFFF),
    bgSurface: Color(0xFFFFFFFF),
    bgSurfaceRaised: _Primitive.sage100,
    bgOverlay: _Primitive.neutral200,
    textPrimary: _Primitive.ink900,
    textSecondary: _Primitive.ink700,
    textMuted: _Primitive.ink500,
    textDisabled: _Primitive.neutral400,
    accentPrimary: _Primitive.sage500,
    accentPrimaryHover: _Primitive.sage400,
    accentSecondary: _Primitive.dusk500,
    accentWarmth: _Primitive.amber600,
    crisisSurface: _Primitive.coral100,
    crisisAction: _Primitive.coral600,
    crisisActionHover: _Primitive.coral500,
    crisisText: _Primitive.coral600,
    interactiveFocus: _Primitive.dusk500,
    successSubtle: _Primitive.sage500,
  );
}

/// Convenience accessor for semantic colors in the widget tree
extension AppColorsX on BuildContext {
  AppCustomColors get colors =>
      Theme.of(this).extension<AppCustomColors>() ?? AppCustomColors.dark;
}

/// Convenience aliases matching design system specifications across UI widgets
extension AppCustomColorsAliases on AppCustomColors {
  Color get actionSage => accentPrimary;
  Color get actionSageHover => accentPrimaryHover;
  Color get surfaceCard => bgSurface;
  Color get surfaceSubtle => bgSurfaceRaised;
  Color get surfaceElevated => bgSurfaceRaised;
  Color get surfaceBase => bgCanvas;
  Color get surfaceDeep => bgCanvasDeep;
  Color get surface => bgSurface;
  Color get surfaceContainer => bgSurface;
  Color get container => bgSurfaceRaised;
  Color get borderSubtle => bgOverlay;
  Color get borderMuted => bgOverlay;
  Color get borderOpaque => textDisabled;
  Color get textInverse => bgCanvasDeep;
  Color get background => bgCanvas;
  Color get canvasBackdrop => bgCanvasDeep;
  Color get textTertiary => textMuted;
  Color get textFaint => textDisabled;
  Color get crisisRed => crisisAction;
  Color get crisisCoral => crisisAction;
  Color get crisisCoralSurface => crisisSurface;
  Color get accentAmber => accentWarmth;
  Color get emergencyShield => accentWarmth;
  Color get accentDusk => accentSecondary;
  Color get warningAmber => accentWarmth;
  Color get infoDusk => accentSecondary;
  Color get successGreen => successSubtle;
  Color get primary => accentPrimary;
  Color get secondary => accentSecondary;
  Color get onPrimary => bgCanvasDeep;
  Color get onSurface => textPrimary;
  Color get onSurfaceVariant => textSecondary;
  Color get onError => const Color(0xFFFFFFFF);
}
