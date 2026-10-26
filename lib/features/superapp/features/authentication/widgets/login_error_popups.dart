import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginErrorPopups {
  static const teamInternalErrorCode = 'ERR_ROLE_TEAM_INTERNAL_BLOCKED';

  static bool isTeamInternalBlocked(String message) {
    final error = message.toLowerCase();
    return error.contains(teamInternalErrorCode.toLowerCase()) ||
        error.contains('role team internal tidak memiliki akses') ||
        error.contains('tidak memiliki akses untuk masuk ke aplikasi');
  }

  static bool isOtherRoleError(String message) {
    final error = message.toLowerCase();
    return error.contains('user is non partner') ||
        error.contains('user is not partner') ||
        error.contains('non partner') ||
        error.contains('non-partner') ||
        error.contains('talent internal') ||
        error.contains('internal talent');
  }

  static void showTeamInternalBlocked(BuildContext context,
      {VoidCallback? onClose}) {
    DsBottomSheet.show(
      context: context,
      title: 'Akses Tidak Diizinkan',
      description:
          'Akun Anda dengan role Team Internal tidak memiliki akses untuk masuk ke aplikasi Komerce OS demi alasan keamanan.',
      image: SvgPicture.asset(
        'assets/images/superapp/auth/account_not_active.svg',
        height: 200,
      ),
      primaryButtonText: 'Kembali',
      onPrimaryPressed: () {
        Navigator.pop(context);
        onClose?.call();
      },
      onClosePressed: () {
        Navigator.pop(context);
        onClose?.call();
      },
      isDismissible: true,
    );
  }

  static void showOtherRole(BuildContext context, {VoidCallback? onClose}) {
    DsBottomSheet.show(
      context: context,
      title: 'Akun Terdaftar di Peran Lain',
      description:
          'Akun kamu terdaftar di peran lain.\nTenang, kamu bisa menanyakan hal ini\nke live chat Customer Support.',
      image: SvgPicture.asset(
        'assets/images/superapp/auth/account_not_active.svg',
        height: 200,
      ),
      secondaryButtonText: 'Kembali',
      onSecondaryPressed: () {
        Navigator.pop(context);
        onClose?.call();
      },
      onClosePressed: () {
        Navigator.pop(context);
        onClose?.call();
      },
      primaryButtonText: 'Hubungi Customer Support',
      onPrimaryPressed: () async {
        Navigator.pop(context);
        onClose?.call();
        final url = Uri.parse('https://partner.komerce.id/');
        if (!await launchUrl(url)) {
          debugPrint('Could not launch $url');
        }
      },
      isDismissible: true,
    );
  }

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
