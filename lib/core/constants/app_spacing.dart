/// Single source of truth for all spacing values.
///
/// Rules every screen must follow:
///   • Horizontal content: always [pagePadding] (20) left + right
///   • Section gap (between major zones): [xl] (24)
///   • Bottom safe-area breathing room: [xxl] (32)
///   • Card internal padding: [cardPadding] (16)
class AppSpacing {
  AppSpacing._();

  // ── Base scale ───────────────────────────────────────────────────────────────
  static const double xs    = 4;
  static const double sm    = 8;
  static const double md    = 12;
  static const double lg    = 16;
  static const double xl    = 24;
  static const double xxl   = 32;
  static const double xxxl  = 48;
  static const double huge  = 64;

  // ── Structural ───────────────────────────────────────────────────────────────

  /// Horizontal padding for all full-width content regions.
  static const double pagePadding = 20;

  /// Standard padding inside cards and surface containers.
  static const double cardPadding = 16;

  /// Height of the persistent bottom navigation bar.
  static const double bottomNavHeight = 80;

  // ── Corner radii ─────────────────────────────────────────────────────────────
  static const double radiusXs   = 6;
  static const double radiusSm   = 10;
  static const double radiusMd   = 14;
  static const double radiusLg   = 18;
  static const double radiusXl   = 24;
  static const double radiusFull = 999;
}
