import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';

/// Jenis metode verifikasi 2FA yang tersedia saat login.
enum TwoFaMethodType {
  email,
  whatsapp,
  sms;

  String get apiValue {
    switch (this) {
      case TwoFaMethodType.email:
        return 'email';
      case TwoFaMethodType.whatsapp:
        return 'whatsapp';
      case TwoFaMethodType.sms:
        return 'sms';
    }
  }

  String get defaultTitle {
    switch (this) {
      case TwoFaMethodType.email:
        return 'Email ke';
      case TwoFaMethodType.whatsapp:
        return 'WhatsApp Kode OTP ke';
      case TwoFaMethodType.sms:
        return 'SMS Kode OTP ke';
    }
  }
}

/// Item opsi metode 2FA yang ditampilkan pada [TwoFaMethodBottomSheet].
class TwoFaMethodOption {
  final TwoFaMethodType type;
  final String title;
  final String value;
  final bool enabled;

  const TwoFaMethodOption({
    required this.type,
    required this.title,
    required this.value,
    this.enabled = true,
  });
}

/// Bottom sheet pemilihan metode pengiriman OTP 2FA ("Kirim Verifikasi OTP").
///
/// Spesifikasi visual:
/// - Outer sheet: radius atas `30`, warna `#DCDCDC` ([AppColors.bgPopup]),
///   border `1px` putih, dan efek blur backdrop.
/// - Card metode: putih (`#FFFFFF`), border `1px` `#E5E5E5`; saat dipilih
///   berubah menjadi `#FFF4ED` dengan border `#E5E5E5`.
/// - Menggunakan asset icon existing (`ic_email_two_fa.svg`, `ic_wa_two_fa.svg`,
///   `ic_message_two_fa.svg`).
class TwoFaMethodBottomSheet extends StatefulWidget {
  /// Email tujuan (masked atau raw) untuk membangun opsi Email otomatis
  /// ketika [methods] tidak diisi manual.
  final String? email;

  /// Nomor HP tujuan (masked atau raw) untuk membangun opsi WhatsApp & SMS
  /// otomatis ketika [methods] tidak diisi manual.
  final String? phone;

  /// Daftar opsi metode 2FA kustom. Jika `null`, daftar dibangun dari
  /// [email] dan [phone] yang tidak kosong.
  final List<TwoFaMethodOption>? methods;

  /// Menandakan user telah mencapai batas request OTP.
  final bool otpLimitExceeded;

  /// Metode awal yang terpilih saat bottom sheet dibuka (opsional).
  final TwoFaMethodType? initialSelectedType;

  /// Menampilkan loading state pada tombol "Konfirmasi".
  final bool isLoading;

  /// Pesan error aksi (misalnya gagal request OTP / reCAPTCHA).
  final String? errorMessage;

  /// Callback saat user menekan tombol "Konfirmasi" dengan metode terpilih.
  final ValueChanged<TwoFaMethodOption>? onConfirm;

  /// Callback saat user menekan tombol "Batal". Defaults ke [Navigator.pop].
  final VoidCallback? onCancel;

  /// Callback saat user menekan tombol close (X). Defaults ke [onCancel] atau [Navigator.pop].
  final VoidCallback? onClose;

  const TwoFaMethodBottomSheet({
    super.key,
    this.email,
    this.phone,
    this.methods,
    this.otpLimitExceeded = false,
    this.initialSelectedType,
    this.isLoading = false,
    this.errorMessage,
    this.onConfirm,
    this.onCancel,
    this.onClose,
  });

  /// Helper statis untuk menampilkan bottom sheet "Kirim Verifikasi OTP".
  static Future<T?> show<T>(
    BuildContext context, {
    String? email,
    String? phone,
    List<TwoFaMethodOption>? methods,
    bool otpLimitExceeded = false,
    TwoFaMethodType? initialSelectedType,
    bool isLoading = false,
    String? errorMessage,
    ValueChanged<TwoFaMethodOption>? onConfirm,
    VoidCallback? onCancel,
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
      builder: (sheetContext) => TwoFaMethodBottomSheet(
        email: email,
        phone: phone,
        methods: methods,
        otpLimitExceeded: otpLimitExceeded,
        initialSelectedType: initialSelectedType,
        isLoading: isLoading,
        errorMessage: errorMessage,
        onConfirm: onConfirm,
        onCancel: onCancel ?? () => Navigator.pop(sheetContext),
        onClose: onClose ?? onCancel ?? () => Navigator.pop(sheetContext),
      ),
    );
  }

  /// Helper opsional untuk menyusun daftar metode dari `email` dan `phone`.
  static List<TwoFaMethodOption> buildDefaultMethods({
    String? email,
    String? phone,
    bool otpLimitExceeded = false,
  }) {
    final bool enabled = !otpLimitExceeded;
    final List<TwoFaMethodOption> result = [];

    if (email != null && email.trim().isNotEmpty) {
      result.add(
        TwoFaMethodOption(
          type: TwoFaMethodType.email,
          title: TwoFaMethodType.email.defaultTitle,
          value: email.trim(),
          enabled: enabled,
        ),
      );
    }

    if (phone != null && phone.trim().isNotEmpty) {
      final cleanPhone = phone.trim();
      result.add(
        TwoFaMethodOption(
          type: TwoFaMethodType.whatsapp,
          title: TwoFaMethodType.whatsapp.defaultTitle,
          value: cleanPhone,
          enabled: enabled,
        ),
      );
      result.add(
        TwoFaMethodOption(
          type: TwoFaMethodType.sms,
          title: TwoFaMethodType.sms.defaultTitle,
          value: cleanPhone,
          enabled: enabled,
        ),
      );
    }

    return result;
  }

  @override
  State<TwoFaMethodBottomSheet> createState() => _TwoFaMethodBottomSheetState();
}

class _TwoFaMethodBottomSheetState extends State<TwoFaMethodBottomSheet> {
  static const double _sheetRadius = 30.0;
  static const Color _selectedCardColor = Color(0xFFFFF4ED);
  static const Color _cardBorderColor = Color(0xFFE5E5E5);

  TwoFaMethodType? _selectedType;

  List<TwoFaMethodOption> get _effectiveMethods =>
      widget.methods ??
      TwoFaMethodBottomSheet.buildDefaultMethods(
        email: widget.email,
        phone: widget.phone,
        otpLimitExceeded: widget.otpLimitExceeded,
      );

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialSelectedType;
  }

  @override
  Widget build(BuildContext context) {
    final methods = _effectiveMethods;
    final TwoFaMethodOption? selectedOption = _resolveSelectedOption(methods);
    final bool canConfirm =
        !widget.otpLimitExceeded && !widget.isLoading && selectedOption != null;

    final effectiveOnCancel =
        widget.onCancel ?? () => Navigator.of(context).pop();
    final effectiveOnClose = widget.onClose ?? effectiveOnCancel;

    return PopScope(
      canPop: !widget.isLoading,
      child: BackdropFilter(
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
                          'Kirim Verifikasi OTP',
                          textAlign: TextAlign.center,
                          style: AppTypography.headingMd.copyWith(
                            color: AppColors.grey900,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: widget.isLoading ? null : effectiveOnClose,
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

                  // ── Subtitle
                  Text(
                    'Pilih salah satu metode 2FA di bawah ini\nuntuk mendapatkan kode verifikasi.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMdRegular.copyWith(
                      color: AppColors.grey700,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Method Options
                  for (int i = 0; i < methods.length; i++) ...[
                    _TwoFaMethodCard(
                      option: methods[i],
                      isSelected: selectedOption?.type == methods[i].type,
                      selectedColor: _selectedCardColor,
                      borderColor: _cardBorderColor,
                      onTap: (methods[i].enabled && !widget.isLoading)
                          ? () {
                              setState(() {
                                _selectedType = methods[i].type;
                              });
                            }
                          : null,
                    ),
                    if (i < methods.length - 1)
                      const SizedBox(height: AppSpacing.md3),
                  ],

                  // ── OTP Limit Exceeded / Error Message
                  if (widget.otpLimitExceeded) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Request OTP sudah mencapai batas.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySmMedium.copyWith(
                        color: AppColors.errorBase,
                      ),
                    ),
                  ] else if (widget.errorMessage != null &&
                      widget.errorMessage!.trim().isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      widget.errorMessage!.trim(),
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySmMedium.copyWith(
                        color: AppColors.errorBase,
                      ),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.lg),

                  // ── Cancel Text Button
                  TextButton(
                    onPressed: widget.isLoading ? null : effectiveOnCancel,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.errorBase,
                      textStyle: AppTypography.bodyMdMedium,
                      minimumSize: const Size(
                        double.infinity,
                        AppSpacing.touchSm,
                      ),
                    ),
                    child: const Text('Batal'),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // ── Confirm Primary Button
                  DsButton(
                    text: 'Konfirmasi',
                    loadingText: 'Memproses...',
                    borderRadius: AppRadius.md2,
                    disabledBackgroundColor:
                        AppColors.primaryBase.withValues(alpha: 0.5),
                    state: widget.isLoading
                        ? DsButtonState.loading
                        : (canConfirm
                            ? DsButtonState.enabled
                            : DsButtonState.disabled),
                    onPressed: () {
                      if (selectedOption != null) {
                        widget.onConfirm?.call(selectedOption);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  TwoFaMethodOption? _resolveSelectedOption(List<TwoFaMethodOption> methods) {
    if (_selectedType == null) return null;
    for (final method in methods) {
      if (method.type == _selectedType && method.enabled) {
        return method;
      }
    }
    return null;
  }
}

class _TwoFaMethodCard extends StatelessWidget {
  final TwoFaMethodOption option;
  final bool isSelected;
  final Color selectedColor;
  final Color borderColor;
  final VoidCallback? onTap;

  const _TwoFaMethodCard({
    required this.option,
    required this.isSelected,
    required this.selectedColor,
    required this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = !option.enabled;
    final Color cardBackground = isDisabled
        ? AppColors.alwaysWhite.withValues(alpha: 0.5)
        : (isSelected ? selectedColor : AppColors.alwaysWhite);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md2,
          vertical: AppSpacing.md3,
        ),
        decoration: BoxDecoration(
          color: cardBackground,
          borderRadius: BorderRadius.circular(AppRadius.md2),
          border: Border.all(
            color: borderColor,
            width: 1,
          ),
          boxShadow: isDisabled
              ? const []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Opacity(
          opacity: isDisabled ? 0.48 : 1.0,
          child: Row(
            children: [
              _MethodIconBox(type: option.type),
              const SizedBox(width: AppSpacing.md3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      option.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyMdMedium.copyWith(
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      option.value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmRegular.copyWith(
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MethodIconBox extends StatelessWidget {
  final TwoFaMethodType type;

  const _MethodIconBox({
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final Color containerColor = switch (type) {
      TwoFaMethodType.email => AppColors.cardBgFFF7ED,
      TwoFaMethodType.whatsapp => AppColors.successLight,
      TwoFaMethodType.sms => AppColors.cardBgFFF7ED,
    };

    final Widget iconWidget = switch (type) {
      TwoFaMethodType.email => SvgPicture.asset(
          'assets/images/superapp/auth/ic_email_two_fa.svg',
          width: 20,
          height: 20,
          fit: BoxFit.contain,
        ),
      TwoFaMethodType.whatsapp => SvgPicture.asset(
          'assets/images/superapp/auth/ic_wa_two_fa.svg',
          width: 20,
          height: 20,
          fit: BoxFit.contain,
        ),
      TwoFaMethodType.sms => SvgPicture.asset(
          'assets/images/superapp/auth/ic_message_two_fa.svg',
          width: 20,
          height: 20,
          fit: BoxFit.contain,
        ),
    };

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      alignment: Alignment.center,
      child: iconWidget,
    );
  }
}

