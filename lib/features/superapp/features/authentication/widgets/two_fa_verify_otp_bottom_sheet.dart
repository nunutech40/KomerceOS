import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import 'package:komtim_partner/features/superapp/features/authentication/widgets/two_fa_method_bottom_sheet.dart'
    show TwoFaMethodType;

/// Bottom sheet input & verifikasi kode OTP 2FA ("Verifikasi Kode OTP").
///
/// Spesifikasi visual:
/// - Outer sheet: radius atas `30`, warna `#DCDCDC` ([AppColors.bgPopup]),
///   border `1px` putih, tombol close `(X)` lingkaran putih, dan blur backdrop.
/// - Input OTP: 6 digit format 3–3 putih (`#FFFFFF`) dengan pemisah strip
///   serta focus ring abu-abu.
/// - Mendukung semua state UI 2FA:
///   1. Countdown aktif (`Kirim Ulang (59s)` & `Gunakan Metode Lain (59s)`).
///   2. Countdown selesai (`Kirim Ulang` oranye, `Gunakan Metode Lain` merah).
///   3. Error salah OTP (`Kode OTP yang kamu masukkan salah.\nTersisa X kali percobaan.`).
///   4. Limit request OTP terlampaui (`otpLimitExceeded`).
///   5. Sesi berakhir (`Sesi telah berakhir, silahkan coba lagi`).
class TwoFaVerifyOtpBottomSheet extends StatefulWidget {
  /// Metode pengiriman OTP yang dipilih (`email`, `whatsapp`, `sms`).
  final TwoFaMethodType methodType;

  /// Target tujuan OTP (masked/raw email atau nomor HP).
  final String target;

  /// Controller opsional untuk mengelola nilai 6-digit OTP dari parent.
  final TextEditingController? controller;

  /// Durasi awal countdown dalam detik (misal `59` atau `expiresIn` dari API).
  final int initialCountdownSeconds;

  /// Ubah nilainya untuk mereset & memulai ulang countdown dari parent.
  final int countdownKey;

  /// Pesan error kustom di bawah kotak OTP (misal kesalahan jaringan/validasi).
  final String? errorMessage;

  /// Sisa percobaan OTP salah; otomatis memformat pesan error jika
  /// [errorMessage] bernilai `null`.
  final int? attemptsLeft;

  /// Menandakan request kirim ulang OTP sudah mencapai batas maksimal.
  final bool otpLimitExceeded;

  /// Menandakan sesi token verifikasi OTP sudah kedaluwarsa.
  final bool isSessionExpired;

  /// Menandakan input OTP dikunci (misal setelah salah 3x).
  final bool isLocked;

  /// Menampilkan loading state pada tombol konfirmasi.
  final bool isLoading;

  /// Menampilkan state sedang mengirim ulang OTP pada aksi "Kirim Ulang".
  final bool isResending;

  /// Apakah kotak digit pertama langsung memfokuskan keyboard saat dibuka.
  final bool autoFocusOtp;

  /// Label tombol utama (default `'Konfirmasi'`).
  final String confirmButtonText;

  /// Callback setiap nilai OTP berubah.
  final ValueChanged<String>? onChanged;

  /// Callback saat tombol konfirmasi ditekan dengan 6 digit OTP.
  final ValueChanged<String>? onConfirm;

  /// Callback saat "Kirim Ulang" ditekan (ketika countdown selesai).
  final VoidCallback? onResend;

  /// Callback saat "Gunakan Metode Lain" ditekan.
  final VoidCallback? onChangeMethod;

  /// Callback saat tombol close `(X)` ditekan. Defaults ke [Navigator.pop].
  final VoidCallback? onClose;

  const TwoFaVerifyOtpBottomSheet({
    super.key,
    required this.methodType,
    required this.target,
    this.controller,
    this.initialCountdownSeconds = 59,
    this.countdownKey = 0,
    this.errorMessage,
    this.attemptsLeft,
    this.otpLimitExceeded = false,
    this.isSessionExpired = false,
    this.isLocked = false,
    this.isLoading = false,
    this.isResending = false,
    this.autoFocusOtp = false,
    this.confirmButtonText = 'Konfirmasi',
    this.onChanged,
    this.onConfirm,
    this.onResend,
    this.onChangeMethod,
    this.onClose,
  });

  /// Helper statis untuk menampilkan bottom sheet "Verifikasi Kode OTP".
  static Future<T?> show<T>(
    BuildContext context, {
    required TwoFaMethodType methodType,
    required String target,
    TextEditingController? controller,
    int initialCountdownSeconds = 59,
    int countdownKey = 0,
    String? errorMessage,
    int? attemptsLeft,
    bool otpLimitExceeded = false,
    bool isSessionExpired = false,
    bool isLocked = false,
    bool autoFocusOtp = false,
    String confirmButtonText = 'Konfirmasi',
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onConfirm,
    VoidCallback? onResend,
    VoidCallback? onChangeMethod,
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
      builder: (sheetContext) => TwoFaVerifyOtpBottomSheet(
        methodType: methodType,
        target: target,
        controller: controller,
        initialCountdownSeconds: initialCountdownSeconds,
        countdownKey: countdownKey,
        errorMessage: errorMessage,
        attemptsLeft: attemptsLeft,
        otpLimitExceeded: otpLimitExceeded,
        isSessionExpired: isSessionExpired,
        isLocked: isLocked,
        autoFocusOtp: autoFocusOtp,
        confirmButtonText: confirmButtonText,
        onChanged: onChanged,
        onConfirm: onConfirm,
        onResend: onResend,
        onChangeMethod: onChangeMethod,
        onClose: onClose ?? () => Navigator.pop(sheetContext),
      ),
    );
  }

  @override
  State<TwoFaVerifyOtpBottomSheet> createState() =>
      _TwoFaVerifyOtpBottomSheetState();
}

class _TwoFaVerifyOtpBottomSheetState extends State<TwoFaVerifyOtpBottomSheet> {
  static const double _sheetRadius = 30.0;

  late TextEditingController _otpController;
  late bool _ownsController;
  Timer? _countdownTimer;
  int _secondsRemaining = 0;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _otpController = widget.controller ?? TextEditingController();
    _syncCountdownFromProps();
  }

  @override
  void didUpdateWidget(covariant TwoFaVerifyOtpBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller != oldWidget.controller) {
      if (_ownsController) {
        _otpController.dispose();
      }
      _ownsController = widget.controller == null;
      _otpController = widget.controller ?? TextEditingController();
    }

    if (widget.isSessionExpired || widget.otpLimitExceeded || widget.isLocked) {
      _stopCountdown();
    } else if (widget.countdownKey != oldWidget.countdownKey ||
        widget.initialCountdownSeconds != oldWidget.initialCountdownSeconds) {
      _syncCountdownFromProps();
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    if (_ownsController) {
      _otpController.dispose();
    }
    super.dispose();
  }

  void _syncCountdownFromProps() {
    if (widget.isSessionExpired || widget.otpLimitExceeded || widget.isLocked) {
      _stopCountdown();
      return;
    }

    if (widget.initialCountdownSeconds > 0) {
      _startCountdown(widget.initialCountdownSeconds);
    } else {
      _stopCountdown();
    }
  }

  void _startCountdown(int seconds) {
    _countdownTimer?.cancel();
    if (!mounted) return;

    setState(() {
      _secondsRemaining = seconds;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsRemaining > 1) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
        setState(() {
          _secondsRemaining = 0;
        });
      }
    });
  }

  void _stopCountdown() {
    _countdownTimer?.cancel();
    if (mounted && _secondsRemaining != 0) {
      setState(() {
        _secondsRemaining = 0;
      });
    } else {
      _secondsRemaining = 0;
    }
  }

  String get _subtitleText {
    switch (widget.methodType) {
      case TwoFaMethodType.email:
        return 'Masukkan Kode OTP yang kami\nkirimkan ke email\n${widget.target}';
      case TwoFaMethodType.whatsapp:
        return 'Masukkan Kode OTP WhatsApp yang kami\nkirimkan ke ${widget.target}';
      case TwoFaMethodType.sms:
        return 'Masukkan Kode OTP SMS yang kami\nkirimkan ke ${widget.target}';
    }
  }

  String? get _effectiveOtpError {
    if (widget.errorMessage != null && widget.errorMessage!.trim().isNotEmpty) {
      return widget.errorMessage;
    }
    if (widget.attemptsLeft != null) {
      return 'Kode OTP yang kamu masukkan salah.\nTersisa ${widget.attemptsLeft} kali percobaan.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final bool isBusy = widget.isLoading || widget.isResending;
    final bool isInputEnabled =
        !widget.isSessionExpired && !widget.isLocked && !isBusy;
    final bool hasCountdown = _secondsRemaining > 0 &&
        !widget.isSessionExpired &&
        !widget.otpLimitExceeded;
    final bool canResend = !widget.isSessionExpired &&
        !widget.otpLimitExceeded &&
        !widget.isLocked &&
        !hasCountdown &&
        !isBusy;
    final bool canChangeMethod =
        !widget.isSessionExpired && !hasCountdown && !isBusy;

    final effectiveOnClose =
        widget.onClose ?? () => Navigator.of(context).pop();
    final String? otpError = _effectiveOtpError;
    final double bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return PopScope(
      canPop: !isBusy,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(bottom: bottomInset),
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
                            'Verifikasi Kode OTP',
                            textAlign: TextAlign.center,
                            style: AppTypography.headingMd.copyWith(
                              color: AppColors.grey900,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: isBusy ? null : effectiveOnClose,
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

                    // ── Subtitle Method & Target
                    Text(
                      _subtitleText,
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMdRegular.copyWith(
                        color: AppColors.grey700,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // ── 6-Digit Grouped OTP Field (3 — 3)
                    _TwoFaOtpField(
                      controller: _otpController,
                      isEnabled: isInputEnabled,
                      autoFocus: widget.autoFocusOtp,
                      onChanged: widget.onChanged,
                    ),

                    // ── Wrong OTP Error Message
                    if (otpError != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        otpError,
                        textAlign: TextAlign.center,
                        style: AppTypography.bodySmRegular.copyWith(
                          color: AppColors.errorBase,
                          height: 1.4,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg3),

                    // ── Resend Action / Countdown
                    _buildResendAction(
                      hasCountdown: hasCountdown,
                      canResend: canResend,
                    ),

                    // ── Session Expired / OTP Limit Notice
                    if (widget.isSessionExpired) ...[
                      const SizedBox(height: AppSpacing.md3),
                      Text(
                        'Sesi telah berakhir, silahkan coba lagi',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodySmRegular.copyWith(
                          color: AppColors.errorBase,
                        ),
                      ),
                    ] else if (widget.otpLimitExceeded) ...[
                      const SizedBox(height: AppSpacing.md3),
                      Text(
                        'Request OTP sudah mencapai batas.',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodySmRegular.copyWith(
                          color: AppColors.errorBase,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg3),

                    // ── Change Method Action / Countdown
                    _buildChangeMethodAction(
                      hasCountdown: hasCountdown,
                      canChangeMethod: canChangeMethod,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // ── Confirm Primary Button
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _otpController,
                      builder: (context, value, _) {
                        final bool isOtpComplete = value.text.length == 6;
                        final bool canConfirm = isOtpComplete &&
                            !widget.isSessionExpired &&
                            !widget.isLocked &&
                            !widget.isResending;

                        return DsButton(
                          text: widget.confirmButtonText,
                            loadingText: 'Memverifikasi...',
                          borderRadius: AppRadius.md2,
                          disabledBackgroundColor:
                              AppColors.primaryBase.withValues(alpha: 0.5),
                          state: widget.isLoading
                              ? DsButtonState.loading
                              : (canConfirm
                                  ? DsButtonState.enabled
                                  : DsButtonState.disabled),
                          onPressed: () {
                            if (canConfirm && !widget.isLoading) {
                              widget.onConfirm?.call(_otpController.text);
                            }
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResendAction({
    required bool hasCountdown,
    required bool canResend,
  }) {
    if (widget.isResending) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBase),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Mengirim ulang...',
            style: AppTypography.bodyMdMedium.copyWith(
              color: AppColors.primaryBase,
            ),
          ),
        ],
      );
    }

    if (hasCountdown) {
      return Text.rich(
        TextSpan(
          text: 'Kirim Ulang ',
          style: AppTypography.bodyMdMedium.copyWith(
            color: AppColors.grey700,
          ),
          children: [
            TextSpan(
              text: '(${_secondsRemaining}s)',
              style: AppTypography.bodyMdMedium.copyWith(
                color: AppColors.primaryBase,
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      );
    }

    return GestureDetector(
      onTap: canResend ? widget.onResend : null,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Text(
          'Kirim Ulang',
          textAlign: TextAlign.center,
          style: AppTypography.bodyMdMedium.copyWith(
            color: canResend ? AppColors.primaryBase : AppColors.grey600,
          ),
        ),
      ),
    );
  }

  Widget _buildChangeMethodAction({
    required bool hasCountdown,
    required bool canChangeMethod,
  }) {
    if (hasCountdown) {
      return Text.rich(
        TextSpan(
          text: 'Gunakan Metode Lain ',
          style: AppTypography.bodyMdMedium.copyWith(
            color: AppColors.errorBase,
          ),
          children: [
            TextSpan(
              text: '(${_secondsRemaining}s)',
              style: AppTypography.bodyMdMedium.copyWith(
                color: AppColors.grey900,
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      );
    }

    final Color textColor = widget.isSessionExpired
        ? AppColors.errorBase.withValues(alpha: 0.45)
        : (canChangeMethod
            ? AppColors.errorBase
            : AppColors.errorBase.withValues(alpha: 0.45));

    return GestureDetector(
      onTap: canChangeMethod ? widget.onChangeMethod : null,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Text(
          'Gunakan Metode Lain',
          textAlign: TextAlign.center,
          style: AppTypography.bodyMdMedium.copyWith(
            color: textColor,
          ),
        ),
      ),
    );
  }
}

/// Input 6 digit OTP dengan layout 3–3 box putih di atas permukaan `#DCDCDC`.
class _TwoFaOtpField extends StatefulWidget {
  final TextEditingController controller;
  final bool isEnabled;
  final bool autoFocus;
  final ValueChanged<String>? onChanged;

  const _TwoFaOtpField({
    required this.controller,
    this.isEnabled = true,
    this.autoFocus = false,
    this.onChanged,
  });

  @override
  State<_TwoFaOtpField> createState() => _TwoFaOtpFieldState();
}

class _TwoFaOtpFieldState extends State<_TwoFaOtpField> {
  static const int _length = 6;
  static const double _boxSize = 40.0;
  static const Color _groupBorderColor = Color(0xFFE5E5E5);

  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  late final List<FocusNode> _keyboardNodes;
  Timer? _autofocusRetry;

  String get _currentOtp => _controllers.map((c) => c.text).join();

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_length, (_) => TextEditingController());
    _focusNodes = List.generate(_length, (_) => FocusNode());
    _keyboardNodes = List.generate(_length, (_) => FocusNode());

    widget.controller.addListener(_syncFromParent);
    if (widget.controller.text.isNotEmpty) {
      _syncFromParent();
    }

    if (widget.autoFocus && widget.isEnabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _focusNodes.first.requestFocus();
        _autofocusRetry = Timer(const Duration(milliseconds: 350), () {
          if (mounted &&
              widget.isEnabled &&
              !_focusNodes.any((node) => node.hasFocus)) {
            _focusNodes.first.requestFocus();
          }
        });
      });
    }
  }

  @override
  void didUpdateWidget(covariant _TwoFaOtpField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeListener(_syncFromParent);
      widget.controller.addListener(_syncFromParent);
      _syncFromParent();
    }
    if (!widget.isEnabled) {
      for (final node in _focusNodes) {
        if (node.hasFocus) node.unfocus();
      }
    }
  }

  @override
  void dispose() {
    _autofocusRetry?.cancel();
    widget.controller.removeListener(_syncFromParent);
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    for (final k in _keyboardNodes) {
      k.dispose();
    }
    super.dispose();
  }

  void _syncFromParent() {
    final parentText = widget.controller.text;
    if (parentText != _currentOtp) {
      for (int i = 0; i < _length; i++) {
        final char = i < parentText.length ? parentText[i] : '';
        if (_controllers[i].text != char) {
          _controllers[i].text = char;
        }
      }
    }
  }

  void _notifyChanged() {
    final otp = _currentOtp;
    if (widget.controller.text != otp) {
      widget.controller.text = otp;
    }
    widget.onChanged?.call(otp);
  }

  void _handleChanged(int index, String value) {
    if (value.length > 1) {
      _handlePaste(value);
      return;
    }

    if (value.isNotEmpty && index < _length - 1) {
      _focusNodes[index + 1].requestFocus();
    }

    _notifyChanged();
  }

  void _handlePaste(String pastedText) {
    final digits = pastedText.replaceAll(RegExp(r'[^0-9]'), '');
    for (int i = 0; i < _length; i++) {
      _controllers[i].text = i < digits.length ? digits[i] : '';
    }
    final focusIndex =
        digits.length >= _length ? _length - 1 : digits.length;
    _focusNodes[focusIndex.clamp(0, _length - 1)].requestFocus();
    _notifyChanged();
  }

  void _handleKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_controllers[index].text.isEmpty && index > 0) {
        _controllers[index - 1].clear();
        _focusNodes[index - 1].requestFocus();
        _notifyChanged();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildGroup(0, 3),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md3),
            child: SizedBox(
              width: 18,
              child: Divider(
                color: AppColors.grey700,
                thickness: 1.5,
              ),
            ),
          ),
          _buildGroup(3, 6),
        ],
      ),
    );
  }

  Widget _buildGroup(int startIndex, int endIndex) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.alwaysWhite,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: _groupBorderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = startIndex; i < endIndex; i++) ...[
            if (i != startIndex)
              Container(
                width: 1,
                height: _boxSize,
                color: AppColors.grey200,
              ),
            _buildDigitBox(
              i,
              isGroupStart: i == startIndex,
              isGroupEnd: i == endIndex - 1,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDigitBox(
    int index, {
    required bool isGroupStart,
    required bool isGroupEnd,
  }) {
    return ListenableBuilder(
      listenable: Listenable.merge([_focusNodes[index], _controllers[index]]),
      builder: (context, _) {
        final bool hasFocus = widget.isEnabled && _focusNodes[index].hasFocus;
        final String displayText = _controllers[index].text;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: _boxSize,
          height: _boxSize,
          decoration: BoxDecoration(
            color: AppColors.alwaysWhite,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(
                (isGroupStart || hasFocus) ? AppRadius.md : AppRadius.none,
              ),
              bottomLeft: Radius.circular(
                (isGroupStart || hasFocus) ? AppRadius.md : AppRadius.none,
              ),
              topRight: Radius.circular(
                (isGroupEnd || hasFocus) ? AppRadius.md : AppRadius.none,
              ),
              bottomRight: Radius.circular(
                (isGroupEnd || hasFocus) ? AppRadius.md : AppRadius.none,
              ),
            ),
            border: Border.all(
              color: hasFocus ? AppColors.borderColor : AppColors.transparent,
              width: hasFocus ? 1.5 : 0,
            ),
            boxShadow: hasFocus
                ? const [
                    BoxShadow(
                      color: AppColors.focusRingShadow,
                      blurRadius: 0,
                      spreadRadius: 3,
                    ),
                  ]
                : const [],
          ),
          child: KeyboardListener(
            focusNode: _keyboardNodes[index],
            onKeyEvent: (event) => _handleKeyEvent(index, event),
            child: Stack(
              alignment: Alignment.center,
              children: [
                IgnorePointer(
                  child: Text(
                    displayText,
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyLgMedium.copyWith(
                      color: widget.isEnabled
                          ? AppColors.black
                          : AppColors.grey700,
                    ),
                  ),
                ),
                TextField(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  enabled: widget.isEnabled,
                  autofocus: widget.autoFocus && widget.isEnabled && index == 0,
                  textAlign: TextAlign.center,
                  textAlignVertical: TextAlignVertical.center,
                  keyboardType: TextInputType.number,
                  autofillHints: index == 0
                      ? const [AutofillHints.oneTimeCode]
                      : null,
                  cursorColor: widget.isEnabled
                      ? AppColors.grey800
                      : AppColors.transparent,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _TwoFaOtpInputFormatter(),
                  ],
                  style: AppTypography.bodyLgMedium.copyWith(
                    color: Colors.transparent,
                  ),
                  decoration: const InputDecoration(
                    counterText: '',
                    isCollapsed: true,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (value) => _handleChanged(index, value),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TwoFaOtpInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    if (newValue.text.length - oldValue.text.length > 1) {
      return newValue;
    }

    if (newValue.text.length > 1 && oldValue.text.isNotEmpty) {
      final newChar = newValue.text.characters.last;
      return TextEditingValue(
        text: newChar,
        selection: const TextSelection.collapsed(offset: 1),
      );
    }

    return newValue;
  }
}

