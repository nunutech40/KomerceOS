/// Design Token — Border Radius
///
/// Standardized corner radii for consistent component shapes.
/// All values are `double` constants — no Flutter imports needed.
///
/// Naming convention:
///   AppRadius.<size>        → raw double value
///   Use with BorderRadius.circular(AppRadius.<size>)
abstract final class AppRadius {
  // ---------------------------------------------------------------------------
  // NONE / SHARP
  // ---------------------------------------------------------------------------

  /// 0 px — no rounding (sharp corners)
  static const double none = 0.0;

  // ---------------------------------------------------------------------------
  // SMALL
  // ---------------------------------------------------------------------------

  /// 4 px — small radius (badges, tags, chips)
  static const double sm = 4.0;

  /// 6 px — slight rounding (compact inputs)
  static const double md3 = 6.0;

  // ---------------------------------------------------------------------------
  // MEDIUM
  // ---------------------------------------------------------------------------

  /// 8 px — default card / button radius
  static const double md = 8.0;

  /// 10 px — slightly rounder buttons
  static const double md2 = 10.0;

  // ---------------------------------------------------------------------------
  // LARGE
  // ---------------------------------------------------------------------------

  /// 12 px — elevated card, dialog
  static const double lg = 12.0;

  /// 16 px — prominent card, bottom sheet header
  static const double lg2 = 16.0;

  /// 20 px — large bottom sheet
  static const double xl = 20.0;

  /// 24 px — hero card, modal
  static const double xl2 = 24.0;

  // ---------------------------------------------------------------------------
  // EXTRA LARGE / PILL
  // ---------------------------------------------------------------------------

  /// 32 px — pill button (large)
  static const double pill = 32.0;

  /// 48 px — very wide pill
  static const double pillLg = 48.0;

  // ---------------------------------------------------------------------------
  // CIRCULAR — Use for avatars, FABs, and icon containers
  // ---------------------------------------------------------------------------

  /// 999 px — forces a perfect circle for any reasonable widget size
  static const double circular = 999.0;
}