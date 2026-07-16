import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';

class DsRadioButton extends StatelessWidget {
  final String title;
  final Widget icon;
  final bool selected;
  final bool isDisabled;
  final VoidCallback onTap;

  const DsRadioButton({
    super.key,
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    const Color activeColor = AppColors.primaryBase;
    const Color inactiveBorderColor = AppColors.grey300;
    final Color activeBgColor = activeColor.withValues(alpha: 0.05);
    const Color disabledBgColor = AppColors.grey100;
    const Color disabledTextColor = AppColors.grey400;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: isDisabled
                ? disabledBgColor
                : (selected ? activeBgColor : Colors.transparent),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: isDisabled
                  ? inactiveBorderColor
                  : (selected ? activeColor : inactiveBorderColor),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              isDisabled ? Opacity(opacity: 0.5, child: icon) : icon,
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.bodyMdMedium.copyWith(
                    color:
                        isDisabled ? disabledTextColor : AppColors.alwaysBlack,
                  ),
                ),
              ),
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: isDisabled
                    ? AppColors.grey400
                    : (selected ? activeColor : AppColors.grey400),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
