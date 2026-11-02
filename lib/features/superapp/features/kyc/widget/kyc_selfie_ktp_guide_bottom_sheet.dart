import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';

/// # KycSelfieKtpGuideBottomSheet
///
/// Bottom sheet panduan visual pengambilan foto selfie memegang e-KTP yang benar dan salah.
///
/// ### 📌 Kapan Digunakan:
/// - Dipicu setelah user berhasil memotret foto KTP depan, sebelum kamera selfie diaktifkan.
/// - Menjelaskan poin-poin krusial agar pengajuan tidak ditolak:
///   - Wajah dan fisik KTP berada dalam satu frame foto selfie.
///   - Tangan tidak menutupi informasi teks atau foto pada e-KTP.
///   - Tidak menggunakan kacamata hitam, masker, atau topi yang menutupi wajah.
///   - Tulisan pada KTP harus tetap terbaca jelas dan tidak kabur/silau.
///
/// ### 🔄 Alur & Posisi dalam User Journey:
/// 1. Foto KTP berhasil diverifikasi/dibaca di [KycVerifyingDocumentBottomSheet].
/// 2. Halaman memicu panduan selfie [KycSelfieKtpGuideBottomSheet.show].
/// 3. User menekan tombol "Mulai Foto" (`onStartPhoto`).
/// 4. Bottom sheet ditutup dan aplikasi membuka kamera depan untuk memotret selfie bersama KTP.
///
/// ### 💻 Contoh Penggunaan:
/// ```dart
/// await KycSelfieKtpGuideBottomSheet.show(
///   context,
///   onStartPhoto: () {
///     Navigator.pop(context); // Tutup bottom sheet
///     _openSelfieCamera();
///   },
/// );
/// ```
///
/// ### ⚙️ Parameter:
/// - [onStartPhoto] : Callback saat tombol "Mulai Foto" ditekan.
/// - [onClose] : Callback saat tombol close (X) di pojok kanan atas ditekan. Defaults ke `Navigator.pop(context)`.
///
/// ### ⚠️ Catatan Penting:
/// - Menggunakan asset gambar `assets/images/superapp/kyc/il_kyc_selfie_valid.jpg` dan
///   `assets/images/superapp/kyc/il_kyc_selfie_invalid.jpg`.
class KycSelfieKtpGuideBottomSheet extends StatelessWidget {
  /// Callback saat tombol "Mulai Foto" ditekan.
  final VoidCallback? onStartPhoto;

  /// Callback saat tombol close (X) ditekan. Defaults ke [Navigator.pop].
  final VoidCallback? onClose;

  const KycSelfieKtpGuideBottomSheet({
    super.key,
    this.onStartPhoto,
    this.onClose,
  });

  /// Helper statis untuk menampilkan bottom sheet panduan foto selfie KTP.
  ///
  /// ```dart
  /// KycSelfieKtpGuideBottomSheet.show(
  ///   context,
  ///   onStartPhoto: () => openFrontCamera(),
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
      builder: (_) => KycSelfieKtpGuideBottomSheet(
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
                        'Verifikasi Foto Selfie & KTP',
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
                    'Ambil foto wajah dan KTP untuk memverifikasi identitasmu.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMdRegular.copyWith(
                      color: AppColors.textDark,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // ── Section Title
                  Text(
                    'Petunjuk Verifikasi KTP',
                    style: AppTypography.bodyMdSemiBold.copyWith(
                      color: AppColors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // ── Example 1: Benar
                  const _SelfieCard(
                    isCorrect: true,
                    label: 'Benar',
                    imagePath:
                        'assets/images/superapp/kyc/image_selfie_valid.png',
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Status diterima rules (hijau)
                  Text(
                    'Status verifikasi KTP diterima apabila:',
                    style: AppTypography.bodyMdMedium.copyWith(
                      color: AppColors.successBase,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  const _ColoredBullet(
                    color: AppColors.successBase,
                    text:
                        'Selfie + KTP terfoto dengan jelas dan tidak terpotong',
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  const _ColoredBullet(
                    color: AppColors.successBase,
                    text:
                        'Data yang ada di profile sesuai dengan data yang ada di KTP',
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // ── Example 2: Salah
                  const _SelfieCard(
                    isCorrect: false,
                    label: 'Salah',
                    imagePath:
                        'assets/images/superapp/kyc/image_selfie_invalid.png',
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Status ditolak rules (merah)
                  Text(
                    'Status verifikasi KTP ditolak apabila:',
                    style: AppTypography.bodyMdMedium.copyWith(
                      color: AppColors.errorBase,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  const _ColoredBullet(
                    color: AppColors.errorBase,
                    text:
                        'Selfie + KTP terfoto tidak jelas dan tidak terpotong',
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  const _ColoredBullet(
                    color: AppColors.errorBase,
                    text:
                        'Data yang ada di profile tidak sesuai dengan data yang ada di KTP',
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // ── Action: Mulai Foto
                  DsButton(
                    text: 'Mulai Foto',
                    onPressed: onStartPhoto ?? () {},
                  ),
                ],
              ),
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

class _SelfieCard extends StatelessWidget {
  final bool isCorrect;
  final String label;
  final String imagePath;

  const _SelfieCard({
    required this.isCorrect,
    required this.label,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = isCorrect ? AppColors.successBase : AppColors.errorBase;
    final bgColor =
        isCorrect ? const Color(0xFFF6FDF9) : const Color(0xFFFEF7F7);
    const borderColor = Color(0x0ff5e5e5);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: Image.asset(
                imagePath,
                width: 140,
                height: 140,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ColoredBullet extends StatelessWidget {
  final Color color;
  final String text;

  const _ColoredBullet({
    required this.color,
    required this.text,
  });

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
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodyMdRegular.copyWith(
              color: AppColors.textDark,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
