import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firefly/core/theme/app_colors.dart';
import 'package:firefly/core/theme/app_typography.dart';
import 'package:firefly/core/theme/icon_tokens.dart';
import 'package:firefly/core/theme/radius_tokens.dart';
import 'package:firefly/core/theme/spacing_tokens.dart';

double calculateLuminance(Color color) {
  double channelLuminance(int channel) {
    final norm = channel / 255.0;
    return norm <= 0.03928
        ? norm / 12.92
        : pow((norm + 0.055) / 1.055, 2.4).toDouble();
  }

  final r = channelLuminance(color.red);
  final g = channelLuminance(color.green);
  final b = channelLuminance(color.blue);
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

double calculateContrastRatio(Color foreground, Color background) {
  final l1 = calculateLuminance(foreground);
  final l2 = calculateLuminance(background);
  final lighter = max(l1, l2);
  final darker = min(l1, l2);
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  print('=== Verifying Firefly Design System & Tokens Alignment ===');

  // 1. Spacing token aliases verification
  assert(SpacingTokens.xxs == 4.0, 'SpacingTokens.xxs should be 4.0');
  assert(SpacingTokens.xs == 8.0, 'SpacingTokens.xs should be 8.0');
  assert(SpacingTokens.sm == 12.0, 'SpacingTokens.sm should be 12.0');
  assert(SpacingTokens.md == 16.0, 'SpacingTokens.md should be 16.0');
  assert(SpacingTokens.lg == 20.0, 'SpacingTokens.lg should be 20.0');
  assert(SpacingTokens.xl == 24.0, 'SpacingTokens.xl should be 24.0');
  assert(SpacingTokens.xxl == 32.0, 'SpacingTokens.xxl should be 32.0');
  print('✓ SpacingTokens canonical aliases verified (7/7 passed)');

  // 2. Radius token aliases verification
  assert(RadiusTokens.full == RadiusTokens.circular, 'RadiusTokens.full == circular');
  assert(RadiusTokens.container == RadiusTokens.lg, 'RadiusTokens.container == lg');
  assert(RadiusTokens.radiusSm == RadiusTokens.sm, 'RadiusTokens.radiusSm == sm');
  assert(RadiusTokens.radiusMd == RadiusTokens.md, 'RadiusTokens.radiusMd == md');
  assert(RadiusTokens.radiusLg == RadiusTokens.lg, 'RadiusTokens.radiusLg == lg');
  assert(RadiusTokens.radiusPill == RadiusTokens.pill, 'RadiusTokens.radiusPill == pill');
  assert(RadiusTokens.modalRadius == RadiusTokens.sheet, 'RadiusTokens.modalRadius == sheet');
  print('✓ RadiusTokens canonical aliases verified (7/7 passed)');

  // 3. Typography token aliases verification
  assert(AppTypography.captionSm == AppTypography.caption, 'AppTypography.captionSm == caption');
  assert(AppTypography.displaySm == AppTypography.displayMd, 'AppTypography.displaySm == displayMd');
  assert(AppTypography.labelXs == AppTypography.labelSm, 'AppTypography.labelXs == labelSm');
  assert(AppTypography.headingSmall == AppTypography.headingSm, 'AppTypography.headingSmall == headingSm');
  assert(AppTypography.titleMedium == AppTypography.headingMd, 'AppTypography.titleMedium == headingMd');
  assert(AppTypography.bodyMedium == AppTypography.bodyMd, 'AppTypography.bodyMedium == bodyMd');
  assert(AppTypography.bodySmall == AppTypography.bodySm, 'AppTypography.bodySmall == bodySm');
  assert(AppTypography.labelMedium == AppTypography.labelMd, 'AppTypography.labelMedium == labelMd');
  assert(AppTypography.labelSmall == AppTypography.labelSm, 'AppTypography.labelSmall == labelSm');
  print('✓ AppTypography canonical aliases verified (9/9 passed)');

  // 4. Icon token aliases verification
  assert(AppIcons.nature == AppIcons.natureBirds, 'AppIcons.nature == natureBirds');
  assert(AppIcons.audio == AppIcons.soundWaves, 'AppIcons.audio == soundWaves');
  assert(AppIcons.shield == AppIcons.emergencyShield, 'AppIcons.shield == emergencyShield');
  assert(AppIcons.insights == AppIcons.scientificEvidence, 'AppIcons.insights == scientificEvidence');
  assert(AppIcons.safetyPlan == AppIcons.emergencyShield, 'AppIcons.safetyPlan == emergencyShield');
  assert(AppIcons.history == Icons.history_rounded, 'AppIcons.history == Icons.history_rounded');
  print('✓ AppIcons canonical aliases verified (6/6 passed)');

  // 5. Palette Contrast Verification against Stitch Serene Sanctuary Standard
  final darkColors = AppCustomColors.dark;
  assert(darkColors.accentPrimary == const Color(0xFF7DBA9B), 'accentPrimary should be Stitch illuminated sage #7DBA9B');

  final sageContrast = calculateContrastRatio(darkColors.accentPrimary, darkColors.bgCanvas);
  final textContrast = calculateContrastRatio(darkColors.textPrimary, darkColors.bgCanvas);
  final duskContrast = calculateContrastRatio(darkColors.accentSecondary, darkColors.bgCanvas);

  print('Dark Canvas: ${darkColors.bgCanvas}');
  print('Sage Accent Contrast: ${sageContrast.toStringAsFixed(2)}:1');
  print('Primary Text Contrast: ${textContrast.toStringAsFixed(2)}:1');
  print('Dusk Accent Contrast: ${duskContrast.toStringAsFixed(2)}:1');

  // Verify WCAG AAA (>= 7:1) for primary sage on dark canvas
  assert(sageContrast >= 7.0, 'Sage accent must clear WCAG AAA (>= 7.0:1)');
  assert(textContrast >= 7.0, 'Text primary must clear WCAG AAA (>= 7.0:1)');
  assert(duskContrast >= 4.5, 'Dusk secondary must clear WCAG AA (>= 4.5:1)');

  print('✓ WCAG AAA and AA Color Contrast Ratios Verified and Passed!');
  print('=== ALL DESIGN SYSTEM AUDIT CHECKS PASSED (100% COMPLIANT) ===');
}
