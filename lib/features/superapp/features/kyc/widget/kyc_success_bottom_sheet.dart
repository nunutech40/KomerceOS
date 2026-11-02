import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';

/// # KycSuccessBottomSheet
///
/// Bottom sheet universal dan reusable untuk status sukses serta status dalam proses pada alur KYC:
/// 1. **Pengajuan Berhasil** (`showSubmissionSuccess`) : Setelah user selesai mengunggah seluruh dokumen & foto.
/// 2. **Dalam Proses Verifikasi** (`showVerificationInProgress`) : Popup info saat status akun bernilai 1 (menunggu screening admin 1x24 jam).
/// 3. **Pembayaran Berhasil** (`showPaymentSuccess`) : Notifikasi sukses pembayaran biaya verifikasi KYC Rp 25.000 dengan spinner redirecting.
///
/// ### 📌 Kapan Digunakan:
/// - Dipicu di akhir submit KYC, setelah pembayaran potong saldo Kompay, atau saat badge status 1 diklik.
/// - Mendukung mode loading transisi (`isLoading: true`) di mana tombol berubah menjadi disabled dengan spinner animasi.
///
/// ### 🔄 Alur & Posisi dalam User Journey:
/// - **Submit Selesai**: User selesai liveness test -> panggil API submit -> tampilkan `showSubmissionSuccess` -> tekan "Selesai" -> kembali ke Home.
/// - **Cek Status**: User klik badge "Dalam Proses" di Home -> tampilkan `showVerificationInProgress` -> tekan "Oke" -> tutup modal.
///
/// ### 💻 Contoh Penggunaan:
/// ```dart
/// // Contoh 1: Notifikasi sukses submit dokumen KTP & wajah
/// await KycSuccessBottomSheet.showSubmissionSuccess(
///   context,
///   onDone: () {
///     Navigator.pop(context); // Tutup bottom sheet
///     Navigator.of(context).popUntil((r) => r.isFirst); // Kembali ke root Home
///   },
/// );
///
/// // Contoh 2: Info akun sedang direview admin
/// KycSuccessBottomSheet.showVerificationInProgress(context);
///
/// // Contoh 3: Sukses bayar biaya verifikasi
/// KycSuccessBottomSheet.showPaymentSuccess(
///   context,
///   onAction: () => navigateToIdentityStep(),
/// );
/// ```
///
/// ### ⚙️ Parameter Utama:
/// - [title] : Judul utama (default bervariasi sesuai preset).
/// - [subtitle] : Pesan instruksi / estimasi waktu (misal: "1x24 jam").
/// - [buttonText] : Label teks tombol (default: `'Selesai'` atau `'Oke'`).
/// - [onButtonPressed] / [onDone] : Callback saat tombol aksi ditekan.
/// - [isLoading] : Jika `true`, tombol berubah menjadi loading state "Redirecting..." dan modal non-dismissible.
/// - [showCloseButton] : Menampilkan tombol close (X) di pojok kanan atas.
class KycSuccessBottomSheet extends StatelessWidget {
  /// Judul utama
  final String title;

  /// Penjelasan di bawah judul
  final String subtitle;

  /// Teks tombol aksi (saat tidak loading)
  final String buttonText;

  /// Callback tombol aksi
  final VoidCallback? onButtonPressed;

  /// Menampilkan tombol close (X) di pojok kanan atas (opsional)
  final bool showCloseButton;

  /// Callback saat tombol close ditekan
  final VoidCallback? onClose;

  /// Widget ilustrasi custom
  final Widget? image;

  /// Path asset gambar ilustrasi (default: ilustration_top_up_success.svg)
  final String? imagePath;

  /// Mode loading / redirecting
  final bool isLoading;

  /// Teks pada tombol saat mode loading
  final String loadingText;

  /// Warna latar belakang bottom sheet (default: AppColors.alwaysWhite, bisa Color(0xFFDCDCDC))
  final Color? backgroundColor;

  const KycSuccessBottomSheet({
    super.key,
    this.title = 'Pengajuan Verifikasi KTP Berhasil',
    this.subtitle = 'Silakan tunggu konfirmasi lebih lanjut selama 1x24 jam.',
    this.buttonText = 'Selesai',
    this.onButtonPressed,
    this.showCloseButton = false,
    this.onClose,
    this.image,
    this.imagePath,
    this.isLoading = false,
    this.loadingText = 'Redirecting...',
    this.backgroundColor,
  });

  // ---------------------------------------------------------------------------
  // Static Factory Helpers
  // ---------------------------------------------------------------------------

  /// Helper umum untuk menampilkan bottom sheet sukses / status
  static Future<T?> show<T>(
    BuildContext context, {
    String title = 'Pengajuan Verifikasi KTP Berhasil',
    String subtitle = 'Silakan tunggu konfirmasi lebih lanjut selama 1x24 jam.',
    String buttonText = 'Selesai',
    VoidCallback? onButtonPressed,
    bool showCloseButton = false,
    VoidCallback? onClose,
    Widget? image,
    String? imagePath,
    bool isLoading = false,
    String loadingText = 'Redirecting...',
    Color? backgroundColor,
    bool? isDismissible,
    bool? enableDrag,
  }) {
    final effectiveDismissible = isDismissible ?? !isLoading;
    final effectiveEnableDrag = enableDrag ?? !isLoading;

    return showModalBottomSheet<T>(
      context: context,
      isDismissible: effectiveDismissible,
      enableDrag: effectiveEnableDrag,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black54,
      builder: (_) => PopScope(
        canPop: effectiveDismissible,
        child: KycSuccessBottomSheet(
          title: title,
          subtitle: subtitle,
          buttonText: buttonText,
          onButtonPressed: onButtonPressed ?? () => Navigator.pop(context),
          showCloseButton: showCloseButton,
          onClose: onClose ?? () => Navigator.pop(context),
          image: image,
          imagePath: imagePath,
          isLoading: isLoading,
          loadingText: loadingText,
          backgroundColor: backgroundColor,
        ),
      ),
    );
  }

  /// Preset: Pengajuan Verifikasi KTP Berhasil (Tombol 'Selesai', tanpa close)
  static Future<T?> showSubmissionSuccess<T>(
    BuildContext context, {
    String title = 'Pengajuan Verifikasi KTP\nBerhasil',
    String subtitle = 'Silakan tunggu konfirmasi lebih lanjut\nselama 1x24 jam.',
    String buttonText = 'Selesai',
    bool showCloseButton = true,
    VoidCallback? onDone,
    VoidCallback? onClose,
  }) {
    return show<T>(
      context,
      title: title,
      subtitle: subtitle,
      buttonText: buttonText,
      showCloseButton: showCloseButton,
      onButtonPressed: onDone,
      onClose: onClose,
      isLoading: false,
    );
  }

  /// Preset: Dalam Proses Verifikasi (Tombol 'Oke', close (X) opsional, ilustrasi proses)
  static Future<T?> showVerificationInProgress<T>(
    BuildContext context, {
    String title = 'Dalam Proses Verifikasi',
    String subtitle =
        'Tunggu sekitar 1x24 jam, update\ntersedia di email atau lonceng\nnotifikasi.',
    String buttonText = 'Oke',
    String imagePath =
        'assets/images/superapp/team/ic_proses_withdraw_saldo.svg',
    bool showCloseButton = true,
    VoidCallback? onDone,
    VoidCallback? onClose,
  }) {
    return show<T>(
      context,
      title: title,
      subtitle: subtitle,
      buttonText: buttonText,
      imagePath: imagePath,
      showCloseButton: showCloseButton,
      onButtonPressed: onDone,
      onClose: onClose,
      isLoading: false,
    );
  }

  /// Preset: Pembayaran Berhasil (Tombol loading 'Redirecting...' atau aksi selesai)
  static Future<T?> showPaymentSuccess<T>(
    BuildContext context, {
    String title = 'Pembayaran Berhasil',
    String subtitle = 'Paid verifikasi telah berhasil dibeli.',
    Color backgroundColor = const Color(0xFFDCDCDC),
    bool isLoading = true,
    String loadingText = 'Redirecting...',
    String buttonText = 'Lanjutkan',
    VoidCallback? onAction,
  }) {
    return show<T>(
      context,
      title: title,
      subtitle: subtitle,
      backgroundColor: backgroundColor,
      isLoading: isLoading,
      loadingText: loadingText,
      buttonText: buttonText,
      onButtonPressed: onAction,
      showCloseButton: false,
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed =
        onButtonPressed ?? () => Navigator.pop(context);
    final effectiveOnClose = onClose ?? () => Navigator.pop(context);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pageMargin2xs,
        ),
        decoration: BoxDecoration(
          color: backgroundColor ?? Color(0xFFDCDCDC),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(
              backgroundColor != null ? AppRadius.pill : AppRadius.xl2,
            ),
            topRight: Radius.circular(
              backgroundColor != null ? AppRadius.pill : AppRadius.xl2,
            ),
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
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Header Bar: Title with optional Close Button (X)
                if (showCloseButton)
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      const SizedBox(
                        width: double.infinity,
                        height: 40,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: AppTypography.headingSm.copyWith(
                            color: AppColors.black,
                            fontWeight: FontWeight.bold,
                          ),
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
                  )
                else ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: AppTypography.headingSm.copyWith(
                      color: AppColors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xs),

                // ── Subtitle
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMdRegular.copyWith(
                    color: AppColors.textDark,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // ── Illustration Image
                image ??
                    Builder(
                      builder: (_) {
                        final path = imagePath ??
                            'assets/images/superapp/topup/ilustration_top_up_success.svg';
                        if (path.endsWith('.svg')) {
                          return SvgPicture.asset(
                            path,
                            height: 200,
                            fit: BoxFit.contain,
                          );
                        }
                        return Image.asset(
                          path,
                          height: 220,
                          fit: BoxFit.contain,
                        );
                      },
                    ),
                const SizedBox(height: AppSpacing.xl),

                // ── Button: Loading Spinner or Primary Button
                if (isLoading)
                  _LoadingButton(label: loadingText)
                else
                  DsButton(
                    text: buttonText,
                    onPressed: effectiveOnPressed,
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
// Helper Widgets
// =============================================================================

/// Tombol abu-abu dengan spinner saat state redirecting/loading
class _LoadingButton extends StatelessWidget {
  final String label;

  const _LoadingButton({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            label,
            style: AppTypography.bodyMdSemiBold.copyWith(
              color: AppColors.grey600,
            ),
          ),
        ],
      ),
    );
  }
}
