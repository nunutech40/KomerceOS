/// Design Token — Spacing
///
/// 4-point grid system for consistent layout spacing and touch-target sizing.
/// All values are `double` constants — no Flutter imports needed.
///
/// Naming convention:
///   AppSpacing.<size>          → generic layout spacing
///   AppSpacing.touch<Size>     → minimum touch-target height/width (≥ 44 px)
///   AppSpacing.inset<Size>     → symmetric padding shorthands
abstract final class AppSpacing {
  // ---------------------------------------------------------------------------
  // BASE GRID UNIT
  // ---------------------------------------------------------------------------

  /// Fundamental grid unit (4 px). Prefer the named constants below.
  static const double unit = 4.0;

  // ---------------------------------------------------------------------------
  // SPACING SCALE — 4-point grid
  // ---------------------------------------------------------------------------

  /// 2 px — hairline gap, icon-to-label nudge
  static const double xxs = 2.0;

  /// 4 px — tight gap between inline elements
  static const double xs = 4.0;

  /// 6 px — tight gap between inline elements
  static const double xs2 = 6.0;

  /// 8 px — small gap (icon + label, chip padding)
  static const double sm = 8.0;

  /// 14 px — default content padding
  static const double md2 = 14.0;

  /// 12 px — inner card padding (vertical)
  static const double md3 = 12.0;

  /// 16 px — default content padding / section gap
  static const double md = 16.0;

  /// 20 px — spacer between grouped form fields
  static const double lg3 = 20.0;

  /// 24 px — section header spacing
  static const double lg = 24.0;

  /// 32 px — large section / hero spacing
  static const double xl = 32.0;

  /// 40 px — major section divider
  static const double xl2 = 40.0;

  /// 48 px — hero / banner vertical padding
  static const double xl3 = 48.0;

  /// 64 px — large hero spacing
  static const double xl4 = 64.0;

  /// 80 px — extra-large hero spacing / empty-state art area
  static const double xl5 = 80.0;

  // ---------------------------------------------------------------------------
  // TOUCH TARGETS
  // Minimum sizes recommended for accessible, fast touch interaction.
  // Material recommends ≥ 48 px; iOS HIG recommends ≥ 44 pt.
  // ---------------------------------------------------------------------------

  /// 44 px — minimum accessible tap target (iOS HIG)
  static const double touchSm = 44.0;

  /// 48 px — standard Material touch target
  static const double touchMd = 48.0;

  /// 56 px — prominent button / FAB height
  static const double touchLg = 56.0;

  /// 64 px — large list-item row / bottom-nav height
  static const double touchXl = 64.0;

  // ---------------------------------------------------------------------------
  // INSET SHORTHANDS (symmetric content padding)
  // Use these with EdgeInsets.all() / symmetric()
  // ---------------------------------------------------------------------------

  /// 4 px all-around (very tight)
  static const double insetXs = 4.0;

  /// 8 px all-around (chip / badge)
  static const double insetSm = 8.0;

  /// 12 px all-around (compact card)
  static const double insetMd3 = 12.0;

  /// 16 px all-around (standard card / dialog)
  static const double insetMd = 16.0;

  /// 20 px all-around (generous card)
  static const double insetLg3 = 20.0;

  /// 24 px all-around (section container)
  static const double insetLg = 24.0;

  // ---------------------------------------------------------------------------
  // HORIZONTAL PAGE MARGINS
  // ---------------------------------------------------------------------------

  static const double pageMargin2xs = 4.0;

  /// Small horizontal page margin (8 px)
  static const double pageMarginSm = 8.0;

  /// Default horizontal page margin (16 px)
  static const double pageMargin = 16.0;

  /// Generous horizontal page margin (24 px) for wider screens
  static const double pageMarginLg = 24.0;

  // ---------------------------------------------------------------------------
  // ICON SIZES
  // ---------------------------------------------------------------------------

  static const double iconXs = 12.0;
  static const double iconSm = 16.0;
  static const double iconMd = 20.0;
  static const double iconLg = 24.0;
  static const double iconXl = 32.0;
  static const double iconXxl = 48.0;
}
