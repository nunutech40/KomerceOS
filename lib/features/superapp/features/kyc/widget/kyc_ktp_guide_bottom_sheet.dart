import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';

/// # KycKtpGuideBottomSheet
///
/// Bottom sheet panduan visual pengambilan foto e-KTP yang benar dan salah.
///
/// ### 📌 Kapan Digunakan:
/// - Dipicu tepat sebelum aplikasi membuka kamera atau picker foto KTP pada proses KYC.
/// - Menampilkan perbandingan kartu ilustrasi contoh KTP "Benar" (`il_kyc_ktp_valid.jpg`)
///   dan contoh KTP "Salah" (`il_kyc_ktp_invalid.jpg`) beserta poin-poin persyaratan:
///   - Menggunakan e-KTP asli (bukan fotokopi/scan).
///   - Seluruh bagian KTP masuk ke dalam frame dan tidak terpotong.
///   - Tulisan pada KTP terbaca jelas dan tidak terkena pantulan cahaya/silau.
///
/// ### 🔄 Alur & Posisi dalam User Journey:
/// 1. Liveness berhasil dan pengguna melanjutkan ke foto KTP.
/// 2. Halaman menampilkan panduan [KycKtpGuideBottomSheet.show].
/// 3. User membaca panduan lalu menekan tombol "Mulai Foto" (`onStartPhoto`).
/// 4. Bottom sheet ditutup dan aplikasi meluncurkan kamera / scanner KTP.
///
/// ### 💻 Contoh Penggunaan:
/// ```dart
/// await KycKtpGuideBottomSheet.show(
///   context,
///   onStartPhoto: () {
///     Navigator.pop(context); // Tutup bottom sheet
///     // Buka kamera foto KTP
///     _openKtpCamera();
///   },
/// );
/// ```
///
/// ### ⚙️ Parameter:
/// - [onStartPhoto] : Callback saat tombol "Mulai Foto" ditekan.
/// - [onClose] : Callback saat tombol close (X) di pojok kanan atas ditekan. Defaults ke `Navigator.pop(context)`.
///
/// ### ⚠️ Catatan Penting:
/// - Menggunakan asset gambar `assets/images/superapp/kyc/il_kyc_ktp_valid.jpg` dan
///   `assets/images/superapp/kyc/il_kyc_ktp_invalid.jpg`.
class KycKtpGuideBottomSheet extends StatelessWidget {
  /// Callback saat tombol "Mulai Foto" ditekan.
  final VoidCallback? onStartPhoto;

  /// Callback saat tombol close (X) ditekan. Defaults ke [Navigator.pop].
  final VoidCallback? onClose;

  const KycKtpGuideBottomSheet({
    super.key,
    this.onStartPhoto,
    this.onClose,
  });

  /// Helper statis untuk menampilkan bottom sheet panduan foto KTP.
  ///
  /// ```dart
  /// KycKtpGuideBottomSheet.show(
  ///   context,
  ///   onStartPhoto: () => openKtpCamera(),
  /// );
  /// ```
  static Future<T?> show<T>(
    BuildContext context, {
    VoidCallback? onStartPhoto,
    VoidCallback? onClose,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black54,
      builder: (_) => KycKtpGuideBottomSheet(
        onStartPhoto: onStartPhoto,
        onClose: onClose ?? () => Navigator.pop(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveOnClose = onClose ?? () => Navigator.pop(context);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
      child: Container(
        width: double.infinity,
        height: MediaQuery.sizeOf(context).height * .78,
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
              AppSpacing.md,
              AppSpacing.pageMargin2xs + 16,
              AppSpacing.lg,
            ),
            child: Column(
              children: [
                Expanded(
                    child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Top header bar: Title + Close (X)
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          const SizedBox(
                            width: double.infinity,
                            height: 40,
                          ),
                          Text(
                            'Verifikasi Foto KTP',
                            textAlign: TextAlign.center,
                            style: AppTypography.headingSm.copyWith(
                              color: AppColors.black,
                            ),
                          ),
                          Positioned(
                            right: 0,
                            child: GestureDetector(
                              onTap: effectiveOnClose,
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: const BoxDecoration(
                                  color: AppColors.grey100,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close_rounded,
                                  size: 18,
                                  color: AppColors.grey700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),

                      // ── Subtitle
                      Text(
                        'Pastikan foto KTP terlihat jelas dan seluruh informasi dapat terbaca untuk melanjutkan verifikasi identitas.',
                        textAlign: TextAlign.left,
                        style: AppTypography.bodySmRegular.copyWith(
                          color: AppColors.textDark,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // ── Section Title
                      Text(
                        'Petunjuk Verifikasi KTP',
                        style: AppTypography.bodySmSemiBold.copyWith(
                          color: AppColors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // ── Example 1: Benar
                      const _ExampleCard(
                        isCorrect: true,
                        label: 'Benar',
                        imagePath:
                            'assets/images/superapp/kyc/image_ktp_valid.png',
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // ── Example 2: Salah
                      const _ExampleCard(
                        isCorrect: false,
                        label: 'Salah',
                        imagePath:
                            'assets/images/superapp/kyc/image_ktp_invalid.png',
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // ── Bullet Rules
                      const _RuleBulletPoint(
                        text:
                            'Unggah foto KTP asli, bukan hasil scan atau fotocopy.',
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      const _RuleBulletPoint(
                        text:
                            'Pastikan foto tidak buram dan memiliki pencahayaan yang cukup.',
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      const _RuleBulletPoint(
                        text:
                            'Seluruh bagian KTP harus masuk ke dalam kotak foto yang disediakan.',
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                  ),
                )),
                const SizedBox(height: AppSpacing.sm),
                DsButton(text: 'Mulai Foto', onPressed: onStartPhoto ?? () {}),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Helper Widgets
// =============================================================================

class _ExampleCard extends StatelessWidget {
  final bool isCorrect;
  final String label;
  final String imagePath;

  const _ExampleCard({
    required this.isCorrect,
    required this.label,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = isCorrect ? AppColors.successBase : AppColors.errorBase;
    final bgColor =
        isCorrect ? const Color(0xFFF4FBF7) : const Color(0xFFFFF7F7);
    const borderColor = Color(0xFFE5E5E5);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.md2),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Status tag
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                size: 16,
                color: statusColor,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: AppTypography.bodySmMedium.copyWith(
                  color: statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),

          // KTP Image
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: Image.asset(
              imagePath,
              width: double.infinity,
              height: 110,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

class _RuleBulletPoint extends StatelessWidget {
  final String text;

  const _RuleBulletPoint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6, right: 8),
          child: Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: AppColors.errorBase,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodySmRegular.copyWith(
              color: AppColors.textDark,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
