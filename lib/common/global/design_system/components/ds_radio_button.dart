import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';

class DsRadioButton extends StatelessWidget {
  final String title;
  final Widget icon;
  final bool selected;
  final VoidCallback onTap;

  const DsRadioButton({
    super.key,
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color activeColor = AppColors.primaryBase;
    final Color inactiveBorderColor = AppColors.grey300;
    final Color activeBgColor = activeColor.withOpacity(.05);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: selected ? activeBgColor : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: selected ? activeColor : inactiveBorderColor,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              icon,
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.bodyMdMedium.copyWith(
                    color: AppColors.alwaysBlack,
                  ),
                ),
              ),
              Icon(
                selected 
                    ? Icons.radio_button_checked 
                    : Icons.radio_button_off,
                color: selected ? activeColor : AppColors.grey400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}