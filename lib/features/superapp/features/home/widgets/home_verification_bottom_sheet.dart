import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import 'package:komtim_partner/features/superapp/features/myapp/view/my_app_page.dart';

class HomeVerificationBottomSheet {
  const HomeVerificationBottomSheet._();

  static Future<T?> show<T>({
    required BuildContext context,
  }) {
    return DsBottomSheet.show<T>(
      context: context,
      title: 'Ada Produk yang\nMenunggu Verifikasi',
      description:
          'Kami menemukan beberapa produk yang belum memiliki status verifikasi email. Segera selesaikan verifikasi untuk melanjutkan penggunaan produk tersebut.',
      image: SvgPicture.asset(
        'assets/images/superapp/auth/account_not_active.svg',
        width: 200,
        height: 200,
      ),
      secondaryButtonText: 'Lewati',
      onSecondaryPressed: () => Navigator.pop(context),
      secondaryButtonColor: AppColors.errorBase,
      primaryButtonText: 'Verifikasi Sekarang',
      onPrimaryPressed: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const MyAppPage(),
          ),
        );
      },
    );
  }
}
