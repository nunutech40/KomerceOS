import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import 'package:komtim_partner/common/time_convert.dart';

// ignore: must_be_immutable
class CardNoAttendance extends StatelessWidget {
  String? name;
  String? date;
  final int? length;
  final int index;
  CardNoAttendance(
      {super.key,
      this.name,
      this.date,
      required this.length,
      required this.index});

  @override
  Widget build(BuildContext context) {
    final isLast = length == (index + 1);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.alwaysWhite,
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(
                  color: AppColors.grey200,
                  width: 1,
                ),
              ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name ?? "",
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: AppTypography.bodyMdSemiBold.copyWith(
              color: AppColors.grey800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            dateConvertWithT(date),
            style: AppTypography.bodySmRegular.copyWith(
              color: AppColors.grey600,
            ),
          ),
        ],
      ),
    );
  }
}
