import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:komtim_partner/common/global/design_system/app_colors.dart';
import 'package:komtim_partner/common/global/design_system/app_radius.dart';

class DsViewToggle extends StatelessWidget {
  final bool isGridView;
  final ValueChanged<bool> onChanged;

  const DsViewToggle({
    super.key,
    required this.isGridView,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.bgLight,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Segment Grid View
          _ToggleSegment(
            iconPath: 'assets/images/superapp/ic_layout_grid.svg',
            isActive: isGridView,
            onTap: () => onChanged(true),
          ),
          // Segment List View
          _ToggleSegment(
            iconPath: 'assets/images/superapp/ic_layout_list.svg',
            isActive: !isGridView,
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }
}

class _ToggleSegment extends StatelessWidget {
  final String iconPath;
  final bool isActive;
  final VoidCallback onTap;

  const _ToggleSegment({
    required this.iconPath,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(AppRadius.md3);

    // Warna icon: Black saat aktif, Grey saat tidak aktif
    final Color iconColor =
        isActive ? AppColors.alwaysBlack : AppColors.grey600;

    // Warna background segmen (Sesuai contoh UI)
    final Color backgroundColor =
        isActive ? AppColors.alwaysWhite : AppColors.transparent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        child: Ink(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: borderRadius,
            border: isActive
                ? Border.all(color: AppColors.grey300)
                : Border.all(color: Colors.transparent),
          ),
          child: Center(
            child: SvgPicture.asset(
              iconPath,
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(
                iconColor,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
