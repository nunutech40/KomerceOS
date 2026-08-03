import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';

class DsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;

  const DsAppBar({
    super.key,
    required this.title,
    this.onBackPressed,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.alwaysWhite,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleSpacing: AppSpacing.sm,
      leadingWidth:
          70, // Adjust width to accommodate the circular button padding
      leading: Padding(
        padding:
            const EdgeInsets.only(left: AppSpacing.md, top: 6.0, bottom: 6.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(100),
          onTap: onBackPressed ?? () => Navigator.of(context).pop(),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(
                    0xFFF3F4F6), // Light grey border similar to AppColors.grey200
                width: 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.chevron_left_rounded,
              color: AppColors.alwaysBlack,
              size: 28,
            ),
          ),
        ),
      ),
      title: Text(
        title,
        style: AppTypography.bodyLgBold.copyWith(
          color: AppColors.alwaysBlack,
        ),
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
