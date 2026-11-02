import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';

/// # KycLivenessBottomSheet
///
/// Bottom sheet instruksi panduan sebelum memulai proses verifikasi liveness (deteksi wajah hidup).
///
/// ### 📌 Kapan Digunakan:
/// - Dipicu setelah user berhasil mengambil foto KTP dan selfie bersama KTP.
/// - Memberikan edukasi kepada user tentang instruksi yang akan diminta saat pemindaian wajah:
///   - Menghadap lurus ke arah kamera depan.
///   - Memastikan pencahayaan ruangan cukup terang.
///   - Tidak menggunakan aksesoris penutup wajah (masker, kacamata hitam, topi).
///   - Bersiap mengikuti instruksi gerakan (seperti mengedipkan mata atau menoleh).
///
/// ### 🔄 Alur & Posisi dalam User Journey:
/// 1. Selesai memotret KTP & selfie KTP di [KycSelfieKtpGuideBottomSheet].
/// 2. Halaman menampilkan panduan [KycLivenessBottomSheet.show].
/// 3. User menekan "Mulai Verifikasi Liveness" (`onStart`).
/// 4. Bottom sheet ditutup dan aplikasi meluncurkan modul/SDK Liveness (atau cek izin kamera via [KycCameraPermissionDialog]).
///
/// ### 💻 Contoh Penggunaan:
/// ```dart
/// await KycLivenessBottomSheet.show(
///   context,
///   onStart: () {
///     Navigator.pop(context); // Tutup bottom sheet
///     // Jalankan flow verifikasi liveness
///     _startLivenessProcess();
///   },
/// );
/// ```
///
/// ### ⚙️ Parameter:
/// - [onStart] : Callback saat tombol "Mulai Verifikasi Liveness" ditekan.
/// - [onClose] : Callback saat tombol close (X) di pojok kanan atas ditekan. Defaults ke `Navigator.pop(context)`.
///
/// ### ⚠️ Catatan Penting:
/// - Menggunakan asset gambar `assets/images/superapp/kyc/il_kyc_liveness.jpg`.
class KycLivenessBottomSheet extends StatelessWidget {
  /// Callback saat tombol "Mulai Verifikasi Liveness" ditekan.
  final VoidCallback? onStart;

  /// Callback saat tombol close (X) ditekan. Defaults ke [Navigator.pop].
  final VoidCallback? onClose;

  const KycLivenessBottomSheet({
    super.key,
    this.onStart,
    this.onClose,
  });

  // ---------------------------------------------------------------------------
  // Static factory
  // ---------------------------------------------------------------------------

  /// Helper statis untuk menampilkan bottom sheet panduan verifikasi liveness wajah.
  ///
  /// ```dart
  /// KycLivenessBottomSheet.show(
  ///   context,
  ///   onStart: () => launchLivenessSdk(),
  /// );
  /// ```
  static Future<T?> show<T>(
    BuildContext context, {
    VoidCallback? onStart,
    VoidCallback? onClose,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black54,
      builder: (_) => KycLivenessBottomSheet(
        onStart: onStart,
        onClose: onClose ?? () => Navigator.pop(context),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final effectiveOnClose = onClose ?? () => Navigator.pop(context);

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
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.insetLg,
              AppSpacing.lg,
              AppSpacing.insetLg,
              AppSpacing.insetLg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                          'Verifikasi Wajah Liveness',
                          textAlign: TextAlign.center,
                          style: AppTypography.headingSm.copyWith(
                            color: AppColors.black,
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: effectiveOnClose,
                        child: Container(
                          width: 40,
                          height: 40,
                          padding: const EdgeInsets.all(AppSpacing.xs),
                          decoration: const BoxDecoration(
                            color: AppColors.bgLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 20,
                            color: AppColors.grey700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),

                // ── Description
                Text(
                  'Kami perlu memastikan Kamu adalah pengguna asli. Ikuti instruksi di layar untuk verifikasi.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMdRegular.copyWith(
                    color: AppColors.textDark,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // ── Illustration (face liveness scan)
                Center(
                  child: SvgPicture.asset(
                    'assets/images/superapp/kyc/image_kyc_liveness.svg',
                    height: 180,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // ── Instruction section
                Text(
                  'Kamu akan diminta untuk:',
                  style: AppTypography.bodyMdSemiBold.copyWith(
                    color: AppColors.black0A0A,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                const _BulletItem(text: 'Putar Kepala ke Arah Kanan'),
                const _BulletItem(text: 'Putar Kepala ke Arah Kiri'),
                const _BulletItem(text: 'Senyum Saat Swafoto'),

                const SizedBox(height: AppSpacing.xl),

                // ── Mulai Verifikasi Liveness button
                DsButton(
                  text: 'Mulai Verifikasi Liveness',
                  onPressed: onStart ?? () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// _BulletItem
//
// Satu baris bullet list dengan titik orange di depan teks.
// =============================================================================

class _BulletItem extends StatelessWidget {
  final String text;

  const _BulletItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6, right: AppSpacing.sm),
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: AppColors.primaryBase,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodyMdRegular.copyWith(
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
