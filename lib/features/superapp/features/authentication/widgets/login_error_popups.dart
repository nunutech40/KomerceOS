import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';

class LoginErrorPopups {
  static void showAccountNotActive(
      BuildContext context, VoidCallback onHubungiAdmin) {
    DsBottomSheet.show(
      context: context,
      title: 'Akun Tidak Aktif',
      description:
          'Akun kamu sedang tidak aktif. Hubungi admin atau layanan terkait untuk bantuan lebih lanjut.',
      image: SvgPicture.asset(
        'assets/images/superapp/auth/account_not_active.svg',
        width: 200,
        height: 200,
      ),
      primaryButtonText: 'Hubungi Admin',
      onPrimaryPressed: () {
        Navigator.pop(context);
        onHubungiAdmin();
      },
      secondaryButtonText: 'Kembali',
      onSecondaryPressed: () {
        Navigator.pop(context);
      },
    );
  }

  static void showPenalty(BuildContext context) {
    DsBottomSheet.show(
      context: context,
      title: 'Terlalu Banyak Percobaan Login',
      description:
          'Terlalu banyak percobaan login. Silakan coba lagi beberapa saat nanti.',
      image: SvgPicture.asset(
        'assets/images/superapp/auth/attempt_count_login.svg',
        width: 200,
        height: 200,
      ),
      primaryButtonText: 'Coba Lagi',
      onPrimaryPressed: () {
        Navigator.pop(context);
      },
      secondaryButtonText: 'Kembali',
      onSecondaryPressed: () {
        Navigator.pop(context);
      },
    );
  }

  static void showServerError(BuildContext context) {
    DsBottomSheet.show(
      context: context,
      title: 'Server Error',
      description:
          'Terjadi kendala pada sistem. Silakan coba kembali beberapa saat lagi.',
      image: SvgPicture.asset(
        'assets/images/superapp/auth/server_error.svg',
        width: 200,
        height: 200,
      ),
      primaryButtonText: 'Coba Lagi',
      onPrimaryPressed: () {
        Navigator.pop(context);
      },
      secondaryButtonText: 'Kembali',
      onSecondaryPressed: () {
        Navigator.pop(context);
      },
    );
  }

  static void showFailedAttempt(
      BuildContext context, int attemptsLeft, VoidCallback onResetPassword) {
    final bool isBlocked = attemptsLeft <= 0;

    DsBottomSheet.show(
      context: context,
      title: 'Gagal Login',
      description: isBlocked
          ? 'Anda telah gagal login sebanyak 3 kali. Silakan coba kembali dalam 24 jam ke depan atau reset password'
          : 'Periksa kembali email dan password yang kamu masukkan. Tersisa $attemptsLeft kali percobaan.',
      image: SvgPicture.asset(
        'assets/images/superapp/auth/attempt_count_login.svg',
        width: 200,
        height: 200,
      ),
      primaryButtonText: isBlocked ? 'Reset Password' : 'Coba Lagi',
      onPrimaryPressed: () {
        Navigator.pop(context);
        if (isBlocked) {
          onResetPassword();
        }
      },
      secondaryButtonText: 'Kembali',
      onSecondaryPressed: () {
        Navigator.pop(context);
      },
    );
  }
}
