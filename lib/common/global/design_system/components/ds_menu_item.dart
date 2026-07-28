import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/design_system/app_colors.dart';
import 'package:komtim_partner/common/global/design_system/app_typography.dart';
import 'package:komtim_partner/common/global/design_system/app_spacing.dart';
import 'package:komtim_partner/common/global/design_system/app_radius.dart';

class DsMenuItem extends StatelessWidget {
  /// Teks judul menu yang bisa diganti-ganti oleh parent
  final String title;
  
  /// Widget Icon yang sangat fleksibel (bisa dimasukkan Icon bawaan Flutter atau SvgPicture)
  final Widget icon;
  
  /// Callback murni ketika baris menu ditekan (Event naik ke atas)
  final VoidCallback onTap;

  /// Background color untuk menu item (default: AppColors.surface)
  final Color backgroundColor;

  /// Padding untuk menu item
  final EdgeInsetsGeometry padding;

  const DsMenuItem({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.backgroundColor = AppColors.surface,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md2),
  });

  @override
  Widget build(BuildContext context) {
    // Menggunakan Material + InkWell agar memiliki efek ripple yang rapi saat di-tap
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Padding(
          padding: padding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primaryBase,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Center(
                  child: IconTheme(
                    data: const IconThemeData(
                      color: AppColors.alwaysWhite,
                      size: AppSpacing.iconMd,
                    ),
                    child: icon,
                  ),
                ),
              ),
              
              const SizedBox(height: AppSpacing.sm),
              
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTypography.bodySmSemiBold.copyWith(
                  color: AppColors.black,
                ),
              ),
              
            ],
          ),
        ),
      ),
    );
  }
}