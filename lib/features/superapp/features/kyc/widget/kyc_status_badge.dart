import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';

import 'kyc_rejected_bottom_sheet.dart';
import 'kyc_success_bottom_sheet.dart';

/// # KycKtpStatus
///
/// Pemetaan enum untuk nilai parameter API `verification_ktp_status`:
/// - [unverified] (0) : Akun belum pernah mengajukan verifikasi KYC sama sekali.
/// - [inProgress] (1) : Dokumen telah dikirim dan sedang dalam proses screening/peninjauan admin (1x24 jam).
/// - [verified] (2)   : Verifikasi telah disetujui (ACC) oleh admin.
/// - [rejected] (3)   : Pengajuan verifikasi ditolak karena dokumen/foto tidak sesuai.
/// - [paid] (5)       : User sudah membayar biaya verifikasi (Rp 25.000), namun belum mengunggah dokumen/foto KTP.
enum KycKtpStatus {
  unverified(0),
  inProgress(1),
  verified(2),
  rejected(3),
  paid(5);

  final int value;
  const KycKtpStatus(this.value);

  /// Konversi aman dari dynamic (int, String, atau null).
  static KycKtpStatus fromValue(dynamic value) {
    if (value == null) return KycKtpStatus.unverified;
    final parsed = int.tryParse(value.toString());
    switch (parsed) {
      case 1:
        return KycKtpStatus.inProgress;
      case 2:
        return KycKtpStatus.verified;
      case 3:
        return KycKtpStatus.rejected;
      case 5:
        return KycKtpStatus.paid;
      case 0:
      default:
        return KycKtpStatus.unverified;
    }
  }
}

/// Posisi ikon pada badge:
/// - [leading] : Ikon di sebelah kiri teks.
/// - [trailing] : Ikon di sebelah kanan teks (misal: panah ↗ atau chevron >).
enum KycBadgeIconPosition { leading, trailing }

/// # KycStatusBadge
///
/// Widget badge / chip berbentuk kapsul (pill) untuk menampilkan status KYC akun pengguna secara visual.
///
/// ### 📌 Kapan Digunakan:
/// - Ditampilkan pada Header / Balance Section di `HomePage` dan halaman `SettingPage` / Profil Akun.
/// - Warna, ikon, dan teks otomatis menyesuaikan nilai status KYC dari API backend (`verification_ktp_status`).
///
/// ### 🔄 Perilaku Interaksi & Klik (Tap Behavior):
/// - **Status 0 (Belum Verifikasi) & 5 (Paid/Belum Lengkapi Dokumen)**:
///   Badge bersifat *read-only* (tidak bisa diklik). Interaksi user dipusatkan pada tombol CTA terpisah
///   seperti [KycOutlinedButton] ("Ajukan Verifikasi KTP ↗").
/// - **Status 1 (Dalam Proses Verifikasi)**:
///   Badge *dapat diklik*. Otomatis menampilkan modal [KycSuccessBottomSheet.showVerificationInProgress]
///   yang menginformasikan bahwa data sedang ditinjau 1x24 jam.
/// - **Status 2 (Terverifikasi)**:
///   Badge hijau sukses (read-only).
/// - **Status 3 (Ditolak)**:
///   Badge merah peringatan. Bersifat *read-only* pada halaman profil/pengaturan (aksi pengajuan ulang
///   dipusatkan ke tombol [KycOutlinedButton] "Ajukan Ulang Verifikasi", sedangkan modal alasan penolakan
///   [KycRejectedBottomSheet] diakses melalui tombol **"Periksa Data Diri"** pada halaman Notifikasi).
///
/// ### 💻 Contoh Penggunaan:
/// ```dart
/// // Cara termudah: otomatis mapping dari status API (status 1 otomatis bisa diklik membuka modal proses):
/// KycStatusBadge.fromStatus(
///   userProfile.verificationKtpStatus,
///   context: context,
/// )
///
/// // Atau gunakan custom onTap:
/// KycStatusBadge.fromStatus(
///   userProfile.verificationKtpStatus,
///   onTap: () {
///     // Handler navigasi khusus
///   },
/// )
/// ```
///
/// ### ⚙️ Parameter `KycStatusBadge.fromStatus`:
/// - [status] : Nilai integer atau String dari API backend (`0`, `1`, `2`, `3`, `5`).
/// - [context] : BuildContext pemanggil untuk otomatis menampilkan popup detail (status 1 & 3).
/// - [descRejected] : Teks alasan penolakan jika status bernilai 3.
/// - [isClickable] : Menentukan apakah badge merespons sentuhan (default: `true`).
/// - [customText] : Override teks default badge jika diperlukan.
class KycStatusBadge extends StatelessWidget {
  /// Teks yang ditampilkan pada badge
  final String text;

  /// IconData untuk ikon sederhana
  final IconData? iconData;

  /// Custom Widget ikon jika membutuhkan widget khusus
  final Widget? icon;

  /// Posisi ikon (di kiri teks atau di kanan teks)
  final KycBadgeIconPosition iconPosition;

  /// Warna teks
  final Color? textColor;

  /// Warna ikon (default mengikuti [textColor])
  final Color? iconColor;

  /// Warna background badge (default: tint lembut dari [textColor])
  final Color? backgroundColor;

  /// Warna border (opsional)
  final Color? borderColor;

  /// Ukuran ikon (default: 16)
  final double iconSize;

  /// Jarak antara ikon dan teks (default: 6)
  final double spacing;

  /// Padding dalam badge
  final EdgeInsetsGeometry padding;

  /// Custom text style
  final TextStyle? textStyle;

  /// Apakah badge dapat diklik (default: true jika onTap / auto tap aktif)
  final bool isClickable;

  /// Callback saat badge ditekan (opsional)
  final VoidCallback? onTap;

  const KycStatusBadge({
    super.key,
    required this.text,
    this.iconData = Icons.verified_outlined,
    this.icon,
    this.iconPosition = KycBadgeIconPosition.leading,
    this.textColor = const Color(0xFF08A0F7),
    this.iconColor,
    this.backgroundColor,
    this.borderColor,
    this.iconSize = 16,
    this.spacing = 6,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    this.textStyle,
    this.isClickable = true,
    this.onTap,
  });

  // ---------------------------------------------------------------------------
  // Factory by verification_ktp_status
  // ---------------------------------------------------------------------------

  /// Factory untuk menampilkan badge otomatis sesuai nilai [verification_ktp_status] dari API:
  /// - `0` -> Belum Terverifikasi (read-only, aksi dipusatkan pada CTA tombol)
  /// - `1` -> Dalam Proses Verifikasi (bisa diklik untuk buka info proses)
  /// - `2` -> Terverifikasi (hijau sukses)
  /// - `3` -> Verifikasi KTP Ditolak (bisa diklik untuk buka alasan penolakan)
  /// - `5` -> Paid / Menunggu Pengunggahan Dokumen
  ///
  /// ```dart
  /// KycStatusBadge.fromStatus(
  ///   profile.verificationKtpStatus,
  ///   context: context,
  ///   descRejected: profile.kycRejectionReason,
  /// )
  /// ```
  ///
  /// Jika [context] diisi dan [onTap] bernilai null:
  /// - Status 1 otomatis membuka [KycSuccessBottomSheet.showVerificationInProgress].
  /// - Status 3 pada dasarnya read-only di halaman setting/profile (aksi diarahkan ke tombol CTA
  ///   dan detail alasan penolakan diakses dari tombol "Periksa Data Diri" di halaman notifikasi).
  factory KycStatusBadge.fromStatus(
    dynamic status, {
    Key? key,
    BuildContext? context,
    VoidCallback? onTap,
    String? customText,
    String? descRejected,
    bool isClickable = true,
  }) {
    final parsedStatus = KycKtpStatus.fromValue(status);

    VoidCallback? resolveOnTap() {
      if (!isClickable) return null;
      if (onTap != null) return onTap;

      // Default tap handler jika context tersedia
      if (context != null) {
        if (parsedStatus == KycKtpStatus.inProgress) {
          return () =>
              KycSuccessBottomSheet.showVerificationInProgress(context);
        } else if (parsedStatus == KycKtpStatus.rejected &&
            descRejected != null) {
          return () => KycRejectedBottomSheet.show(
                context,
                descRejected: descRejected,
              );
        }
      }
      return null;
    }

    final effectiveOnTap = resolveOnTap();

    switch (parsedStatus) {
      case KycKtpStatus.paid:
        return KycStatusBadge.unverified(
          key: key,
          text: customText ?? 'Belum Terverifikasi',
          isClickable: effectiveOnTap != null && isClickable,
          onTap: effectiveOnTap,
        );
      case KycKtpStatus.inProgress:
        return KycStatusBadge.inProgress(
          key: key,
          text: customText ?? 'Dalam Proses Verifikasi',
          isClickable: isClickable,
          onTap: effectiveOnTap,
        );
      case KycKtpStatus.verified:
        return KycStatusBadge.verified(
          key: key,
          text: customText ?? 'Terverifikasi',
          isClickable: isClickable,
          onTap: effectiveOnTap,
        );
      case KycKtpStatus.rejected:
        return KycStatusBadge.rejected(
          key: key,
          text: customText ?? 'Verifikasi KTP Ditolak',
          isClickable: isClickable,
          onTap: effectiveOnTap,
        );
      case KycKtpStatus.unverified:
        return KycStatusBadge.unverified(
          key: key,
          text: customText ?? 'Belum Terverifikasi',
          isClickable: effectiveOnTap != null && isClickable,
          onTap: effectiveOnTap,
        );
    }
  }

  // ---------------------------------------------------------------------------
  // Factory Presets Sesuai Desain
  // ---------------------------------------------------------------------------

  /// 0 = Belum Terverifikasi (Abu-abu dengan icon cancel silang di kiri)
  factory KycStatusBadge.unverified({
    Key? key,
    String text = 'Belum Terverifikasi',
    IconData? iconData = Icons.cancel_outlined,
    Widget? icon,
    Color textColor = const Color(0xFF626262),
    Color? iconColor,
    Color backgroundColor = const Color(0xFFE8E8E8),
    Color? borderColor,
    bool isClickable = false,
    VoidCallback? onTap,
  }) {
    return KycStatusBadge(
      key: key,
      text: text,
      iconData: iconData,
      icon: icon,
      iconPosition: KycBadgeIconPosition.leading,
      textColor: textColor,
      iconColor: iconColor ?? textColor,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      isClickable: isClickable,
      onTap: onTap,
    );
  }

  /// 1 = Dalam Proses Verifikasi (Peach oranye dengan icon info biru di kanan)
  /// Otomatis bisa diklik. Jika [context] dioper, otomatis membuka sheet info proses.
  factory KycStatusBadge.inProgress({
    Key? key,
    BuildContext? context,
    String text = 'Dalam Proses Verifikasi',
    IconData? iconData = Icons.info_outline_rounded,
    Widget? icon,
    Color textColor = const Color(0xFFCC4B12),
    Color iconColor = const Color(0xFF0090FF),
    Color backgroundColor = const Color(0xFFFFD0B5),
    Color? borderColor,
    bool isClickable = true,
    VoidCallback? onTap,
  }) {
    final effectiveOnTap = onTap ??
        (context != null && isClickable
            ? () => KycSuccessBottomSheet.showVerificationInProgress(context)
            : null);

    return KycStatusBadge(
      key: key,
      text: text,
      iconData: iconData,
      icon: icon,
      iconPosition: KycBadgeIconPosition.trailing,
      textColor: textColor,
      iconColor: iconColor,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      isClickable: isClickable,
      onTap: effectiveOnTap,
    );
  }

  /// Alias untuk [inProgress]
  static KycStatusBadge pending({
    Key? key,
    BuildContext? context,
    String text = 'Dalam Proses Verifikasi',
    bool isClickable = true,
    VoidCallback? onTap,
  }) =>
      KycStatusBadge.inProgress(
        key: key,
        context: context,
        text: text,
        isClickable: isClickable,
        onTap: onTap,
      );

  /// 2 = Terverifikasi (Biru muda dengan icon checklist bergerigi di kiri)
  factory KycStatusBadge.verified({
    Key? key,
    String text = 'Terverifikasi',
    IconData? iconData = Icons.verified_outlined,
    Widget? icon,
    Color textColor = const Color(0xFF0090FF),
    Color? iconColor,
    Color backgroundColor = const Color(0xFFE6F4FE),
    Color? borderColor,
    bool isClickable = true,
    VoidCallback? onTap,
  }) {
    return KycStatusBadge(
      key: key,
      text: text,
      iconData: iconData,
      icon: icon,
      iconPosition: KycBadgeIconPosition.leading,
      textColor: textColor,
      iconColor: iconColor ?? textColor,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      isClickable: isClickable,
      onTap: onTap,
    );
  }

  /// 3 = Verifikasi KTP Ditolak (Merah muda dengan icon seru di kiri)
  factory KycStatusBadge.rejected({
    Key? key,
    BuildContext? context,
    String text = 'Verifikasi KTP Ditolak',
    String? descRejected,
    IconData? iconData = Icons.error_outline_rounded,
    Widget? icon,
    Color textColor = const Color(0xFFDC2626),
    Color? iconColor,
    Color backgroundColor = const Color(0xFFFEEBEC),
    Color? borderColor,
    bool isClickable = true,
    VoidCallback? onTap,
  }) {
    final effectiveOnTap = onTap ??
        (context != null && descRejected != null && isClickable
            ? () => KycRejectedBottomSheet.show(
                  context,
                  descRejected: descRejected,
                )
            : null);

    return KycStatusBadge(
      key: key,
      text: text,
      iconData: iconData,
      icon: icon,
      iconPosition: KycBadgeIconPosition.leading,
      textColor: textColor,
      iconColor: iconColor ?? textColor,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      isClickable: isClickable,
      onTap: effectiveOnTap,
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final effectiveTextColor = textColor ?? AppColors.secondaryBase;
    final effectiveIconColor = iconColor ?? effectiveTextColor;
    final effectiveBgColor =
        backgroundColor ?? effectiveTextColor.withValues(alpha: 0.1);

    Widget? iconWidget;
    if (icon != null) {
      iconWidget = icon;
    } else if (iconData != null) {
      iconWidget = Icon(
        iconData,
        size: iconSize,
        color: effectiveIconColor,
      );
    }

    final textWidget = Text(
      text,
      style: textStyle ??
          AppTypography.bodySmMedium.copyWith(
            color: effectiveTextColor,
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
    );

    final List<Widget> children = [];
    if (iconPosition == KycBadgeIconPosition.leading) {
      if (iconWidget != null) {
        children.add(iconWidget);
        children.add(SizedBox(width: spacing));
      }
      children.add(textWidget);
    } else {
      children.add(textWidget);
      if (iconWidget != null) {
        children.add(SizedBox(width: spacing));
        children.add(iconWidget);
      }
    }

    final effectiveOnTap = isClickable ? onTap : null;
    final borderRadius = BorderRadius.circular(100);

    return Material(
      color: effectiveBgColor,
      borderRadius: borderRadius,
      child: InkWell(
        onTap: effectiveOnTap,
        borderRadius: borderRadius,
        splashColor: effectiveTextColor.withValues(alpha: 0.12),
        highlightColor: effectiveTextColor.withValues(alpha: 0.08),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            border: borderColor != null
                ? Border.all(color: borderColor!, width: 1)
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: children,
          ),
        ),
      ),
    );
  }
}