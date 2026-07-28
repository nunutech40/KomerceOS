import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';

class NoInternetErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const NoInternetErrorView({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageMarginLg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/superapp/auth/not_have_internet.png',
            width: 240,
            height: 240,
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Gagal mengambil data',
            style: AppTypography.headingMd.copyWith(color: AppColors.grey800),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Data tidak dapat tampil, cek kembali internet kamu',
            style:
                AppTypography.bodyMdRegular.copyWith(color: AppColors.grey600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl2),
          SizedBox(
            width: 140,
            child: DsButton(
              text: 'Coba Lagi',
              onPressed: onRetry,
            ),
          ),
        ],
      ),
    );
  }
}
