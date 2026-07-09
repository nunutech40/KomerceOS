import 'package:flutter/material.dart';

/// Design Token — Colors
///
/// Semantic color constants for the Komtim Partner design system.
/// All colors are immutable `const` values — no ThemeData, no widgets here.
///
/// Naming convention:
///   AppColors.<group><Variant>
///   e.g. AppColors.primaryBase, AppColors.grey300
abstract final class AppColors {
  // ---------------------------------------------------------------------------
  // PRIMARY — Orange brand
  // ---------------------------------------------------------------------------

  /// Main brand orange — used for CTAs, active states
  static const Color primaryBase = Color(0xFFF95E16);

  /// Darker shade — pressed / hover states
  static const Color primaryDark = Color(0xFFD84E0F);

  /// Light tint — chips, highlighted backgrounds
  static const Color primaryLight = Color(0xFFFFEBE1);

  /// Very light tint — tag backgrounds, banners
  static const Color primarySubtle = Color(0xFFFFF2EC);

  /// Tag background
  static const Color primaryTag = Color(0xFFFFD5C4);

  // ---------------------------------------------------------------------------
  // SECONDARY — Blue accent
  // ---------------------------------------------------------------------------

  static const Color secondaryBase = Color(0xFF08A0F7);
  static const Color secondaryLight = Color(0xFFDFF3FF);

  // ---------------------------------------------------------------------------
  // BACKGROUND & SURFACE
  // ---------------------------------------------------------------------------

  /// Page / scaffold background
  static const Color background = Color(0xFFF8F8F8);

  /// Card / sheet / dialog surface
  static const Color surface = Color(0xFFFFFFFF);

  /// Background untuk popup / dialog
  static const Color bgPopup = Color(0xFFDCDCDC);

  /// Slightly off-white surface (dividers, subtle fills)
  static const Color surfaceMuted = Color(0xFFF4F4F4);

  /// Elevated surface inside cards / containers
  static const Color surfaceContainer = Color(0xFFF2F2F2);

  static const Color bgLight = Color(0xFFF5F5F5);

  // ---------------------------------------------------------------------------
  // SEMANTIC — Success
  // ---------------------------------------------------------------------------

  static const Color successBase = Color(0xFF34A853);
  static const Color successLight = Color(0xFFDCF3EB);

  // ---------------------------------------------------------------------------
  // SEMANTIC — Warning
  // ---------------------------------------------------------------------------

  static const Color warningBase = Color(0xFFFBA63C);
  static const Color warningDark = Color(0xFFAF6A13);
  static const Color warningLight = Color(0xFFFFF2E2);

  // ---------------------------------------------------------------------------
  // SEMANTIC — Error / Danger
  // ---------------------------------------------------------------------------

  static const Color errorBase = Color(0xFFE31A1A);
  static const Color errorLight = Color(0xFFFCE8E8);

  // ---------------------------------------------------------------------------
  // SEMANTIC — Info / Accent
  // ---------------------------------------------------------------------------

  static const Color infoBase = Color(0xFF4285F4);
  static const Color infoAlt = Color(0xFF6D3CB8); // Purple accent
  static const Color infoAltLight = Color(0xFFE2D8F1);
  static const Color infoOrange = Color(0xFFF95031);
  static const Color infoOrangeLight = Color(0xFFFEF3E6);

  // ---------------------------------------------------------------------------
  // GREY SCALE — Text & Borders
  // ---------------------------------------------------------------------------

  /// Pure black
  static const Color grey900 = Color(0xFF000000);

  /// Near-black — primary dark text
  static const Color black = Color(0xFF222222);

  /// Near-black — primary text
  static const Color grey800 = Color(0xFF333333);

  /// Dark grey — secondary text
  static const Color grey700 = Color(0xFF626262);

  /// Mid grey — placeholder / disabled text
  static const Color grey600 = Color(0xFF828282);

  /// Inactive / hint text
  static const Color grey400 = Color(0xFFC2C2C2);

  /// Disabled button background
  static const Color grey350 = Color(0xFFD9D9D9);

  /// Border stroke
  static const Color grey300 = Color(0xFFCCCCCC);

  /// Separator / divider lines
  static const Color grey200 = Color(0xFFE2E2E2);

  /// Subtle background fills
  static const Color grey100 = Color(0xFFF4F4F4);

  /// Page background / lightest grey
  static const Color grey50 = Color(0xFFF8F8F8);

  // ---------------------------------------------------------------------------
  // ALWAYS — Absolute values independent of theme
  // ---------------------------------------------------------------------------

  static const Color alwaysWhite = Color(0xFFFFFFFF);
  static const Color alwaysBlack = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);
}
