import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';

class DsChipButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const DsChipButton({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(99),
        onTap: onTap,
        child: Ink(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryBase
                : AppColors.alwaysWhite,
            borderRadius: BorderRadius.circular(99),
            border: Border.all(
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
              style: AppTypography.bodyMdMedium.copyWith(
                color: isSelected
                    ? AppColors.alwaysWhite
                    : AppColors.grey700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}