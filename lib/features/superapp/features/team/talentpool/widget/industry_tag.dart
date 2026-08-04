import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';

/// Tag industri talent (mis. "Fashion") dengan latar biru muda.
class IndustryTag extends StatelessWidget {
  final String label;

  const IndustryTag({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: AppColors.secondaryLight,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        label,
        style: AppTypography.labelXsMedium.copyWith(
          color: AppColors.secondaryBase,
        ),
      ),
    );
  }
}

/// Badge "+N" untuk menunjukkan sisa industri yang tidak ditampilkan.
class IndustryMoreTag extends StatelessWidget {
  final int count;

  const IndustryMoreTag({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        '+ $count',
        style: AppTypography.labelXsMedium.copyWith(
          color: AppColors.grey700,
        ),
      ),
    );
  }
}
