import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/design_system/app_colors.dart';
import 'package:komtim_partner/common/global/design_system/app_typography.dart';

class AppTabLayout extends StatelessWidget {
  final List<Widget> tabs; 
  final TabController? controller;
  final ValueChanged<int>? onTap;

  const AppTabLayout({
    super.key,
    required this.tabs,
    this.controller,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.all(6), // TODO: Ganti ke AppSpacing.xs jika ada
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2), // TODO: Sesuai aturan, ganti ke AppColors.grey100 atau sejenisnya
        borderRadius: BorderRadius.circular(16), // TODO: Ganti ke AppRadius.md jika ada
      ),
      child: TabBar(
        controller: controller,
        onTap: onTap,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: AppColors.primaryBase, // Menggunakan token warna utama proyek Anda
          borderRadius: BorderRadius.circular(12), // TODO: Ganti ke AppRadius.sm jika ada
        ),
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF6E6E6E), // TODO: Ganti ke AppColors.textSecondary jika ada
        labelStyle: AppTypography.bodyMdSemiBold,
        unselectedLabelStyle: AppTypography.bodyMdMedium,
        tabs: tabs,
      ),
    );
  }
}