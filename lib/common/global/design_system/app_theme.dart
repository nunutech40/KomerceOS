import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Centralized [ThemeData] configuration for the Komtim Partner design system.
///
/// Usage in [MaterialApp]:
/// ```dart
/// MaterialApp.router(
///   theme: AppTheme.lightTheme,
///   ...
/// )
/// ```
///
/// Rules:
/// - All values come from design token classes — no hardcoded literals.
/// - [useMaterial3] is enabled.
/// - Touch targets are set to meet accessibility minimums (≥ 44 px).
/// - Optimised for a fast, touch-first POS/partner workflow.
abstract final class AppTheme {
  // ---------------------------------------------------------------------------
  // LIGHT THEME
  // ---------------------------------------------------------------------------

  static ThemeData get lightTheme {
    final colorScheme = _colorScheme;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      // -------------------------------------------------------------------------
      // MINIMAL CONFIGURATION (MATCHING OLD LEGACY THEME)
      // -------------------------------------------------------------------------
      scaffoldBackgroundColor: AppColors.alwaysWhite,
      textTheme: _buildTextTheme(),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.alwaysWhite,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.alwaysWhite,
      ),

      /* 
      // =========================================================================
      // FUTURE DESIGN SYSTEM COMPONENTS
      // Temporarily disabled to ensure 100% legacy UI compatibility.
      // Uncomment these blocks incrementally as the app is refactored.
      // =========================================================================
      
      // -------------------------------------------------------------------------
      // STATUS BAR — dark icons on light background
      // -------------------------------------------------------------------------
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.grey800,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: AppSpacing.pageMargin,
        titleTextStyle: AppTypography.headingXs.copyWith(
          color: AppColors.grey800,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.grey700,
          size: AppSpacing.iconLg,
        ),
        actionsIconTheme: const IconThemeData(
          color: AppColors.grey700,
          size: AppSpacing.iconLg,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        shadowColor: AppColors.transparent,
        surfaceTintColor: AppColors.transparent,
      ),

      // -------------------------------------------------------------------------
      // ELEVATED BUTTON
      // -------------------------------------------------------------------------
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBase,
          foregroundColor: AppColors.alwaysWhite,
          disabledBackgroundColor: AppColors.grey200,
          disabledForegroundColor: AppColors.grey400,
          elevation: 0,
          shadowColor: AppColors.transparent,
          minimumSize: const Size.fromHeight(AppSpacing.touchMd),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: AppTypography.labelLg,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),

      // -------------------------------------------------------------------------
      // OUTLINED BUTTON
      // -------------------------------------------------------------------------
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryBase,
          disabledForegroundColor: AppColors.grey400,
          side: const BorderSide(color: AppColors.primaryBase, width: 1.0),
          minimumSize: const Size.fromHeight(AppSpacing.touchMd),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: AppTypography.labelLg,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ).copyWith(
          side: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return const BorderSide(color: AppColors.grey300, width: 1.0);
            }
            return const BorderSide(color: AppColors.primaryBase, width: 1.0);
          }),
        ),
      ),

      // -------------------------------------------------------------------------
      // TEXT BUTTON
      // -------------------------------------------------------------------------
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryBase,
          disabledForegroundColor: AppColors.grey400,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          minimumSize: const Size(AppSpacing.touchSm, AppSpacing.touchSm),
          textStyle: AppTypography.labelMdSemiBold,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),

      // -------------------------------------------------------------------------
      // INPUT DECORATION — clean, high-contrast borders for POS use
      // -------------------------------------------------------------------------
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,

        // --- Hint & Label styles ---
        hintStyle: AppTypography.bodyMdRegular.copyWith(
          color: AppColors.grey400,
        ),
        labelStyle: AppTypography.bodyMdMedium.copyWith(
          color: AppColors.grey600,
        ),
        floatingLabelStyle: AppTypography.bodySmMedium.copyWith(
          color: AppColors.primaryBase,
        ),
        errorStyle: AppTypography.labelSm.copyWith(
          color: AppColors.errorBase,
        ),
        helperStyle: AppTypography.labelSm.copyWith(
          color: AppColors.grey600,
        ),

        // --- Content padding ---
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md3,
        ),

        // --- Borders ---
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(
            color: AppColors.grey300,
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(
            color: AppColors.grey300,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(
            color: AppColors.primaryBase,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(
            color: AppColors.errorBase,
            width: 1.0,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(
            color: AppColors.errorBase,
            width: 1.5,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(
            color: AppColors.grey200,
            width: 1.0,
          ),
        ),

        // --- Icon colours ---
        prefixIconColor: AppColors.grey600,
        suffixIconColor: AppColors.grey600,

        // --- Make touch target tall enough for POS use ---
        isDense: false,
      ),

      // -------------------------------------------------------------------------
      // CHIP
      // -------------------------------------------------------------------------
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceMuted,
        selectedColor: AppColors.primarySubtle,
        disabledColor: AppColors.grey100,
        labelStyle: AppTypography.labelSm.copyWith(
          color: AppColors.grey700,
        ),
        secondaryLabelStyle: AppTypography.labelSmSemiBold.copyWith(
          color: AppColors.primaryBase,
        ),
        side: const BorderSide(color: AppColors.grey200, width: 1.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        iconTheme: const IconThemeData(
          size: AppSpacing.iconSm,
          color: AppColors.grey700,
        ),
      ),

      // -------------------------------------------------------------------------
      // CARD
      // -------------------------------------------------------------------------
      cardTheme: CardThemeData(
        color: AppColors.surface,
        surfaceTintColor: AppColors.transparent,
        shadowColor: AppColors.grey300.withOpacity(0.5),
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.grey200, width: 1.0),
        ),
      ),

      // -------------------------------------------------------------------------
      // DIVIDER
      // -------------------------------------------------------------------------
      dividerTheme: const DividerThemeData(
        color: AppColors.grey200,
        thickness: 1.0,
        space: 0,
      ),

      // -------------------------------------------------------------------------
      // BOTTOM SHEET
      // -------------------------------------------------------------------------
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: AppColors.transparent,
        elevation: 0,
        modalBackgroundColor: AppColors.surface,
        modalElevation: 0,
        showDragHandle: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl2),
          ),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // -------------------------------------------------------------------------
      // DIALOG
      // -------------------------------------------------------------------------
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: AppColors.transparent,
        elevation: 0,
        titleTextStyle: AppTypography.headingSm.copyWith(
          color: AppColors.grey800,
        ),
        contentTextStyle: AppTypography.bodyMdRegular.copyWith(
          color: AppColors.grey700,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        insetPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xl,
        ),
      ),

      // -------------------------------------------------------------------------
      // SNACK BAR
      // -------------------------------------------------------------------------
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.grey800,
        contentTextStyle: AppTypography.bodySmRegular.copyWith(
          color: AppColors.alwaysWhite,
        ),
        actionTextColor: AppColors.primaryLight,
        elevation: 4,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),

      // -------------------------------------------------------------------------
      // CHECKBOX
      // -------------------------------------------------------------------------
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xs),
        ),
        side: const BorderSide(color: AppColors.grey400, width: 1.5),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColors.grey200;
          }
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryBase;
          }
          return AppColors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.alwaysWhite),
        materialTapTargetSize: MaterialTapTargetSize.padded,
      ),

      // -------------------------------------------------------------------------
      // SWITCH
      // -------------------------------------------------------------------------
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColors.grey300;
          }
          return AppColors.alwaysWhite;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColors.grey100;
          }
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryBase;
          }
          return AppColors.grey300;
        }),
        trackOutlineColor: WidgetStateProperty.all(AppColors.transparent),
      ),

      // -------------------------------------------------------------------------
      // RADIO
      // -------------------------------------------------------------------------
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryBase;
          }
          return AppColors.grey300;
        }),
        materialTapTargetSize: MaterialTapTargetSize.padded,
      ),

      // -------------------------------------------------------------------------
      // BOTTOM NAVIGATION BAR
      // -------------------------------------------------------------------------
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryBase,
        unselectedItemColor: AppColors.grey500,
        selectedLabelStyle: AppTypography.labelXsSemiBold.copyWith(
          color: AppColors.primaryBase,
        ),
        unselectedLabelStyle: AppTypography.labelXs.copyWith(
          color: AppColors.grey500,
        ),
      ),

      // -------------------------------------------------------------------------
      // POPUP MENU
      // -------------------------------------------------------------------------
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.surface,
        surfaceTintColor: AppColors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: const BorderSide(color: AppColors.grey200, width: 1.0),
        ),
        elevation: 4,
        textStyle: AppTypography.bodyMdRegular.copyWith(
          color: AppColors.grey800,
        ),
      ),

      // -------------------------------------------------------------------------
      // PROGRESS INDICATOR
      // -------------------------------------------------------------------------
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primaryBase,
        linearTrackColor: AppColors.grey100,
        circularTrackColor: AppColors.transparent,
      ),

      // -------------------------------------------------------------------------
      // BANNER (MaterialBanner)
      // -------------------------------------------------------------------------
      bannerTheme: const MaterialBannerThemeData(
        backgroundColor: AppColors.primarySubtle,
        contentTextStyle: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.grey800,
        ),
        elevation: 0,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.pageMargin,
          vertical: AppSpacing.sm,
        ),
      ),
      */
    );
  }

  // ---------------------------------------------------------------------------
  // COLOR SCHEME
  // ---------------------------------------------------------------------------

  static ColorScheme get _colorScheme => const ColorScheme.light(
        // Brand
        primary: AppColors.primaryBase,
        onPrimary: AppColors.alwaysWhite,
        primaryContainer: AppColors.primarySubtle,
        onPrimaryContainer: AppColors.primaryDark,

        // Secondary / Blue accent
        secondary: AppColors.secondaryBase,
        onSecondary: AppColors.alwaysWhite,
        secondaryContainer: AppColors.secondaryLight,
        onSecondaryContainer: AppColors.grey800,

        // Tertiary — purple accent used in badges
        tertiary: Color(0xFF6D3CB8),
        onTertiary: AppColors.alwaysWhite,
        tertiaryContainer: Color(0xFFE2D8F1),
        onTertiaryContainer: Color(0xFF6D3CB8),

        // Semantic
        error: AppColors.errorBase,
        onError: AppColors.alwaysWhite,
        errorContainer: AppColors.errorLight,
        onErrorContainer: AppColors.errorBase,

        // Surface & Background
        surface: AppColors.surface,
        onSurface: AppColors.grey800,
        surfaceContainerHighest: AppColors.surfaceContainer,
        onSurfaceVariant: AppColors.grey600,

        // Outline / Border
        outline: AppColors.grey300,
        outlineVariant: AppColors.grey200,

        // Inverse
        inverseSurface: AppColors.grey800,
        onInverseSurface: AppColors.alwaysWhite,
        inversePrimary: AppColors.primaryLight,

        // Scrim / Shadow
        scrim: AppColors.grey900,
        shadow: AppColors.grey900,
      );

  // ---------------------------------------------------------------------------
  // TEXT THEME BUILDER
  // Map AppTypography constants → Material TextTheme roles
  // ---------------------------------------------------------------------------

  static TextTheme _buildTextTheme() {
    return const TextTheme(
      // Display
      displayLarge: AppTypography.displayLg,
      displayMedium: AppTypography.displayMd,
      displaySmall: AppTypography.displaySm,

      // Headline (maps to our Heading scale)
      headlineLarge: AppTypography.headingLg,
      headlineMedium: AppTypography.headingMd,
      headlineSmall: AppTypography.headingSm,

      // Title (maps to our Heading XS and Body Large SemiBold)
      titleLarge: AppTypography.headingXs,
      titleMedium: AppTypography.bodyLgSemiBold,
      titleSmall: AppTypography.bodyMdSemiBold,

      // Body
      bodyLarge: AppTypography.bodyLgRegular,
      bodyMedium: AppTypography.bodyMdRegular,
      bodySmall: AppTypography.bodySmRegular,

      // Label
      labelLarge: AppTypography.labelLg,
      labelMedium: AppTypography.labelMd,
      labelSmall: AppTypography.labelSm,
    );
  }
}
