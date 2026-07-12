import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/design_system/app_typography.dart';

class AppStatusChip extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;

  const AppStatusChip({
    super.key,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        text,
        style: AppTypography.bodySmSemiBold.copyWith(
          color: textColor,
        ),
      ),
    );
  }
}