import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';

// 1. Enum State yang saling eksklusif (SUDAH BENAR)
enum DsButtonState {
  enabled,
  disabled,
  loading,
}

class DsButton extends StatelessWidget {
  final String text;
  final String? loadingText;
  final TextStyle? loadingTextStyle;
  final VoidCallback onPressed;
  final Widget? leftIcon;
  final bool colorIcon;
  final double height;
  final double borderRadius;
  final TextStyle? textStyle;
  final double? elevation;
  final Color? disabledBackgroundColor;

  final DsButtonState state;

  const DsButton({
    required this.text,
    required this.onPressed,
    this.state = DsButtonState.enabled,
    this.loadingText,
    this.loadingTextStyle,
    this.leftIcon,
    this.colorIcon = true,
    this.height = 50,
    this.borderRadius = AppRadius.lg,
    this.textStyle,
    this.elevation,
    this.disabledBackgroundColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLoading = state == DsButtonState.loading;
    final bool isDisabled = state == DsButtonState.disabled;

    // Gunakan warna dari AppColors secara konsisten
    final Color textColor = isLoading
        ? AppColors.grey600
        : Colors.white; // Ganti Colors.white ke AppColors.white jika ada

    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: (isLoading || isDisabled) ? null : onPressed,
        style: ElevatedButton.styleFrom(
          elevation: elevation,
          backgroundColor: AppColors.primaryBase,
          foregroundColor: Colors.white,
          disabledBackgroundColor: isLoading
              ? Colors.transparent
              : disabledBackgroundColor ?? AppColors.grey350,
          disabledForegroundColor: textColor,
          side: isLoading ? const BorderSide(color: AppColors.grey350) : null,
          shape: RoundedRectangleBorder(
            // PERBAIKAN 1: Gunakan token AppRadius
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading) ...[
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor: AlwaysStoppedAnimation<Color>(textColor),
                ),
              ),
              // PERBAIKAN 2: Gunakan token AppSpacing
              const SizedBox(width: AppSpacing.sm), // Ganti angka 8
            ] else if (leftIcon != null) ...[
              colorIcon
                  ? ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        textColor,
                        BlendMode.srcIn,
                      ),
                      child: leftIcon!,
                    )
                  : leftIcon!,
              // PERBAIKAN 2: Gunakan token AppSpacing
              const SizedBox(width: AppSpacing.sm), // Ganti angka 8
            ],
            Flexible(
              child: Text(
                isLoading && loadingText != null ? loadingText! : text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                // PERBAIKAN 3: Gunakan token AppTypography
                style: (isLoading && loadingTextStyle != null
                        ? loadingTextStyle!
                        : textStyle ?? AppTypography.headingXxs)
                    .copyWith(color: textColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
