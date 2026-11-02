import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';

/// # KycCameraPermissionDialog
///
/// Dialog pop-up yang meminta izin akses kamera perangkat sebelum masuk ke tahap
/// verifikasi wajah (face recognition / liveness test) atau foto KTP.
///
/// ### 📌 Kapan Digunakan:
/// - Dipicu sebelum inisialisasi modul kamera atau SDK Liveness jika aplikasi mendeteksi
///   bahwa izin kamera belum diberikan atau sebelumnya sempat ditolak.
/// - Menjelaskan secara transparan kepada user mengapa kamera dibutuhkan untuk verifikasi KYC.
///
/// ### 🔄 Alur & Posisi dalam User Journey:
/// 1. User menekan tombol "Mulai Verifikasi Liveness" di [KycLivenessBottomSheet].
/// 2. Jika permission kamera belum granted, tampilkan [KycCameraPermissionDialog.show].
/// 3. Jika user menekan "Izinkan kamera" (`onAllow`) -> panggil permission request OS / buka settings.
/// 4. Jika user menekan "Jangan izinkan" (`onDeny`) -> modal tertutup / tampilkan fallback state.
///
/// ### 💻 Contoh Penggunaan:
/// ```dart
/// await KycCameraPermissionDialog.show(
///   context,
///   onAllow: () async {
///     Navigator.pop(context); // Tutup dialog
///     final status = await Permission.camera.request();
///     if (status.isGranted && context.mounted) {
///       // Lanjutkan buka kamera / SDK liveness
///     } else if (status.isPermanentlyDenied) {
///       openAppSettings();
///     }
///   },
///   onDeny: () {
///     Navigator.pop(context); // Tutup dialog jika batal
///   },
/// );
/// ```
///
/// ### ⚙️ Parameter:
/// - [onAllow] : Callback saat user menekan tombol "Izinkan kamera".
/// - [onDeny] : Callback saat user menekan tombol "Jangan izinkan". Defaults ke `Navigator.pop(context)`.
///
/// ### ⚠️ Catatan Penting:
/// - Pastikan selalu menutup dialog via `Navigator.pop(context)` di dalam callback `onAllow` sebelum
///   menjalankan request permission async OS agar dialog tidak menggantung di layar.
class KycCameraPermissionDialog extends StatelessWidget {
  /// Callback saat tombol "Izinkan kamera" ditekan.
  final VoidCallback? onAllow;

  /// Callback saat tombol "Jangan izinkan" ditekan. Defaults ke [Navigator.pop].
  final VoidCallback? onDeny;

  const KycCameraPermissionDialog({
    super.key,
    this.onAllow,
    this.onDeny,
  });

  /// Helper statis untuk menampilkan dialog izin kamera.
  ///
  /// ```dart
  /// KycCameraPermissionDialog.show(
  ///   context,
  ///   onAllow: () => handleCameraRequest(),
  ///   onDeny: () => Navigator.pop(context),
  /// );
  /// ```
  static Future<T?> show<T>(
    BuildContext context, {
    VoidCallback? onAllow,
    VoidCallback? onDeny,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black54,
      builder: (_) => KycCameraPermissionDialog(
        onAllow: onAllow,
        onDeny: onDeny ?? () => Navigator.pop(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveOnDeny = onDeny ?? () => Navigator.pop(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title
            Text(
              'Izinkan akses kamera?',
              style: AppTypography.headingXs.copyWith(
                color: AppColors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // ── Description
            Text(
              'Kamera diperlukan untuk memeriksa gerakan wajah saat verifikasi identitas.',
              style: AppTypography.bodyMdRegular.copyWith(
                color: AppColors.textDark,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),

            // ── Center Camera Icon Box
            const Center(
              child: _CameraIconBox(
                icon: Icons.camera_alt_outlined,
              ),
            ),
            const SizedBox(height: 20),

            // ── Security / Info Note
            Row(
              children: [
                SvgPicture.asset(
                  'assets/images/superapp/kyc/ic_security_verif.svg',
                  width: 16,
                  height: 16,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    'Kamera digunakan untuk verifikasi wajah.',
                    style: AppTypography.bodySmRegular.copyWith(
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Action Buttons (Jangan izinkan | Izinkan kamera)
            Row(
              children: [
                Expanded(
                  child: _DialogSecondaryButton(
                    label: 'Jangan izinkan',
                    onPressed: effectiveOnDeny,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _DialogPrimaryButton(
                    label: 'Izinkan kamera',
                    onPressed: onAllow ?? () {},
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// KycCameraDeniedDialog (Popup)
//
// Dialog / popup saat izin kamera ditolak / belum tersedia.
// Meminta user membuka pengaturan HP atau browser.
//
// Cara pakai:
//   KycCameraDeniedDialog.show(
//     context,
//     onSettings: () {
//       // open app settings
//     },
//     onBack: () {
//       // handle kembali
//     },
//   );
// =============================================================================

class KycCameraDeniedDialog extends StatelessWidget {
  /// Callback saat tombol "Pengaturan" ditekan.
  final VoidCallback? onSettings;

  /// Callback saat tombol "Kembali" ditekan. Defaults ke [Navigator.pop].
  final VoidCallback? onBack;

  const KycCameraDeniedDialog({
    super.key,
    this.onSettings,
    this.onBack,
  });

  /// Helper statis untuk menampilkan popup
  static Future<T?> show<T>(
    BuildContext context, {
    VoidCallback? onSettings,
    VoidCallback? onBack,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black54,
      builder: (_) => KycCameraDeniedDialog(
        onSettings: onSettings,
        onBack: onBack ?? () => Navigator.pop(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveOnBack = onBack ?? () => Navigator.pop(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title
            Text(
              'Izin kamera diperlukan untuk verifikasi',
              style: AppTypography.headingXs.copyWith(
                color: AppColors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),

            // ── Description
            Text(
              'Izin kamera ditolak atau akses kamera belum tersedia. Izinkan kamera melalui pengaturan HP atau browser, lalu coba lagi.',
              style: AppTypography.bodySmRegular.copyWith(
                color: AppColors.textDark,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),

            // ── Center Camera Off Icon Box
            const Center(
              child: _CameraIconBox(
                icon: Icons.no_photography_outlined,
              ),
            ),
            const SizedBox(height: 20),

            // ── Security / Info Note
            Row(
              children: [
                SvgPicture.asset(
                  'assets/images/superapp/kyc/ic_security_verif.svg',
                  width: 16,
                  height: 16,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    'Kamera digunakan untuk verifikasi wajah.',
                    style: AppTypography.bodySmRegular.copyWith(
                      color: AppColors.grey700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Action Buttons (Kembali | Pengaturan)
            Row(
              children: [
                Expanded(
                  child: _DialogSecondaryButton(
                    label: 'Kembali',
                    onPressed: effectiveOnBack,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _DialogPrimaryButton(
                    label: 'Pengaturan',
                    onPressed: onSettings ?? () {},
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Helper Internal Widgets
// =============================================================================

/// Kotak rounded peach dengan icon kamera outline
class _CameraIconBox extends StatelessWidget {
  final IconData icon;

  const _CameraIconBox({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFFFFE8D9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: SvgPicture.asset(
            'assets/images/superapp/kyc/ic_camera_permission.svg',
            width: 40,
            height: 40),
      ),
    );
  }
}

/// Tombol abu-abu sekunder (e.g. "Jangan izinkan", "Kembali")
class _DialogSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _DialogSecondaryButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFFF6F6F6),
          foregroundColor: AppColors.black,
          side: const BorderSide(color: Color(0xFFE5E5E5), width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          elevation: 0,
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.bodySmSemiBold.copyWith(
            color: AppColors.black,
          ),
        ),
      ),
    );
  }
}

/// Tombol oranye primer (e.g. "Izinkan kamera", "Pengaturan")
class _DialogPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _DialogPrimaryButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBase,
          foregroundColor: AppColors.alwaysWhite,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.bodySmSemiBold.copyWith(
            color: AppColors.alwaysWhite,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Aliases
// =============================================================================
typedef KycCameraPermissionPopup = KycCameraPermissionDialog;
typedef KycCameraDeniedPopup = KycCameraDeniedDialog;
