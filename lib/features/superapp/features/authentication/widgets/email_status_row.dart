import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';

import 'email_check_status.dart';

class EmailStatusRow extends StatelessWidget {
  final EmailCheckStatus status;

  const EmailStatusRow({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      EmailCheckStatus.loading => const _StatusItem(
          icon: _Spinner(),
          text: 'Memverifikasi email...',
          color: AppColors.grey600,
        ),
      EmailCheckStatus.found => const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StatusItem(
              icon: Icon(
                Icons.check_circle_rounded,
                size: 16,
                color: AppColors.successBase,
              ),
              text: 'Email berhasil ditemukan',
              color: AppColors.successBase,
            ),
          ],
        ),
      EmailCheckStatus.unregistered => _StatusItem(
          icon: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.bgLight,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.errorBase, width: 1.5),
            ),
            child: const Center(
              child: Icon(
                Icons.close_rounded,
                size: 10,
                color: AppColors.errorBase,
              ),
            ),
          ),
          text: 'Email belum terdaftar',
          color: AppColors.errorBase,
        ),
      _ => const SizedBox.shrink(),
    };
  }
}

class _StatusItem extends StatelessWidget {
  final Widget icon;
  final String text;
  final Color color;

  const _StatusItem({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        icon,
        const SizedBox(width: AppSpacing.xs),
        Text(
          text,
          style: AppTypography.bodySmRegular.copyWith(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _Spinner extends StatelessWidget {
  final Color color;

  const _Spinner({this.color = AppColors.grey600});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 14,
      height: 14,
      child: CircularProgressIndicator(
        strokeWidth: 1.5,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}
