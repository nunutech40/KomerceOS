import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';

class DsButtonSelected extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final double? borderRadius;
  final double? height;

  const DsButtonSelected({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.borderRadius,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final double radius = borderRadius ?? 99;
    final double customHeight = height ?? 38.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        child: Ink(
          height: customHeight,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryBase
                : AppColors.alwaysWhite,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              width: 1,
              color: isSelected
                  ? Colors.transparent
                  : AppColors.grey200,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: AppTypography.bodyMdSemiBold.copyWith(
                color: isSelected
                    ? AppColors.alwaysWhite
                    : AppColors.alwaysBlack,
              ),
            ),
          ),
        ),
      ),
    );
  }
}