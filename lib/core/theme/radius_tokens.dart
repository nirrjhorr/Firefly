/// Centralized corner radius design tokens for Firefly.
/// Defines an intentional, Apple-inspired scale from compact tags to full capsules.
abstract final class RadiusTokens {
  /// 8dp - Micro tags, inner chips, indicators, alert banners
  static const double xs = 8.0;

  /// 12dp - Form input fields, secondary controls, category chips, list tiles
  static const double sm = 12.0;

  /// 14dp - Secondary buttons, alert notifications
  static const double md = 14.0;

  /// 16dp - Standard cards, primary buttons, list item cards
  static const double lg = 16.0;

  /// 20dp - Mood anchor selector tiles, large feature containers, floating player bar
  static const double xl = 20.0;

  /// 24dp - Modal bottom sheets, full dialog containers
  static const double sheet = 24.0;

  /// 28dp - Floating action button, near-circular emergency controls
  static const double fab = 28.0;

  /// 32dp - Pill containers, segmented control sliders, capsule chips
  static const double pill = 32.0;

  /// 999dp - Circular icons, avatars, indicator dots
  static const double circular = 999.0;

  // ── Semantic Aliases ────────────────────────────────────────────────────────
  static const double full = circular;
  static const double card = lg;
  static const double container = lg;
  static const double button = lg;
  static const double buttonSecondary = md;
  static const double input = sm;
  static const double chip = sm;
  static const double dialog = sheet;
  static const double modal = sheet;
  static const double bottomSheet = sheet;
  static const double modalRadius = sheet;
  static const double radiusXs = xs;
  static const double radiusSm = sm;
  static const double radiusMd = md;
  static const double radiusLg = lg;
  static const double radiusXl = xl;
  static const double radiusPill = pill;
}
