import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';

/// # KycVerifyingDocumentBottomSheet
///
/// Modal bottom sheet loading state non-dismissible saat aplikasi sedang memproses,
/// mengunggah, atau membaca data OCR dari foto e-KTP pengguna.
///
/// ### 📌 Kapan Digunakan:
/// - Dipicu tepat setelah user mengambil foto KTP dan menekan "Gunakan Foto Ini".
/// - Memberitahu user bahwa proses pembacaan data identitas sedang berlangsung sehingga user
///   tidak membatalkan atau menutup aplikasi secara paksa.
///
/// ### 🔄 Alur & Posisi dalam User Journey:
/// 1. User mengambil foto KTP di modul kamera.
/// 2. Halaman menampilkan modal proses via `KycVerifyingDocumentBottomSheet.show(context)`.
/// 3. Proses request API OCR / verifikasi dokumen berjalan di background.
/// 4. Setelah API selesai:
///    - **Jika Berhasil**: Panggil `Navigator.pop(context)` untuk menutup modal, lalu tampilkan form koreksi data KTP atau [KycSelfieKtpGuideBottomSheet].
///    - **Jika Gagal / Tidak Terbaca**: Panggil `Navigator.pop(context)`, lalu tampilkan [KycRejectedBottomSheet] atau pesan kesalahan.
///
/// ### 💻 Contoh Penggunaan:
/// ```dart
/// // 1. Tampilkan modal loading pemrosesan
/// KycVerifyingDocumentBottomSheet.show(context);
///
/// try {
///   // 2. Jalankan proses upload / OCR KTP
///   final result = await ocrRepository.readKtp(imageFile);
///   
///   // 3. Tutup modal setelah proses selesai
///   if (context.mounted) {
///     Navigator.pop(context);
///     // Lanjut ke langkah selfie KTP
///     KycSelfieKtpGuideBottomSheet.show(context, onStartPhoto: () => openSelfie());
///   }
/// } catch (e) {
///   if (context.mounted) {
///     Navigator.pop(context); // Pastikan modal selalu ditutup jika error
///   }
/// }
/// ```
///
/// ### ⚙️ Parameter:
/// - [isDismissible] : Apakah modal dapat ditutup dengan tap di luar atau tombol back sistem (default: `false` agar proses tidak terinterupsi).
///
/// ### ⚠️ Catatan Penting:
/// - Menggunakan asset gambar `assets/images/superapp/kyc/il_kyc_verifying.jpg`.
/// - Dibungkus dengan [PopScope] yang mengunci tombol Back Android selama proses berjalan.
class KycVerifyingDocumentBottomSheet extends StatelessWidget {
  const KycVerifyingDocumentBottomSheet({super.key});

  /// Helper statis untuk menampilkan modal pemrosesan dokumen KTP.
  /// Bersifat non-dismissible secara default (`isDismissible = false`).
  ///
  /// ```dart
  /// KycVerifyingDocumentBottomSheet.show(context);
  /// ```
  static Future<T?> show<T>(
    BuildContext context, {
    bool isDismissible = false,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: isDismissible,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black54,
      builder: (_) => PopScope(
        canPop: isDismissible,
        child: const KycVerifyingDocumentBottomSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              AppSpacing.pageMargin2xs + 16,
              AppSpacing.xl,
              AppSpacing.pageMargin2xs + 16,
              AppSpacing.xl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Title
                Text(
                  'Memverifikasi Dokumen',
                  textAlign: TextAlign.center,
                  style: AppTypography.headingSm.copyWith(
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),

                // ── Subtitle
                Text(
                  'Sedang membaca dan memeriksa data pada KTP kamu. Mohon tunggu sebentar.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMdRegular.copyWith(
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // ── Illustration (Hourglass)
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: SvgPicture.asset(
                    'assets/images/superapp/team/ic_proses_withdraw_saldo.svg',
                    width: 200,
                    height: 200,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // ── Processing Indicator Button (Disabled)
                Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEEEEE),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.grey600,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Memproses...',
                        style: AppTypography.bodyMdSemiBold.copyWith(
                          color: AppColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

typedef KycVerifyingDocumentDialog = KycVerifyingDocumentBottomSheet;
