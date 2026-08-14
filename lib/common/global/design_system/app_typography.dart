import 'package:flutter/material.dart';

/// Design Token — Typography
///
/// Standardized [TextStyle] constants for the Komtim Partner design system.
///
/// Primary font  : **Plus Jakarta Sans** (`PlusJakartaSans`) — declared in pubspec.yaml
/// Secondary font: **Inter** — for numeric/mono-spaced content and notification items
///
/// Naming convention (read left → right):
///   AppTypography.<category><Weight><Size?>
///
///   Categories  : display | heading | body | label
///   Weights     : Regular (400) | Medium (500) | SemiBold (600) | Bold (700)
///   Sizes       : Numeric suffix where ambiguous (e.g., bodySm = 12, bodyMd = 14, bodyLg = 16)
///
/// All [TextStyle]s are declared as `static const` — no colors baked in.
/// Apply color at the call site via `.copyWith(color: AppColors.grey800)`.
abstract final class AppTypography {
  // ---------------------------------------------------------------------------
  // FONT FAMILY CONSTANTS
  // ---------------------------------------------------------------------------

  static const String _primaryFont = 'PlusJakartaSans';
  static const String _secondaryFont = 'Inter';

  // ---------------------------------------------------------------------------
  // DISPLAY — Hero text, splash screens, empty states
  // Sizes: 32, 40, 48
  // ---------------------------------------------------------------------------

  /// Display Small — 32 / Bold
  static const TextStyle displaySm = TextStyle(
    fontFamily: _primaryFont,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
  );

  /// Display Medium — 40 / Bold
  static const TextStyle displayMd = TextStyle(
    fontFamily: _primaryFont,
    fontSize: 40,
    fontWeight: FontWeight.w700,
    height: 1.15,
    letterSpacing: -0.75,
  );

  /// Display Large — 48 / ExtraBold
  static const TextStyle displayLg = TextStyle(
    fontFamily: _primaryFont,
    fontSize: 48,
    fontWeight: FontWeight.w800,
    height: 1.1,
    letterSpacing: -1.0,
  );

  // ---------------------------------------------------------------------------
  // HEADING — Section titles, screen titles, card headers
  // Sizes: 16, 18, 20, 24
  // ---------------------------------------------------------------------------

  /// Heading Xxs Bold - 14/Bold
  static const TextStyle headingXxs = TextStyle(
    fontFamily: _primaryFont,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0,
  );

  /// Heading XSmall — 16 / SemiBold
  static const TextStyle headingXs = TextStyle(
    fontFamily: _primaryFont,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0,
  );

  /// Heading Small — 18 / SemiBold
  static const TextStyle headingSm = TextStyle(
    fontFamily: _primaryFont,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0,
  );

  /// Heading Medium — 20 / Bold
  static const TextStyle headingMd = TextStyle(
    fontFamily: _primaryFont,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.35,
    letterSpacing: -0.25,
  );

  /// Heading Large — 24 / Bold
  static const TextStyle headingLg = TextStyle(
    fontFamily: _primaryFont,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -0.25,
  );

  // ---------------------------------------------------------------------------
  // BODY — Reading content, descriptions, form values
  // Sizes: 12, 14, 16
  // ---------------------------------------------------------------------------

  // --- Body Small (12 px) ---

  /// Body Small Regular — 12 / Regular
  static const TextStyle bodySmRegular = TextStyle(
    fontFamily: _primaryFont,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0,
  );

  /// Body Small Medium — 12 / Medium
  static const TextStyle bodySmMedium = TextStyle(
    fontFamily: _primaryFont,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.5,
    letterSpacing: 0,
  );

  /// Body Small SemiBold — 12 / SemiBold
  static const TextStyle bodySmSemiBold = TextStyle(
    fontFamily: _primaryFont,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.5,
    letterSpacing: 0,
  );

  // --- Body Medium (14 px) ---

  /// Body Medium Regular — 14 / Regular
  static const TextStyle bodyMdRegular = TextStyle(
    fontFamily: _primaryFont,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0,
  );

  /// Body Medium Medium — 14 / Medium
  static const TextStyle bodyMdMedium = TextStyle(
    fontFamily: _primaryFont,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.5,
    letterSpacing: 0,
  );

  /// Body Medium SemiBold — 14 / SemiBold
  static const TextStyle bodyMdSemiBold = TextStyle(
    fontFamily: _primaryFont,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.5,
    letterSpacing: 0,
  );

  /// Body Medium Bold — 14 / Bold
  static const TextStyle bodyMdBold = TextStyle(
    fontFamily: _primaryFont,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.5,
    letterSpacing: 0,
  );

  // --- Body Large (16 px) ---

  /// Body Large Regular — 16 / Regular
  static const TextStyle bodyLgRegular = TextStyle(
    fontFamily: _primaryFont,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0,
  );

  /// Body Large Medium — 16 / Medium
  static const TextStyle bodyLgMedium = TextStyle(
    fontFamily: _primaryFont,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
    letterSpacing: 0,
  );

  /// Body Large SemiBold — 16 / SemiBold
  static const TextStyle bodyLgSemiBold = TextStyle(
    fontFamily: _primaryFont,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
    letterSpacing: 0,
  );

  /// Body Large Bold — 16 / Bold
  static const TextStyle bodyLgBold = TextStyle(
    fontFamily: _primaryFont,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.5,
    letterSpacing: 0,
  );

  // ---------------------------------------------------------------------------
  // LABEL — Buttons, form labels, tags, captions, nav items
  // Sizes: 10, 12, 14
  // ---------------------------------------------------------------------------

  /// Label XSmall — 10 / Regular (caption, badge text)
  static const TextStyle labelXs = TextStyle(
    fontFamily: _primaryFont,
    fontSize: 10,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0.1,
  );

  /// Label XSmall Medium — 10 / Medium
  static const TextStyle labelXsMedium = TextStyle(
    fontFamily: _primaryFont,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.1,
  );

  /// Label Small — 12 / Medium (tag, status chip)
  static const TextStyle labelSm = TextStyle(
    fontFamily: _primaryFont,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.1,
  );

  /// Label Small SemiBold — 12 / SemiBold
  static const TextStyle labelSmSemiBold = TextStyle(
    fontFamily: _primaryFont,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.1,
  );

  /// Label Medium — 14 / Medium (form label, nav item)
  static const TextStyle labelMd = TextStyle(
    fontFamily: _primaryFont,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0,
  );

  /// Label Medium SemiBold — 14 / SemiBold (active nav item)
  static const TextStyle labelMdSemiBold = TextStyle(
    fontFamily: _primaryFont,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0,
  );

  /// Label Large — 16 / SemiBold (button text)
  static const TextStyle labelLg = TextStyle(
    fontFamily: _primaryFont,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: 0,
  );

  // ---------------------------------------------------------------------------
  // NUMERIC / SECONDARY FONT — Inter
  // Use for currency amounts, codes, timestamps, invoice numbers
  // ---------------------------------------------------------------------------

  /// Numeric Small — Inter 12 / Regular
  static const TextStyle numericSm = TextStyle(
    fontFamily: _secondaryFont,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0,
  );

  /// Numeric Medium — Inter 14 / Regular
  static const TextStyle numericMd = TextStyle(
    fontFamily: _secondaryFont,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0,
  );

  /// Numeric Medium SemiBold — Inter 14 / SemiBold
  static const TextStyle numericMdSemiBold = TextStyle(
    fontFamily: _secondaryFont,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.5,
    letterSpacing: 0,
  );

  /// Numeric Large — Inter 16 / SemiBold (invoice total, balance)
  static const TextStyle numericLg = TextStyle(
    fontFamily: _secondaryFont,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0,
  );

  /// Numeric XLarge — Inter 20 / Bold (hero balance, amounts)
  static const TextStyle numericXl = TextStyle(
    fontFamily: _secondaryFont,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -0.25,
  );

  // ---------------------------------------------------------------------------
  // LEGACY STYLES (To be refactored)
  // ---------------------------------------------------------------------------

  /// Inter SemiBold 18
  static const TextStyle interSemiBold18 = TextStyle(
    fontFamily: _secondaryFont,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0,
  );

  /// Inter SemiBold 16
  static const TextStyle interSemiBold16 = TextStyle(
    fontFamily: _secondaryFont,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0,
  );

  /// Inter Regular 14
  static const TextStyle interRegular14 = TextStyle(
    fontFamily: _secondaryFont,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0,
  );

  /// Inter Regular 12
  static const TextStyle interRegular12 = TextStyle(
    fontFamily: _secondaryFont,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0,
  );
}
