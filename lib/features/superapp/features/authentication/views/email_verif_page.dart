import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';

// -----------------------------------------------------------------------------
// EmailVerifPage (superapp)
//
// Halaman penuh "Verifikasi Email".
// Ditampilkan setelah user tap "Kirim Ulang" pada bottom sheet unverified
// di EmailCheckPage.
//
// Konten:
//   - Ilustrasi verify_email.svg
//   - Judul + deskripsi
//   - Tombol "Buka Email" → launch email client
// -----------------------------------------------------------------------------

class EmailVerifPage extends StatelessWidget {
  final String email;

  const EmailVerifPage({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pageMarginLg,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- Ilustrasi ---
              SvgPicture.asset(
                'assets/images/superapp/auth/verify_email.svg',
                width: 200,
                height: 300,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: AppSpacing.xl),

              // --- Judul ---
              Text(
                'Verifikasi Email',
                style: AppTypography.headingMd.copyWith(
                  color: AppColors.grey800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),

              // --- Deskripsi ---
              Text(
                'Selesaikan ini untuk mengakses akunmu. Cek email kamu dan klik link verifikasi untuk mengaktifkan akun.',
                style: AppTypography.bodyMdRegular.copyWith(
                  color: AppColors.grey600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl2),

              // --- Tombol Buka Email ---
              DsButton(
                key: const Key('verif_open_email_button'),
                text: '→ Buka Email',
                onPressed: () {
                  // TODO: Launch email client
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
