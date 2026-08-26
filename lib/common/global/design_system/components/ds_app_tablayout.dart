import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/design_system/app_colors.dart';
import 'package:komtim_partner/common/global/design_system/app_radius.dart';
import 'package:komtim_partner/common/global/design_system/app_typography.dart';

enum AppTabLayoutVariant {
  primary,
  elevated,
}

class AppTabLayout extends StatelessWidget {
  final List<Widget> tabs;
  final TabController? controller;
  final ValueChanged<int>? onTap;
  final AppTabLayoutVariant variant;

  const AppTabLayout({
    super.key,
    required this.tabs,
    this.controller,
    this.onTap,
    this.variant = AppTabLayoutVariant.primary,
  });

  @override
  Widget build(BuildContext context) {
    final isElevated = variant == AppTabLayoutVariant.elevated;

    return Container(
      height: 50,
      padding: const EdgeInsets.all(6), // TODO: Ganti ke AppSpacing.xs jika ada
      decoration: BoxDecoration(
        color: isElevated ? AppColors.grayF5F5 : const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(AppRadius.md2),
        border: Border.all(color: AppColors.grayF5F5),
      ),
      child: TabBar(
        controller: controller,
        onTap: onTap,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: isElevated ? AppColors.alwaysWhite : AppColors.primaryBase,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: isElevated
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        labelColor: isElevated ? AppColors.grey900 : AppColors.alwaysWhite,
        unselectedLabelColor: AppColors.grey700,
        labelStyle: AppTypography.bodyMdSemiBold,
        unselectedLabelStyle: AppTypography.bodyMdMedium,
        tabs: tabs,
      ),
    );
  }
}
