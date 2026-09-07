import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';

class SmallRating extends StatelessWidget {
  final String rating;
  const SmallRating({
    super.key,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.alwaysWhite,
        borderRadius: BorderRadius.circular(AppRadius.md3),
      ),
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md3,
      ),
      alignment: Alignment.center,
      child: Text(
        rating,
        textAlign: TextAlign.center,
        style: AppTypography.bodyMdSemiBold.copyWith(color: AppColors.grey800),
      ),
    );
  }
}
