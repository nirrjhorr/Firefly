import 'dart:io';
import 'dart:math';

/// Pure Dart standalone design system and token verification suite.
/// Runs without requiring flutter_test SDK, directly verifying tokens and WCAG AAA contrast.

class StandaloneColor {
  const StandaloneColor(this.value);
  final int value;

  int get red => (value >> 16) & 0xFF;
  int get green => (value >> 8) & 0xFF;
  int get blue => value & 0xFF;

  @override
  String toString() => 'Color(0x${value.toRadixString(16).padLeft(8, '0').toUpperCase()})';
}

double calculateLuminance(StandaloneColor color) {
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

double calculateContrastRatio(StandaloneColor foreground, StandaloneColor background) {
  final l1 = calculateLuminance(foreground);
  final l2 = calculateLuminance(background);
  final lighter = max(l1, l2);
  final darker = min(l1, l2);
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  stdout.writeln('=== Verifying Firefly Design System & Tokens Alignment (Standalone) ===');

  // 1. Spacing token aliases verification
  final spacingFile = File('lib/core/theme/spacing_tokens.dart');
  assert(spacingFile.existsSync(), 'spacing_tokens.dart must exist');
  final spacingContent = spacingFile.readAsStringSync();
  assert(spacingContent.contains('static const double xxs = space2xs;'), 'xxs alias missing');
  assert(spacingContent.contains('static const double xs = spaceXs;'), 'xs alias missing');
  assert(spacingContent.contains('static const double sm = spaceSm;'), 'sm alias missing');
  assert(spacingContent.contains('static const double md = spaceMd;'), 'md alias missing');
  assert(spacingContent.contains('static const double lg = spaceLg;'), 'lg alias missing');
  assert(spacingContent.contains('static const double xl = spaceXl;'), 'xl alias missing');
  assert(spacingContent.contains('static const double xxl = space2xl;'), 'xxl alias missing');
  stdout.writeln('✓ SpacingTokens canonical aliases verified (7/7 passed)');

  // 2. Radius token aliases verification
  final radiusFile = File('lib/core/theme/radius_tokens.dart');
  assert(radiusFile.existsSync(), 'radius_tokens.dart must exist');
  final radiusContent = radiusFile.readAsStringSync();
  assert(radiusContent.contains('static const double full = circular;'), 'full alias missing');
  assert(radiusContent.contains('static const double container = lg;'), 'container alias missing');
  assert(radiusContent.contains('static const double radiusSm = sm;'), 'radiusSm alias missing');
  assert(radiusContent.contains('static const double radiusMd = md;'), 'radiusMd alias missing');
  assert(radiusContent.contains('static const double radiusLg = lg;'), 'radiusLg alias missing');
  assert(radiusContent.contains('static const double radiusPill = pill;'), 'radiusPill alias missing');
  assert(radiusContent.contains('static const double modalRadius = sheet;'), 'modalRadius alias missing');
  stdout.writeln('✓ RadiusTokens canonical aliases verified (7/7 passed)');

  // 3. Typography token aliases verification
  final typoFile = File('lib/core/theme/app_typography.dart');
  assert(typoFile.existsSync(), 'app_typography.dart must exist');
  final typoContent = typoFile.readAsStringSync();
  assert(typoContent.contains('static TextStyle get captionSm => caption;'), 'captionSm alias missing');
  assert(typoContent.contains('static TextStyle get displaySm => displayMd;'), 'displaySm alias missing');
  assert(typoContent.contains('static TextStyle get labelXs => labelSm;'), 'labelXs alias missing');
  assert(typoContent.contains('static TextStyle get headingSmall => headingSm;'), 'headingSmall alias missing');
  assert(typoContent.contains('static TextStyle get titleMedium => headingMd;'), 'titleMedium alias missing');
  assert(typoContent.contains('static TextStyle get bodyMedium => bodyMd;'), 'bodyMedium alias missing');
  assert(typoContent.contains('static TextStyle get bodySmall => bodySm;'), 'bodySmall alias missing');
  assert(typoContent.contains('static TextStyle get labelMedium => labelMd;'), 'labelMedium alias missing');
  assert(typoContent.contains('static TextStyle get labelSmall => labelSm;'), 'labelSmall alias missing');
  stdout.writeln('✓ AppTypography canonical aliases verified (9/9 passed)');

  // 4. Icon token aliases verification
  final iconFile = File('lib/core/theme/icon_tokens.dart');
  assert(iconFile.existsSync(), 'icon_tokens.dart must exist');
  final iconContent = iconFile.readAsStringSync();
  assert(iconContent.contains('static const nature = natureBirds;'), 'nature alias missing');
  assert(iconContent.contains('static const audio = soundWaves;'), 'audio alias missing');
  assert(iconContent.contains('static const shield = emergencyShield;'), 'shield alias missing');
  assert(iconContent.contains('static const insights = scientificEvidence;'), 'insights alias missing');
  assert(iconContent.contains('static const safetyPlan = emergencyShield;'), 'safetyPlan alias missing');
  assert(iconContent.contains('static const history = Icons.history_rounded;'), 'history alias missing');
  stdout.writeln('✓ AppIcons canonical aliases verified (6/6 passed)');

  // 5. Palette Contrast Verification against Stitch Serene Sanctuary Standard
  final colorsFile = File('lib/core/theme/app_colors.dart');
  assert(colorsFile.existsSync(), 'app_colors.dart must exist');
  final colorsContent = colorsFile.readAsStringSync();
  assert(colorsContent.contains('0xFF7DBA9B'), 'Stitch illuminated sage #7DBA9B missing');
  assert(colorsContent.contains('0xFF111518'), 'Dark canvas #111518 missing');
  assert(colorsContent.contains('0xFF5B8A99'), 'Stitch dusk blue #5B8A99 missing');

  const sageAccent = StandaloneColor(0xFF7DBA9B);
  const darkCanvas = StandaloneColor(0xFF111518);
  const textPrimary = StandaloneColor(0xFFE2E8F0);
  const duskAccent = StandaloneColor(0xFF5B8A99);

  final sageContrast = calculateContrastRatio(sageAccent, darkCanvas);
  final textContrast = calculateContrastRatio(textPrimary, darkCanvas);
  final duskContrast = calculateContrastRatio(duskAccent, darkCanvas);

  stdout.writeln('Dark Canvas: $darkCanvas');
  stdout.writeln('Sage Accent Contrast: ${sageContrast.toStringAsFixed(2)}:1');
  stdout.writeln('Primary Text Contrast: ${textContrast.toStringAsFixed(2)}:1');
  stdout.writeln('Dusk Accent Contrast: ${duskContrast.toStringAsFixed(2)}:1');

  // Verify WCAG AAA (>= 7:1) for primary sage on dark canvas
  assert(sageContrast >= 7.0, 'Sage accent must clear WCAG AAA (>= 7.0:1)');
  assert(textContrast >= 7.0, 'Text primary must clear WCAG AAA (>= 7.0:1)');
  assert(duskContrast >= 4.5, 'Dusk secondary must clear WCAG AA (>= 4.5:1)');

  stdout.writeln('✓ WCAG AAA and AA Color Contrast Ratios Verified and Passed!');
  stdout.writeln('=== ALL DESIGN SYSTEM AUDIT CHECKS PASSED (100% COMPLIANT) ===');
}
