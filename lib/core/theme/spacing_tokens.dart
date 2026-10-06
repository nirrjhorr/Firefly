/// Spacing tokens based on the 4pt / 8pt baseline grid.
/// Centralizes all padding, margins, gaps, screen layout rhythms, and component dimensions.
abstract final class SpacingTokens {
  // ── Primitives (4pt / 8pt Baseline Grid) ───────────────────────────────────
  static const double space2xs = 4.0;
  static const double spaceXs = 8.0;
  static const double spaceSm = 12.0;
  static const double spaceMd = 16.0;
  static const double spaceLg = 20.0;
  static const double spaceXl = 24.0;
  static const double space2xl = 32.0;
  static const double space3xl = 48.0;
  static const double space4xl = 64.0;

  // ── Canonical Shorthand Aliases ─────────────────────────────────────────────
  static const double xxs = space2xs;
  static const double xs = spaceXs;
  static const double sm = spaceSm;
  static const double md = spaceMd;
  static const double lg = spaceLg;
  static const double xl = spaceXl;
  static const double xxl = space2xl;
  static const double spaceXxl = space2xl;

  // ── Canonical Semantic Layout Tokens ────────────────────────────────────────
  /// Standard screen horizontal padding across all primary screens (20dp)
  static const double screenPaddingH = 20.0;

  /// Standard screen vertical padding (16dp)
  static const double screenPaddingV = 16.0;

  /// Standard inner padding for cards and containers (16dp)
  static const double cardPadding = 16.0;

  /// Expanded padding for prominent cards or modals (20dp)
  static const double cardPaddingLg = 20.0;

  /// Compact padding for list cards or tight items (12dp)
  static const double cardPaddingSm = 12.0;

  /// Standard spacing between major vertical sections (24dp)
  static const double sectionGap = 24.0;

  /// Standard spacing between related elements in a group (12dp)
  static const double elementGap = 12.0;

  /// Minimum interactive touch target dimension (Apple HIG >= 44x44dp)
  static const double minTouchTarget = 44.0;

  /// Recommended touch target dimension for emotional distress (48dp-56dp)
  static const double accessibleTouchTarget = 48.0;

  /// Bottom scroll clearance to prevent content occlusion by bottom nav & SOS button (80dp)
  static const double bottomClearance = 80.0;

  // ── Canonical Component Dimension Tokens ────────────────────────────────────
  /// Primary button height (56dp)
  static const double buttonHeightPrimary = 56.0;

  /// Secondary button height (52dp)
  static const double buttonHeightSecondary = 52.0;

  /// Tertiary / Small Primary button height (44dp)
  static const double buttonHeightTertiary = 44.0;

  /// Small Secondary button height (40dp)
  static const double buttonHeightSmall = 40.0;

  /// Form text input height (52dp)
  static const double inputHeight = 52.0;

  /// Mood anchor tile dimension (72dp x 72dp)
  static const double moodTileSize = 72.0;

  /// Floating emergency SOS trigger dimension (56dp x 56dp)
  static const double sosButtonSize = 56.0;

  /// Bottom navigation bar height (64dp)
  static const double navBarHeight = 64.0;

  /// Floating player bar height (72dp)
  static const double playerBarHeight = 72.0;
}
