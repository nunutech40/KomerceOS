import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';

/// # KycOutlinedButton (Alias: [KycVerificationButton], [KycActionButton])
///
/// Tombol outlined reusable dengan border dan teks oranye, dilengkapi ikon panah serong
/// kanan-atas (`Icons.arrow_outward_rounded` ↗).
///
/// ### 📌 Kapan Digunakan:
/// - Digunakan sebagai Call-to-Action (CTA) utama pada kartu status KYC di Home (`BalanceSection`)
///   atau halaman Pengaturan Akun (`SettingKycStatusSection`).
/// - Contoh label: "Ajukan Verifikasi KTP ↗", "Lanjutkan Verifikasi ↗", atau "Ajukan Ulang ↗".
///
/// ### 🔄 Alur & Posisi dalam User Journey:
/// - Ketika status akun user adalah 0 (Belum Verifikasi) atau 5 (Paid / Belum Lengkapi Dokumen),
///   tombol ini ditekan untuk membuka [KycVerificationBottomSheet.show] atau [KycIdentityBottomSheet.show].
///
/// ### 💻 Contoh Penggunaan:
/// ```dart
/// KycOutlinedButton(
///   text: 'Ajukan Verifikasi KTP',
///   onPressed: () {
///     KycVerificationBottomSheet.show(context, parentContext: context);
///   },
/// )
/// ```
///
/// ### ⚙️ Parameter Utama:
/// - [text] : Teks tombol (wajib).
/// - [onPressed] / [onClick] : Callback saat tombol ditekan (mendukung kedua nama parameter).
/// - [icon] : Ikon pendamping di sebelah kanan teks (default: `Icons.arrow_outward_rounded`).
/// - [showIcon] : Menentukan apakah ikon ditampilkan (default: `true`).
/// - [color] : Warna teks, ikon, dan border (default: `AppColors.primaryBase`).
/// - [backgroundColor] : Background tombol (default: `AppColors.surface`).
/// - [width], [height] : Dimensi tombol (default width: full width / `double.infinity`, height: `48.0`).
class KycOutlinedButton extends StatelessWidget {
  /// Teks tombol
  final String text;

  /// Callback saat tombol ditekan
  final VoidCallback? onClick;

  /// Alias callback [onClick]
  final VoidCallback? onPressed;

  /// Ikon di sebelah kanan teks (default: [Icons.arrow_outward_rounded])
  final IconData? icon;

  /// Menampilkan ikon atau tidak (default: true)
  final bool showIcon;

  /// Warna teks, ikon, dan border (default: [AppColors.primaryBase])
  final Color? color;

  /// Warna background tombol (default: putih/surface)
  final Color? backgroundColor;

  /// Warna border (opsional, jika ingin beda dari [color])
  final Color? borderColor;

  /// Ketebalan border (default: 1.0)
  final double borderWidth;

  /// Tinggi tombol (default: 48.0)
  final double height;

  /// Lebar tombol (default: double.infinity / full width)
  final double? width;

  /// Radius sudut tombol (default: 10.0)
  final double borderRadius;

  /// Ukuran ikon (default: 16.0)
  final double iconSize;

  /// Jarak antara teks dan ikon (default: 6.0)
  final double iconSpacing;

  /// Custom TextStyle (opsional)
  final TextStyle? textStyle;

  /// Custom padding (opsional)
  final EdgeInsetsGeometry? padding;

  /// Status aktif/disabled tombol
  final bool enabled;

  const KycOutlinedButton({
    super.key,
    required this.text,
    this.onClick,
    this.onPressed,
    this.icon = Icons.arrow_outward_rounded,
    this.showIcon = true,
    this.color,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.0,
    this.height = 48.0,
    this.width = double.infinity,
    this.borderRadius = 10.0,
    this.iconSize = 16.0,
    this.iconSpacing = 6.0,
    this.textStyle,
    this.padding,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.primaryBase;
    final effectiveOnClick = enabled ? (onClick ?? onPressed) : null;

    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: textStyle ??
              AppTypography.bodyMdSemiBold.copyWith(
                color: effectiveColor,
                fontWeight: FontWeight.w600,
              ),
        ),
        if (showIcon && icon != null) ...[
          SizedBox(width: iconSpacing),
          Icon(
            icon,
            size: iconSize,
            color: effectiveColor,
          ),
        ],
      ],
    );

    return SizedBox(
      width: width,
      height: height,
      child: OutlinedButton(
        onPressed: effectiveOnClick,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.surface,
          foregroundColor: effectiveColor,
          disabledForegroundColor: AppColors.grey400,
          disabledBackgroundColor: AppColors.grey100,
          side: BorderSide(
            color: enabled
                ? (borderColor ?? effectiveColor)
                : AppColors.grey300,
            width: borderWidth,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
          elevation: 0,
        ),
        child: child,
      ),
    );
  }
}

// =============================================================================
// Aliases for convenience
// =============================================================================
typedef KycActionButton = KycOutlinedButton;
typedef KycVerificationButton = KycOutlinedButton;
