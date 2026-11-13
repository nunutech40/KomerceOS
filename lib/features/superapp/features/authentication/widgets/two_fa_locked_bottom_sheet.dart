import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import 'package:url_launcher/url_launcher.dart';

/// Jenis status pembatasan OTP 2FA 24 jam.
enum TwoFaLockedVariant {
  /// Ditampilkan saat verifikasi OTP gagal 3x (`otp/verify-login` -> `lock == 1`).
  otpVerificationFailed,

  /// Ditampilkan saat akun login sudah terkunci oleh OTP 2FA (`partner/login` -> `lock == 1 && lock_source == "otp"`).
  accountRestricted,
}

/// Bottom sheet notifikasi OTP 2FA gagal 3x / akun dibatasi 24 jam.
///
/// Spesifikasi visual:
/// - Outer sheet: radius atas `30`, warna `#DCDCDC` ([AppColors.bgPopup]),
///   border `1px` putih, tombol close `(X)` lingkaran putih, dan blur backdrop.
/// - Ilustrasi existing: `assets/images/superapp/setting/failed_img.svg`.
class TwoFaLockedBottomSheet extends StatelessWidget {
  static const double _sheetRadius = 30.0;
  static const String _csUrl = 'https://partner.komerce.id/';
  static const String _illustrationAsset =
      'assets/images/superapp/setting/failed_img.svg';

  final String title;
  final String description;
  final String primaryButtonText;
  final VoidCallback? onPrimaryPressed;
  final VoidCallback? onClose;

  const TwoFaLockedBottomSheet({
    super.key,
    required this.title,
    required this.description,
    required this.primaryButtonText,
    this.onPrimaryPressed,
    this.onClose,
  });

  /// Konstruktor preset untuk kondisi salah OTP 3x saat verifikasi
  /// ("Verifikasi Kode OTP Gagal").
  const TwoFaLockedBottomSheet.otpVerificationFailed({
    super.key,
    this.title = 'Verifikasi Kode OTP Gagal',
    this.description =
        'Kode OTP salah 3 kali, silakan coba lagi\nsetelah 24 jam ke depan.',
    this.primaryButtonText = 'Mengerti',
    this.onPrimaryPressed,
    this.onClose,
  });

  /// Konstruktor preset untuk kondisi akun dibatasi 24 jam saat login
  /// ("Akun Kamu Dibatasi!").
  const TwoFaLockedBottomSheet.accountRestricted({
    super.key,
    this.title = 'Akun Kamu Dibatasi!',
    this.description =
        'Kode OTP (2FA) salah 3 kali, silakan\ncoba lagi setelah 24 jam ke depan.',
    this.primaryButtonText = 'Hubungi CS',
    this.onPrimaryPressed,
    this.onClose,
  });

  /// Menampilkan bottom sheet **"Verifikasi Kode OTP Gagal"** (`Mengerti`).
  static Future<T?> showOtpVerificationFailed<T>(
    BuildContext context, {
    VoidCallback? onPrimaryPressed,
    VoidCallback? onClose,
    bool isDismissible = true,
    Color barrierColor = Colors.black45,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: isDismissible,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: barrierColor,
      builder: (sheetContext) => TwoFaLockedBottomSheet.otpVerificationFailed(
        onPrimaryPressed: onPrimaryPressed ?? () => Navigator.pop(sheetContext),
        onClose: onClose ?? () => Navigator.pop(sheetContext),
      ),
    );
  }

  /// Menampilkan bottom sheet **"Akun Kamu Dibatasi!"** (`Hubungi CS`).
  static Future<T?> showAccountRestricted<T>(
    BuildContext context, {
    VoidCallback? onContactCs,
    VoidCallback? onClose,
    bool isDismissible = true,
    Color barrierColor = Colors.black45,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: isDismissible,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: barrierColor,
      builder: (sheetContext) => TwoFaLockedBottomSheet.accountRestricted(
        onPrimaryPressed: () async {
          Navigator.pop(sheetContext);
          if (onContactCs != null) {
            onContactCs();
            return;
          }
          await openCustomerServiceUrl();
        },
        onClose: onClose ?? () => Navigator.pop(sheetContext),
      ),
    );
  }

  /// Helper generik berdasarkan [TwoFaLockedVariant].
  static Future<T?> show<T>(
    BuildContext context, {
    required TwoFaLockedVariant variant,
    VoidCallback? onPrimaryPressed,
    VoidCallback? onClose,
    bool isDismissible = true,
    Color barrierColor = Colors.black45,
  }) {
    switch (variant) {
      case TwoFaLockedVariant.otpVerificationFailed:
        return showOtpVerificationFailed<T>(
          context,
          onPrimaryPressed: onPrimaryPressed,
          onClose: onClose,
          isDismissible: isDismissible,
          barrierColor: barrierColor,
        );
      case TwoFaLockedVariant.accountRestricted:
        return showAccountRestricted<T>(
          context,
          onContactCs: onPrimaryPressed,
          onClose: onClose,
          isDismissible: isDismissible,
          barrierColor: barrierColor,
        );
    }
  }

  static Future<void> openCustomerServiceUrl() async {
    final Uri url = Uri.parse(_csUrl);
    if (!await launchUrl(url)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveOnClose =
        onClose ?? () => Navigator.of(context).pop();
    final effectiveOnPrimary =
        onPrimaryPressed ?? () => Navigator.of(context).pop();

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pageMargin2xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.bgPopup,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(_sheetRadius),
            topRight: Radius.circular(_sheetRadius),
          ),
          border: Border.all(
            color: AppColors.alwaysWhite,
            width: 1,
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
              children: [
                // ── Header Title + Close Button (X)
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 44),
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: AppTypography.headingMd.copyWith(
                          color: AppColors.grey900,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: effectiveOnClose,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: const BoxDecoration(
                            color: AppColors.alwaysWhite,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
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
                  description,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMdRegular.copyWith(
                    color: AppColors.grey700,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // ── Illustration
                SvgPicture.asset(
                  _illustrationAsset,
                  height: 220,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: AppSpacing.xl),

                // ── Primary CTA Button
                DsButton(
                  text: primaryButtonText,
                  borderRadius: AppRadius.md2,
                  onPressed: effectiveOnPrimary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

