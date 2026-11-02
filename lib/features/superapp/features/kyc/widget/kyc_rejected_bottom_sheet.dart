import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';

/// # KycRejectedBottomSheet
///
/// Bottom sheet detail informasi penolakan verifikasi KYC / dokumen KTP.
///
/// ### 📌 Kapan Digunakan:
/// - Dipicu ketika pengajuan verifikasi KYC user ditolak oleh admin/sistem (status API: 3 / Rejected).
/// - **Secara spesifik dipanggil di halaman Notifikasi** (`NotificationPage`): ketika ada item
///   notifikasi mengenai verifikasi KYC yang gagal, di dalamnya terdapat tombol **"Periksa Data Diri"**.
///   Saat tombol "Periksa Data Diri" tersebut ditekan, modal ini dimunculkan untuk memberitahu
///   user alasan penolakan dan langkah perbaikannya.
/// - *(Catatan: Pada [KycStatusBadge] di halaman Profil/Pengaturan, badge status 3 bersifat read-only,
///   dan aksi ajukan ulang di sana ditangani oleh tombol CTA [KycOutlinedButton] "Ajukan Ulang Verifikasi").*
///
/// ### 🔄 Alur & Posisi dalam User Journey:
/// 1. Admin/sistem menolak pengajuan KYC user (status menjadi 3).
/// 2. User menerima pesan notifikasi penolakan di halaman Notifikasi (`NotificationPage`).
/// 3. User menekan tombol **"Periksa Data Diri"** pada item notifikasi tersebut -> tampilkan [KycRejectedBottomSheet.show].
/// 4. User membaca alasan penolakan (`descRejected`) dan menekan **"Ajukan Ulang Verifikasi"** (`onRetry`).
/// 5. Bottom sheet ditutup dan aplikasi mengarahkan user kembali ke alur pengunggahan identitas (Zero-Fee via [KycIdentityBottomSheet] / form KYC).
///
/// ### 💻 Contoh Penggunaan:
/// ```dart
/// // Contoh pemanggilan dari tombol 'Periksa Data Diri' di item notifikasi KYC:
/// await KycRejectedBottomSheet.show(
///   context,
///   title: 'Foto KTP Ditolak',
///   subtitle: 'Foto KTP kamu belum sesuai. Mohon lakukan ulang dengan mengikuti panduan yang diberikan.',
///   descRejected: notificationData.reason ?? 'Foto KTP buram dan data NIK tidak terbaca jelas.',
///   onRetry: () {
///     Navigator.pop(context); // Tutup bottom sheet
///     // Arahkan langsung ke pengisian identitas ulang (Zero-Fee)
///     KycIdentityBottomSheet.show(context);
///   },
/// );
/// ```
///
/// ### ⚙️ Parameter Utama:
/// - [descRejected] : Teks alasan penolakan dari sistem (wajib).
/// - [title] : Judul penolakan (default: `'Foto KTP Ditolak'`).
/// - [subtitle] : Penjelasan ringkas di bawah judul.
/// - [onRetry] : Callback saat tombol "Ajukan Ulang Verifikasi" ditekan.
/// - [onClose] : Callback saat tombol "Tutup" atau tombol close (X) ditekan. Defaults ke `Navigator.pop(context)`.
/// - [initiallyExpanded] : Apakah kartu alasan penolakan langsung terbuka saat pertama muncul (default: `true`).
/// - [image] / [imagePath] : Asset ilustrasi kustom (default: `assets/images/superapp/kyc/il_kyc_rejected.jpg`).
///
/// ### ⚠️ Catatan Penting:
/// - Kartu alasan penolakan mendukung aksi expand/collapse untuk kenyamanan membaca user.
class KycRejectedBottomSheet extends StatefulWidget {
  /// Judul utama penolakan
  final String title;

  /// Deskripsi singkat di bawah judul
  final String subtitle;

  /// Detail teks alasan penolakan
  final String descRejected;

  /// Label kartu alasan (default: "Alasan Penolakan")
  final String rejectedLabel;

  /// Widget ilustrasi custom (jika ingin menggunakan widget khusus)
  final Widget? image;

  /// Path asset ilustrasi custom (default: 'assets/images/superapp/kyc/il_kyc_rejected.jpg')
  final String? imagePath;

  /// Teks tombol aksi utama (default: "Ajukan Ulang Verifikasi")
  final String retryButtonText;

  /// Teks tombol kedua (default: "Tutup")
  final String closeButtonText;

  /// Callback saat tombol aksi utama ditekan
  final VoidCallback? onRetry;

  /// Callback saat tombol tutup ditekan (defaults ke [Navigator.pop])
  final VoidCallback? onClose;

  /// Apakah kartu alasan awalnya terbuka (default: true)
  final bool initiallyExpanded;

  const KycRejectedBottomSheet({
    super.key,
    this.title = 'Foto KTP Ditolak',
    this.subtitle =
        'Foto KTP kamu belum sesuai. Mohon lakukan ulang dengan mengikuti panduan yang diberikan.',
    required this.descRejected,
    this.rejectedLabel = 'Alasan Penolakan',
    this.image,
    this.imagePath,
    this.retryButtonText = 'Ajukan Ulang Verifikasi',
    this.closeButtonText = 'Tutup',
    this.onRetry,
    this.onClose,
    this.initiallyExpanded = true,
  });

  /// Helper statis untuk menampilkan bottom sheet penolakan verifikasi KYC.
  ///
  /// ```dart
  /// KycRejectedBottomSheet.show(
  ///   context,
  ///   descRejected: 'Foto KTP buram dan tidak jelas.',
  ///   onRetry: () => handleRetryKyc(),
  /// );
  /// ```
  static Future<T?> show<T>(
    BuildContext context, {
    String title = 'Foto KTP Ditolak',
    String subtitle =
        'Foto KTP kamu belum sesuai. Mohon lakukan ulang dengan mengikuti panduan yang diberikan.',
    required String descRejected,
    String rejectedLabel = 'Alasan Penolakan',
    Widget? image,
    String? imagePath,
    String retryButtonText = 'Ajukan Ulang Verifikasi',
    String closeButtonText = 'Tutup',
    VoidCallback? onRetry,
    VoidCallback? onClose,
    bool initiallyExpanded = true,
    bool isDismissible = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: isDismissible,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black54,
      builder: (_) => KycRejectedBottomSheet(
        title: title,
        subtitle: subtitle,
        descRejected: descRejected,
        rejectedLabel: rejectedLabel,
        image: image,
        imagePath: imagePath,
        retryButtonText: retryButtonText,
        closeButtonText: closeButtonText,
        onRetry: onRetry,
        onClose: onClose ?? () => Navigator.pop(context),
        initiallyExpanded: initiallyExpanded,
      ),
    );
  }

  @override
  State<KycRejectedBottomSheet> createState() => _KycRejectedBottomSheetState();
}

class _KycRejectedBottomSheetState extends State<KycRejectedBottomSheet> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final effectiveOnClose = widget.onClose ?? () => Navigator.pop(context);

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
              AppSpacing.lg,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Title
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: AppTypography.headingSm.copyWith(
                      color: AppColors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),

                  // ── Subtitle
                  Text(
                    widget.subtitle,
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMdRegular.copyWith(
                      color: AppColors.textDark,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Illustration Image
                  widget.image ??
                      Builder(
                        builder: (_) {
                          final path = widget.imagePath ??
                              'assets/images/superapp/kyc/il_kyc_rejected.jpg';
                          if (path.endsWith('.svg')) {
                            return SvgPicture.asset(
                              path,
                              width: 200,
                              height: 160,
                              fit: BoxFit.contain,
                            );
                          }
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            child: Image.asset(
                              path,
                              width: 200,
                              height: 160,
                              fit: BoxFit.contain,
                            ),
                          );
                        },
                      ),
                  const SizedBox(height: AppSpacing.xl),

                  // ── Alasan Penolakan Card (Collapsible)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7F7),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: const Color(0xFFE5E5E5),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card header: Red cancel icon + label
                        Row(
                          children: [
                            const Icon(
                              Icons.cancel_rounded,
                              size: 16,
                              color: AppColors.errorBase,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              widget.rejectedLabel,
                              style: AppTypography.bodySmRegular.copyWith(
                                color: AppColors.errorBase,
                              ),
                            ),
                          ],
                        ),

                        // Card body (Expanded): White container with rejection description
                        if (_isExpanded) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              border: Border.all(
                                color: const Color(0xFFEAEAEA),
                                width: 1,
                              ),
                            ),
                            child: Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Text(
                                    widget.descRejected,
                                    style:
                                        AppTypography.bodySmRegular.copyWith(
                                      color: AppColors.textDark,
                                      height: 1.45,
                                    ),
                                  ),
                                ),
                                // Corner decorative indicator
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Icon(
                                    Icons.filter_list_rounded,
                                    size: 12,
                                    color: AppColors.grey400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.sm),

                        // Card toggle: Sembunyikan / Lihat Alasan
                        Center(
                          child: GestureDetector(
                            onTap: _toggleExpanded,
                            behavior: HitTestBehavior.opaque,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _isExpanded
                                        ? 'Sembunyikan'
                                        : 'Lihat Alasan',
                                    style: AppTypography.bodySmSemiBold
                                        .copyWith(
                                      color: AppColors.primaryBase,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    _isExpanded
                                        ? Icons.keyboard_arrow_up_rounded
                                        : Icons.keyboard_arrow_down_rounded,
                                    size: 18,
                                    color: AppColors.primaryBase,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // ── Tutup Button (Text link)
                  GestureDetector(
                    onTap: effectiveOnClose,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.xs,
                        horizontal: AppSpacing.md,
                      ),
                      child: Text(
                        widget.closeButtonText,
                        style: AppTypography.bodyMdSemiBold.copyWith(
                          color: AppColors.primaryBase,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // ── Action: Ajukan Ulang Verifikasi (Primary button)
                  DsButton(
                    text: widget.retryButtonText,
                    onPressed: widget.onRetry ?? () {},
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
