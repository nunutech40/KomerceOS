import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/design_system/app_colors.dart';

import '../../../common/styles.dart';

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
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 12.0),
        child: Center(
          child: Text(
            rating,
            textAlign: TextAlign.center,
            style: AppTypography.semiBold14,
          ),
        ),
      ),
    );
  }
}
