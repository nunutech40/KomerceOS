import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/design_system/app_colors.dart';
import 'package:komtim_partner/common/global/design_system/app_radius.dart';
import 'package:komtim_partner/common/global/design_system/app_spacing.dart';

class DsSquareIconButton extends StatelessWidget {
  final IconData? icon;
  final Widget? customIcon;
  final VoidCallback? onTap;
  final double size;
  final bool isActive;

  const DsSquareIconButton({
    super.key,
    this.icon,
    this.customIcon,
    this.onTap,
    this.size = 44,
    this.isActive = false,
  }) : assert(
          icon != null || customIcon != null,
          'Harus menyertakan icon atau customIcon',
        );

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;
    final borderRadius = BorderRadius.circular(AppRadius.lg);

    final backgroundColor = isActive
        ? AppColors.primaryBase
        : AppColors.alwaysWhite;

    final borderColor = isActive
        ? AppColors.primaryBase
        : AppColors.grey200;

    final iconColor = !isEnabled
        ? AppColors.grey400
        : isActive
            ? AppColors.alwaysWhite
            : AppColors.grey900;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Ink(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: borderRadius,
            border: Border.all(
              color: borderColor,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.alwaysBlack.withValues(alpha: 0.04), // Menggunakan AppColors
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: _buildIcon(iconColor),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(Color color) {
    if (icon != null) {
      return Icon(
        icon,
        size: AppSpacing.iconMd,
        color: color,
      );
    }

    return ColorFiltered(
      colorFilter: ColorFilter.mode(
        color,
        BlendMode.srcIn,
      ),
      child: customIcon!,
    );
  }
}