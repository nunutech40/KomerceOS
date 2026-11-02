import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:komtim_partner/features/superapp/features/kyc/flow/kyc_liveness_flow.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';

/// # KycIdentityBottomSheet
///
/// Bottom sheet pengantar untuk memulai proses pengunggahan identitas KYC.
///
/// ### 📌 Kapan Digunakan:
/// - Dipicu setelah pembayaran verifikasi KYC berhasil (status API: 5 / Paid Verification)
///   atau dari tombol pengajuan verifikasi identitas.
/// - Menjelaskan kepada user bahwa langkah berikutnya adalah memverifikasi data identitas (KTP).
///
/// ### 🔄 Alur & Posisi dalam User Journey:
/// 1. Pembayaran biaya verifikasi KYC 25k berhasil / user berstatus 5 (Paid).
/// 2. Modal `KycIdentityBottomSheet` ditampilkan untuk mengundang user memulai proses.
/// 3. User menekan tombol "Ajukan Verifikasi" (`onSubmit`) -> Navigasi ke halaman form input KTP / panduan KTP.
/// 4. User menekan "Kembali" (`onBack`) -> Bottom sheet tertutup.
///
/// ### 💻 Contoh Penggunaan:
/// ```dart
/// await KycIdentityBottomSheet.show(
///   context,
///   onSubmit: () {
///     Navigator.pop(context); // Tutup bottom sheet
///     // Navigasi ke alur foto/input KTP
///     Navigator.pushNamed(context, '/kyc/ktp-guide');
///   },
///   onBack: () {
///     Navigator.pop(context);
///   },
/// );
/// ```
///
/// ### ⚙️ Parameter:
/// - [onSubmit] : Callback saat tombol "Ajukan Verifikasi" ditekan.
/// - [onBack] : Callback saat tombol "Kembali" atau tombol close (X) ditekan. Defaults ke `Navigator.pop(context)`.
///
/// ### ⚠️ Catatan Penting:
/// - Menggunakan asset ilustrasi `assets/images/superapp/kyc/il_kyc_identity.svg`.
class KycIdentityBottomSheet extends StatelessWidget {
  /// Callback saat tombol "Ajukan Verifikasi" ditekan.
  final VoidCallback? onSubmit;

  /// Callback saat tombol "Kembali" atau tombol close (X) ditekan.
  /// Defaults ke [Navigator.pop].
  final VoidCallback? onBack;

  const KycIdentityBottomSheet({super.key, this.onSubmit, this.onBack});

  // ---------------------------------------------------------------------------
  // Static factory
  // ---------------------------------------------------------------------------

  /// Helper statis untuk menampilkan bottom sheet identitas.
  ///
  /// ```dart
  /// KycIdentityBottomSheet.show(
  ///   context,
  ///   onSubmit: () => navigateToKycForm(),
  /// );
  /// ```
  static Future<T?> show<T>(
    BuildContext context, {
    VoidCallback? onSubmit,
    VoidCallback? onBack,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black54,
      builder: (sheetContext) => KycIdentityBottomSheet(
        onSubmit: onSubmit ??
            () {
              Navigator.pop(sheetContext);
              Future<void>.delayed(const Duration(milliseconds: 250), () {
                if (context.mounted) KycLivenessFlow.start(context);
              });
            },
        onBack: onBack ?? () => Navigator.pop(context),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final effectiveOnBack = onBack ?? () => Navigator.pop(context);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pageMargin2xs,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFFDCDCDC),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppRadius.pill),
            topRight: Radius.circular(AppRadius.pill),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.insetLg,
              AppSpacing.lg,
              AppSpacing.insetLg,
              AppSpacing.insetLg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Title row + close button
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          'Verifikasi Identitas Kamu',
                          textAlign: TextAlign.center,
                          style: AppTypography.headingMd.copyWith(
                            color: AppColors.black0A0A,
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: effectiveOnBack,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 18,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),

                // ── Description
                Text(
                  'Verifikasi diperlukan untuk memvalidasi\nkeaslian akun kamu.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMdRegular.copyWith(
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // ── Illustration
                SvgPicture.asset(
                  'assets/images/superapp/kyc/ic_verify_identity.svg',
                  height: 200,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: AppSpacing.xl),

                // ── Kembali button
                TextButton(
                  onPressed: effectiveOnBack,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryBase,
                    textStyle: AppTypography.bodyMdSemiBold,
                    minimumSize: const Size(
                      double.infinity,
                      AppSpacing.touchSm,
                    ),
                  ),
                  child: const Text('Kembali'),
                ),
                const SizedBox(height: AppSpacing.sm),

                // ── Ajukan Verifikasi button
                DsButton(
                  text: 'Ajukan Verifikasi',
                  onPressed: onSubmit ?? () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
