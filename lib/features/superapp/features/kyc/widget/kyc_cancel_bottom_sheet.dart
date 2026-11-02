import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';

/// # KycCancelBottomSheet
///
/// Bottom sheet konfirmasi saat user ingin membatalkan pengajuan KYC di tengah proses.
///
/// ### 📌 Kapan Digunakan:
/// - Dipicu ketika user menekan tombol "Back" di AppBar atau gesture back sistem Android/iOS
///   saat sedang berada di tengah-tengah formulir atau alur verifikasi KYC.
/// - Menghindari hilangnya progres input data user secara tidak sengaja.
///
/// ### 🔄 Alur & Posisi dalam User Journey:
/// 1. User menekan tombol kembali saat mengisi form KYC / sebelum submit final.
/// 2. Halaman memicu `KycCancelBottomSheet.show(...)`.
/// 3. Jika user memilih "Kembali" (`onKeep`) -> modal tertutup dan user tetap berada di form KYC.
/// 4. Jika user memilih "Ya, Batalkan" (`onCancelSubmission`) -> modal ditutup dan form KYC di-pop kembali ke halaman sebelumnya.
///
/// ### 💻 Contoh Penggunaan:
/// ```dart
/// // Integrasi di dalam PopScope atau tombol Back AppBar:
/// Future<void> _handleBackConfirmation(BuildContext context) async {
///   await KycCancelBottomSheet.show(
///     context,
///     onCancelSubmission: () {
///       Navigator.pop(context); // Tutup bottom sheet
///       Navigator.pop(context); // Keluar dari halaman form KYC
///     },
///     onKeep: () {
///       Navigator.pop(context); // Tutup bottom sheet, tetap di form KYC
///     },
///   );
/// }
/// ```
///
/// ### ⚙️ Parameter:
/// - [onCancelSubmission] : Callback saat tombol "Ya, Batalkan" ditekan.
/// - [onKeep] : Callback saat tombol "Kembali" ditekan. Defaults ke `Navigator.pop(context)`.
/// - [onClose] : Callback saat tombol ikon close (X) di pojok kanan atas ditekan. Defaults ke `Navigator.pop(context)`.
///
/// ### ⚠️ Catatan Penting:
/// - Menggunakan asset gambar `assets/images/superapp/kyc/il_kyc_cancel.jpg`.
class KycCancelBottomSheet extends StatelessWidget {
  /// Callback saat tombol "Ya, Batalkan" ditekan.
  final VoidCallback? onCancelSubmission;

  /// Callback saat tombol "Kembali" ditekan. Defaults ke [Navigator.pop].
  final VoidCallback? onKeep;

  /// Callback saat tombol close (X) ditekan. Defaults ke [Navigator.pop].
  final VoidCallback? onClose;

  const KycCancelBottomSheet({
    super.key,
    this.onCancelSubmission,
    this.onKeep,
    this.onClose,
  });

  /// Helper statis untuk menampilkan bottom sheet konfirmasi pembatalan.
  ///
  /// ```dart
  /// KycCancelBottomSheet.show(
  ///   context,
  ///   onCancelSubmission: () => Navigator.of(context).popUntil((r) => r.isFirst),
  /// );
  /// ```
  static Future<T?> show<T>(
    BuildContext context, {
    VoidCallback? onCancelSubmission,
    VoidCallback? onKeep,
    VoidCallback? onClose,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black54,
      builder: (_) => KycCancelBottomSheet(
        onCancelSubmission: onCancelSubmission,
        onKeep: onKeep ?? () => Navigator.pop(context),
        onClose: onClose ?? () => Navigator.pop(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveOnKeep = onKeep ?? () => Navigator.pop(context);
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
              AppSpacing.xl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                      'Batalkan Pengajuan?',
                      textAlign: TextAlign.center,
                      style: AppTypography.headingSm.copyWith(
                        color: AppColors.black,
                        fontWeight: FontWeight.bold,
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
                const SizedBox(height: AppSpacing.sm),

                // ── Subtitle description
                Text(
                  'Apakah Anda yakin ingin membatalkan pengajuan ini? Semua data yang telah dimasukkan akan dihapus dan tidak dapat dikembalikan.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMdRegular.copyWith(
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // ── Illustration
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: SvgPicture.asset(
                    'assets/images/superapp/kyc/ic_cancel_submit.svg',
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // ── Action: Kembali (Text button)
                GestureDetector(
                  onTap: effectiveOnKeep,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xs,
                      horizontal: AppSpacing.md,
                    ),
                    child: Text(
                      'Kembali',
                      style: AppTypography.bodyMdSemiBold.copyWith(
                        color: AppColors.primaryBase,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                // ── Action: Ya, Batalkan (Primary button)
                DsButton(
                  text: 'Ya, Batalkan',
                  onPressed: onCancelSubmission ?? () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
