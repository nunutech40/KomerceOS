import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';

class AccountActionTile extends StatelessWidget {
  const AccountActionTile({
    super.key,
    required this.icon,
    this.leadingWidget,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final Widget? leadingWidget;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSpacing.touchXl),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: leadingWidget ??
                      Icon(icon,
                          color: AppColors.alwaysBlack,
                          size: AppSpacing.iconLg),
                ),
                const SizedBox(width: AppSpacing.md3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: AppTypography.bodyMdMedium
                              .copyWith(color: AppColors.alwaysBlack)),
                      const SizedBox(height: AppSpacing.xs),
                      Text(subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodySmRegular
                              .copyWith(color: AppColors.grey600)),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Icon(
                  Icons.chevron_right,
                  size: AppSpacing.iconMd,
                  color:
                      onTap == null ? AppColors.grey400 : AppColors.alwaysBlack,
                ),
              ],
            ),
          ),
        ),
      );
}
