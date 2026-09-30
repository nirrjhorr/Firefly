import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  // ── Dark Theme (Default) ────────────────────────────────────────────────────
  static final darkTheme = _buildTheme(
    brightness: Brightness.dark,
    custom: AppCustomColors.dark,
    systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: const Color(0xFF111518),
    ),
  );

  // ── Light Theme ─────────────────────────────────────────────────────────────
  static final lightTheme = _buildTheme(
    brightness: Brightness.light,
    custom: AppCustomColors.light,
    systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: const Color(0xFFF5F7F9),
    ),
  );

  // ── Builder ─────────────────────────────────────────────────────────────────
  static ThemeData _buildTheme({
    required Brightness brightness,
    required AppCustomColors custom,
    required SystemUiOverlayStyle systemOverlayStyle,
  }) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: custom.accentPrimary,
      onPrimary: custom.textPrimary,
      primaryContainer: isDark ? const Color(0xFF2D4A3A) : const Color(0xFFDFF0E6),
      onPrimaryContainer: custom.textPrimary,
      secondary: custom.accentSecondary,
      onSecondary: custom.textPrimary,
      secondaryContainer: isDark ? const Color(0xFF1E3050) : const Color(0xFFD8E6F4),
      onSecondaryContainer: custom.textPrimary,
      tertiary: custom.accentWarmth,
      onTertiary: custom.textPrimary,
      error: custom.crisisAction,
      onError: custom.textPrimary,
      errorContainer: custom.crisisSurface,
      onErrorContainer: custom.crisisText,
      surface: custom.bgSurface,
      onSurface: custom.textPrimary,
      surfaceContainerHighest: custom.bgSurfaceRaised,
      outline: custom.bgOverlay,
      outlineVariant: custom.textDisabled,
      scrim: Colors.black.withOpacity(0.6),
      shadow: Colors.transparent, // Elevation via surface color
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: custom.bgCanvas,
      canvasColor: custom.bgCanvas,

      // ── Typography ──────────────────────────────────────────────────────────
      textTheme: AppTypography.toTextTheme(custom.textPrimary),

      // ── Extensions ──────────────────────────────────────────────────────────
      extensions: [custom],

      // ── App Bar ─────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: custom.bgCanvas,
        foregroundColor: custom.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: systemOverlayStyle,
        titleTextStyle: AppTypography.headingMd.copyWith(color: custom.textPrimary),
      ),

      // ── Cards ───────────────────────────────────────────────────────────────
      cardTheme: CardTheme(
        color: custom.bgSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: custom.bgOverlay, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),

      // ── Bottom Navigation ────────────────────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: custom.bgSurface,
        indicatorColor: custom.accentPrimary.withOpacity(0.15),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: custom.accentPrimary, size: 24);
          }
          return IconThemeData(color: custom.textMuted, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTypography.labelMd.copyWith(color: custom.accentPrimary);
          }
          return AppTypography.labelMd.copyWith(color: custom.textMuted);
        }),
        elevation: 0,
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),

      // ── ElevatedButton (Primary CTA) ─────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return custom.accentPrimary.withOpacity(0.30);
            }
            return custom.accentPrimary;
          }),
          foregroundColor: WidgetStateProperty.all(custom.textPrimary),
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          minimumSize: WidgetStateProperty.all(const Size.fromHeight(56)),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          elevation: WidgetStateProperty.all(0),
          textStyle: WidgetStateProperty.all(AppTypography.labelLg),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
        ),
      ),

      // ── OutlinedButton (Secondary CTA) ─────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(custom.accentPrimary),
          side: WidgetStateProperty.all(
            BorderSide(color: custom.accentPrimary, width: 1.5),
          ),
          minimumSize: WidgetStateProperty.all(const Size.fromHeight(52)),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          elevation: WidgetStateProperty.all(0),
          textStyle: WidgetStateProperty.all(AppTypography.labelLg),
        ),
      ),

      // ── Text Field (Journal input) ───────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: custom.bgSurface,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: custom.bgOverlay),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: custom.bgOverlay),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: custom.interactiveFocus, width: 2),
        ),
        hintStyle: AppTypography.bodyLg.copyWith(color: custom.textMuted),
      ),

      // ── Divider ─────────────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: custom.bgOverlay,
        thickness: 1,
        space: 1,
      ),

      // ── Bottom Sheet ────────────────────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: custom.bgSurface,
        modalBackgroundColor: custom.bgSurface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        elevation: 0,
        modalElevation: 0,
        dragHandleColor: custom.bgOverlay,
        dragHandleSize: const Size(40, 4),
      ),

      // ── Focus ───────────────────────────────────────────────────────────────
      focusColor: custom.interactiveFocus.withOpacity(0.15),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
    );
  }
}
