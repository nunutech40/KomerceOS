import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import 'package:komtim_partner/features/superapp/features/myapp/view/my_app_page.dart';

class HomeVerificationBottomSheet extends StatelessWidget {
  const HomeVerificationBottomSheet({super.key});

  static Future<T?> show<T>({
    required BuildContext context,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.transparent,
      builder: (_) => const HomeVerificationBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(
          left: AppSpacing.pageMargin2xs,
          right: AppSpacing.pageMargin2xs,
        ),
        decoration: const BoxDecoration(
          color: AppColors.bgPopup,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppRadius.xl),
            topRight: Radius.circular(AppRadius.xl),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.insetLg,
              AppSpacing.xl,
              AppSpacing.insetLg,
              AppSpacing.insetLg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // --- Close Button ---
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close,
                          size: 20, color: AppColors.grey800),
                    ),
                  ),
                ),

                // --- Title ---
                Text(
                  'Ada Produk yang\nMenunggu Verifikasi',
                  textAlign: TextAlign.center,
                  style: AppTypography.headingSm.copyWith(
                    color: AppColors.grey900,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                // --- Description ---
                Text(
                  'Kami menemukan beberapa produk yang belum memiliki status verifikasi email. Segera selesaikan verifikasi untuk melanjutkan penggunaan produk tersebut.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmRegular.copyWith(
                    color: AppColors.grey700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // --- Illustration ---
                SvgPicture.asset(
                  'assets/images/superapp/auth/account_not_active.svg',
                  width: 200,
                  height: 200,
                ),
                const SizedBox(height: AppSpacing.xl),

                // --- Secondary text button (Lewati) ---
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.errorBase,
                    textStyle: AppTypography.bodyMdMedium,
                    minimumSize:
                        const Size(double.infinity, AppSpacing.touchSm),
                  ),
                  child: const Text('Lewati'),
                ),
                const SizedBox(height: AppSpacing.sm),

                // --- Primary action button ---
                DsButton(
                  text: 'Verifikasi Sekarang',
                  onPressed: () {
                    Navigator.pop(context); // close bottom sheet
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MyAppPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
