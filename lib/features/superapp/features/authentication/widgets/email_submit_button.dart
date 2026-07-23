import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';

import 'email_check_status.dart';

class EmailSubmitButton extends StatelessWidget {
  final EmailCheckStatus status;
  final bool isActive;
  final bool isLoading;
  final VoidCallback onPressed;

  const EmailSubmitButton({
    super.key,
    required this.status,
    required this.isActive,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Default (idle atau sedang check awal)
    String text = 'Lanjutkan';
    String loadingText = 'Memverifikasi email...';
    bool forceLoading = isLoading;

    Widget? leftIcon;

    if (status == EmailCheckStatus.found) {
      // Jika found, tombol berubah seolah-olah sedang loading memuat halaman
      forceLoading = true;
      loadingText = 'Memuat halaman login...';
    } else if (status == EmailCheckStatus.unregistered) {
      // Jika unregistered, tombol berubah menjadi outlined "Pilih Produk & Daftar"
      text = 'Pilih Produk & Daftar';

      leftIcon = SvgPicture.asset(
        'assets/images/superapp/auth/arrow_up_right.svg',
        width: 20,
        height: 20,
      );
    }

    return DsButton(
      key: const Key('email_check_submit_button'),
      text: text,
      loadingText: loadingText,
      state: forceLoading
          ? DsButtonState.loading
          : (isActive ? DsButtonState.enabled : DsButtonState.disabled),
      leftIcon: leftIcon,
      onPressed: onPressed,
    );
  }
}
