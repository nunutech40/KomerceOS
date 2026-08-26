import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';

/// Header pada Talent Pool: judul rekomendasi + subjudul.
class TalentPoolHeader extends StatelessWidget {
  const TalentPoolHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rekomendasi Talent untuk Bisnismu',
          style: AppTypography.headingXs.copyWith(color: AppColors.grey800),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Kamu mungkin cocok dengan talent berikut ini!',
          style: AppTypography.bodySmRegular.copyWith(color: AppColors.grey600),
        ),
      ],
    );
  }
}
