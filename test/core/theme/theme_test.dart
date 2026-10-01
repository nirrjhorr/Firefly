import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firefly/core/theme/app_colors.dart';
import 'package:firefly/core/theme/app_theme.dart';
import 'package:firefly/core/theme/app_typography.dart';
import 'package:firefly/core/theme/spacing_tokens.dart';

void main() {
  group('Theme & Design System Tokens', () {
    test('Dark theme uses expected background canvas and semantic colors', () {
      final dark = AppTheme.darkTheme;
      final colors = AppCustomColors.dark;

      expect(dark.scaffoldBackgroundColor, equals(colors.bgCanvas));
      expect(dark.brightness, equals(Brightness.dark));
      expect(colors.bgCanvas, equals(const Color(0xFF111518)));
      expect(colors.bgCanvasDeep, equals(const Color(0xFF0A0D0F)));
      expect(colors.accentPrimary, equals(const Color(0xFF4A7862)));
      expect(colors.crisisAction, equals(const Color(0xFFB05454)));
    });

    test('Light theme uses expected background canvas and semantic colors', () {
      final light = AppTheme.lightTheme;
      final colors = AppCustomColors.light;

      expect(light.scaffoldBackgroundColor, equals(colors.bgCanvas));
      expect(light.brightness, equals(Brightness.light));
      expect(colors.bgCanvas, equals(const Color(0xFFF5F7F9)));
      expect(colors.accentPrimary, equals(const Color(0xFF4A7862)));
      expect(colors.crisisAction, equals(const Color(0xFF7D3030)));
    });

    test('Spacing tokens adhere to 4pt/8pt baseline grid', () {
      expect(SpacingTokens.space2xs, equals(4.0));
      expect(SpacingTokens.spaceXs, equals(8.0));
      expect(SpacingTokens.spaceSm, equals(12.0));
      expect(SpacingTokens.spaceMd, equals(16.0));
      expect(SpacingTokens.spaceLg, equals(20.0));
      expect(SpacingTokens.spaceXl, equals(24.0));
      expect(SpacingTokens.space2xl, equals(32.0));
      expect(SpacingTokens.space3xl, equals(48.0));
      expect(SpacingTokens.space4xl, equals(64.0));
    });

    test('Typography uses Atkinson Hyperlegible and Plus Jakarta Sans', () {
      expect(AppTypography.headingLg.fontFamily, equals('AtkinsonHyperlegible'));
      expect(AppTypography.bodyLg.fontFamily, equals('AtkinsonHyperlegible'));
      expect(AppTypography.displayXl.fontFamily, equals('PlusJakartaSans'));
      expect(AppTypography.monoSm.fontFamily, equals('JetBrainsMono'));
    });
  });
}
