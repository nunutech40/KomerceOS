import 'dart:ui';
import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_radius.dart';
import '../app_spacing.dart';
import '../app_typography.dart';
import 'ds_button.dart';

class DsBottomSheet extends StatelessWidget {
  final String title;
  final String description;
  final Widget? image;
  final String primaryButtonText;
  final VoidCallback onPrimaryPressed;
  final DsButtonState primaryButtonState;
  final String? secondaryButtonText;
  final VoidCallback? onSecondaryPressed;
  
  // 1. Tambahkan parameter opsi warna untuk tombol sekunder (default ke warna netral)
  final Color? secondaryButtonColor;
  
  // 2. Tambahkan callback eksplisit untuk tombol close
  final VoidCallback? onClosePressed;
  
  final bool isDismissible;

  const DsBottomSheet({
    super.key,
    required this.title,
    required this.description,
    required this.primaryButtonText,
    required this.onPrimaryPressed,
    this.primaryButtonState = DsButtonState.enabled,
    this.image,
    this.secondaryButtonText,
    this.onSecondaryPressed,
    this.secondaryButtonColor,
    this.onClosePressed, // Inject callback
    this.isDismissible = true,
  });

  // ---------------------------------------------------------------------------
  // Static helper
  // ---------------------------------------------------------------------------

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required String description,
    required String primaryButtonText,
    required VoidCallback onPrimaryPressed,
    DsButtonState primaryButtonState = DsButtonState.enabled,
    Widget? image,
    String? secondaryButtonText,
    VoidCallback? onSecondaryPressed,
    Color? secondaryButtonColor,
    VoidCallback? onClosePressed,
    bool isDismissible = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: isDismissible,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.transparent,
      builder: (_) => DsBottomSheet(
        title: title,
        description: description,
        primaryButtonText: primaryButtonText,
        onPrimaryPressed: onPrimaryPressed,
        primaryButtonState: primaryButtonState,
        image: image,
        secondaryButtonText: secondaryButtonText,
        onSecondaryPressed: onSecondaryPressed,
        secondaryButtonColor: secondaryButtonColor,
        // Default behavior jika tidak ada custom logic dari parent
        onClosePressed: onClosePressed ?? () => Navigator.pop(context), 
        isDismissible: isDismissible,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(
          left: AppSpacing.pageMargin2xs,
          right: AppSpacing.pageMargin2xs,
        ),
        decoration: const BoxDecoration(
          color: AppColors.bgPopup,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppRadius.xl),
            topRight: Radius.circular(AppRadius.xl),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.insetLg,
              AppSpacing.xl,
              AppSpacing.insetLg,
              AppSpacing.insetLg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: AppTypography.headingMd.copyWith(
                          color: AppColors.grey900,
                        ),
                      ),
                    ),
                    if (isDismissible)
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          // Gunakan callback yang di-inject
                          onTap: onClosePressed, 
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.xs),
                            decoration: const BoxDecoration(
                              color: AppColors.bgLight,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close,
                                size: 30, color: AppColors.grey700),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),

                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMdRegular.copyWith(
                    color: AppColors.grey700,
                  ),
                ),

                if (image != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  image!,
                ],

                const SizedBox(height: AppSpacing.xl),

                if (secondaryButtonText != null) ...[
                  TextButton(
                    onPressed: onSecondaryPressed,
                    style: TextButton.styleFrom(
                      // Gunakan warna custom, default ke grey/primary jika null
                      foregroundColor: secondaryButtonColor ?? AppColors.grey600, 
                      textStyle: AppTypography.bodyMdMedium,
                      minimumSize: const Size(double.infinity, AppSpacing.touchSm),
                    ),
                    child: Text(secondaryButtonText!),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],

                DsButton(
                  text: primaryButtonText,
                  onPressed: onPrimaryPressed,
                  state: primaryButtonState,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}