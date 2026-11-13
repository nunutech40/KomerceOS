import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import 'package:komtim_partner/features/superapp/features/authentication/widgets/email_check_header.dart';
import 'package:komtim_partner/features/superapp/features/authentication/widgets/two_fa_locked_bottom_sheet.dart';
import 'package:komtim_partner/features/superapp/features/authentication/widgets/two_fa_method_bottom_sheet.dart';
import 'package:komtim_partner/features/superapp/features/authentication/widgets/two_fa_verify_otp_bottom_sheet.dart';

/// Entrypoint terpisah untuk preview & simulasi interaktif seluruh UI 2FA.
///
/// Jalankan langsung tanpa Firebase / DI / hit API:
/// ```bash
/// fvm flutter run -t lib/features/superapp/features/authentication/views/two_fa_ui_preview_main.dart --flavor dev --dart-define=FLAVOR=dev
/// ```
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _TwoFaUiPreviewApp());
}

class _TwoFaUiPreviewApp extends StatelessWidget {
  const _TwoFaUiPreviewApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Preview UI 2FA Login',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'PlusJakartaSans',
        useMaterial3: true,
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Colors.white,
        ),
      ),
      home: const _TwoFaPreviewLoginScreen(),
    );
  }
}

class _TwoFaPreviewLoginScreen extends StatefulWidget {
  const _TwoFaPreviewLoginScreen();

  @override
  State<_TwoFaPreviewLoginScreen> createState() =>
      _TwoFaPreviewLoginScreenState();
}

class _TwoFaPreviewLoginScreenState extends State<_TwoFaPreviewLoginScreen> {
  static const String _maskedEmail = 'ger*********************@g*****com';
  static const String _maskedPhone = '*********0034';

  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  bool _isLoginLoading = false;
  int _countdownSeconds = 59;
  bool _simulateRequestLimit = false;
  bool _simulateAccountRestrictedOnLogin = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: 'gerry@komerce.id');
    _passwordController = TextEditingController(text: '12345678Aa.');
    _emailController.addListener(_onInputChanged);
    _passwordController.addListener(_onInputChanged);
  }

  @override
  void dispose() {
    _emailController.removeListener(_onInputChanged);
    _passwordController.removeListener(_onInputChanged);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onInputChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _simulateClickLogin() async {
    FocusScope.of(context).unfocus();
    setState(() => _isLoginLoading = true);

    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;

    setState(() => _isLoginLoading = false);

    if (_simulateAccountRestrictedOnLogin) {
      await TwoFaLockedBottomSheet.showAccountRestricted(
        context,
        onContactCs: () {
          _showSnack('Simulasi: membuka Hubungi CS (https://partner.komerce.id/)');
        },
      );
      return;
    }

    await _openInteractiveMethodSheet(
      otpLimitExceeded: _simulateRequestLimit,
    );
  }

  Future<void> _openInteractiveMethodSheet({
    required bool otpLimitExceeded,
    TwoFaMethodType? initialSelectedType,
  }) async {
    final selectedMethod = await showModalBottomSheet<TwoFaMethodOption>(
      context: context,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black45,
      builder: (sheetContext) => _InteractiveMethodSheetHost(
        email: _maskedEmail,
        phone: _maskedPhone,
        otpLimitExceeded: otpLimitExceeded,
        initialSelectedType: initialSelectedType,
      ),
    );

    if (!mounted || selectedMethod == null) return;

    await _openInteractiveVerifySheet(
      methodType: selectedMethod.type,
      target: selectedMethod.value,
      initialCountdownSeconds: _countdownSeconds,
    );
  }

  Future<void> _openInteractiveVerifySheet({
    required TwoFaMethodType methodType,
    required String target,
    required int initialCountdownSeconds,
    String initialOtp = '',
    int? attemptsLeft,
    String? errorMessage,
    bool otpLimitExceeded = false,
    bool isSessionExpired = false,
  }) async {
    final result = await showModalBottomSheet<_VerifySheetOutcome>(
      context: context,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black45,
      builder: (sheetContext) => _InteractiveVerifySheetHost(
        methodType: methodType,
        target: target,
        initialCountdownSeconds: initialCountdownSeconds,
        initialOtp: initialOtp,
        initialAttemptsLeft: attemptsLeft,
        initialErrorMessage: errorMessage,
        initialOtpLimitExceeded: otpLimitExceeded,
        initialSessionExpired: isSessionExpired,
      ),
    );

    if (!mounted || result == null) return;

    switch (result) {
      case _VerifySheetOutcome.verified:
        _showSnack(
          'Simulasi Verifikasi OTP Sukses! (Next: Get Profile -> SharedPreferences -> Home)',
          isSuccess: true,
        );
      case _VerifySheetOutcome.changeMethod:
        await _openInteractiveMethodSheet(
          otpLimitExceeded: _simulateRequestLimit,
          initialSelectedType: methodType,
        );
      case _VerifySheetOutcome.lockedFailedThreeTimes:
        await TwoFaLockedBottomSheet.showOtpVerificationFailed(context);
    }
  }

  void _showSnack(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
              isSuccess ? AppColors.successBase : AppColors.grey800,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final bool canSubmit = _emailController.text.trim().isNotEmpty &&
        _passwordController.text.length >= 8;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Mockup Header Login Asli (agar blur backdrop terlihat akurat)
                  Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 414 / 248,
                        child: SvgPicture.asset(
                          'assets/images/superapp/auth/bg_auth.svg',
                          fit: BoxFit.fill,
                        ),
                      ),
                      Positioned.fill(
                        child: Align(
                          alignment: const Alignment(0, -0.18),
                          child: FractionallySizedBox(
                            widthFactor: 0.4,
                            child: AspectRatio(
                              aspectRatio: 227 / 61,
                              child: SvgPicture.asset(
                                'assets/images/superapp/logo_splash_screen.svg',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  Transform.translate(
                    offset: Offset(0, -constraints.maxWidth * 0.10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.pageMarginLg,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const AuthHeader(
                            title: 'Masuk ke Akun Kamu',
                            subtitle:
                                'Pantau transaksi bisnis kamu kapan aja,\nlangsung dari aplikasi',
                          ),
                          const SizedBox(height: AppSpacing.xl),

                          // ── Card Form Login Simulasi
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                              border: Border.all(color: AppColors.grey200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                DsEmailInput(
                                  label: 'Email',
                                  controller: _emailController,
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                DsPasswordField(
                                  label: 'Password',
                                  controller: _passwordController,
                                  topTrailing: Text(
                                    'Lupa Password?',
                                    style: AppTypography.labelMdSemiBold
                                        .copyWith(color: AppColors.primaryBase),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xl),
                                DsButton(
                                  text: 'Masuk',
                                  loadingText: 'Memuat...',
                                  state: _isLoginLoading
                                      ? DsButtonState.loading
                                      : (canSubmit
                                          ? DsButtonState.enabled
                                          : DsButtonState.disabled),
                                  onPressed: _simulateClickLogin,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: AppSpacing.lg),

                          // ── Panel Kontrol Simulasi & Shortcut Semua State Figma
                          _buildSimulatorPanel(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSimulatorPanel() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.alwaysWhite,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Simulator 2FA UI (Preview)',
            style: AppTypography.headingXs.copyWith(color: AppColors.grey900),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Klik tombol "Masuk" di atas untuk simulasi flow lengkap.\n'
            'OTP benar: 123456 • Selain itu: error & 3x salah -> Lock 24 jam.',
            style: AppTypography.bodySmRegular.copyWith(
              color: AppColors.grey600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Pilihan durasi countdown
          Text(
            'Durasi Countdown:',
            style: AppTypography.bodySmMedium.copyWith(color: AppColors.grey800),
          ),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              for (final sec in [59, 10, 3, 0])
                ChoiceChip(
                  label: Text('${sec}s'),
                  selected: _countdownSeconds == sec,
                  onSelected: (_) => setState(() => _countdownSeconds = sec),
                ),
            ],
          ),

          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: const Text(
              'Simulasi Request OTP Limit (saat klik Masuk)',
              style: AppTypography.bodySmMedium,
            ),
            value: _simulateRequestLimit,
            onChanged: (v) => setState(() => _simulateRequestLimit = v),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: const Text(
              'Simulasi Akun Dibatasi 24 Jam (saat klik Masuk)',
              style: AppTypography.bodySmMedium,
            ),
            value: _simulateAccountRestrictedOnLogin,
            onChanged: (v) =>
                setState(() => _simulateAccountRestrictedOnLogin = v),
          ),

          const Divider(height: AppSpacing.xl),
          Text(
            'Shortcut Buka Langsung State Figma:',
            style: AppTypography.bodySmMedium.copyWith(color: AppColors.grey800),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _ShortcutButton(
                label: '1. Pilih Metode (Normal)',
                onPressed: () =>
                    _openInteractiveMethodSheet(otpLimitExceeded: false),
              ),
              _ShortcutButton(
                label: '2. Pilih Metode (Limit)',
                onPressed: () =>
                    _openInteractiveMethodSheet(otpLimitExceeded: true),
              ),
              _ShortcutButton(
                label: '3. OTP SMS (59s)',
                onPressed: () => _openInteractiveVerifySheet(
                  methodType: TwoFaMethodType.sms,
                  target: _maskedPhone,
                  initialCountdownSeconds: 59,
                ),
              ),
              _ShortcutButton(
                label: '4. OTP Email (59s)',
                onPressed: () => _openInteractiveVerifySheet(
                  methodType: TwoFaMethodType.email,
                  target: _maskedEmail,
                  initialCountdownSeconds: 59,
                ),
              ),
              _ShortcutButton(
                label: '5. OTP Terisi (Siap)',
                onPressed: () => _openInteractiveVerifySheet(
                  methodType: TwoFaMethodType.sms,
                  target: _maskedPhone,
                  initialCountdownSeconds: 0,
                  initialOtp: '123455',
                ),
              ),
              _ShortcutButton(
                label: '6. OTP Salah (Sisa 2)',
                onPressed: () => _openInteractiveVerifySheet(
                  methodType: TwoFaMethodType.sms,
                  target: _maskedPhone,
                  initialCountdownSeconds: 0,
                  initialOtp: '123455',
                  attemptsLeft: 2,
                ),
              ),
              _ShortcutButton(
                label: '7. Sesi Berakhir',
                onPressed: () => _openInteractiveVerifySheet(
                  methodType: TwoFaMethodType.sms,
                  target: _maskedPhone,
                  initialCountdownSeconds: 0,
                  initialOtp: '123455',
                  isSessionExpired: true,
                ),
              ),
              _ShortcutButton(
                label: '8. Verifikasi OTP Gagal',
                onPressed: () =>
                    TwoFaLockedBottomSheet.showOtpVerificationFailed(context),
              ),
              _ShortcutButton(
                label: '9. Akun Dibatasi!',
                onPressed: () => TwoFaLockedBottomSheet.showAccountRestricted(
                  context,
                  onContactCs: () => _showSnack('Simulasi: Hubungi CS ditekan'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShortcutButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _ShortcutButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.grey800,
        side: const BorderSide(color: AppColors.grey300),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
      child: Text(label, style: AppTypography.bodySmMedium),
    );
  }
}

class _InteractiveMethodSheetHost extends StatefulWidget {
  final String email;
  final String phone;
  final bool otpLimitExceeded;
  final TwoFaMethodType? initialSelectedType;

  const _InteractiveMethodSheetHost({
    required this.email,
    required this.phone,
    required this.otpLimitExceeded,
    this.initialSelectedType,
  });

  @override
  State<_InteractiveMethodSheetHost> createState() =>
      _InteractiveMethodSheetHostState();
}

class _InteractiveMethodSheetHostState
    extends State<_InteractiveMethodSheetHost> {
  bool _isLoading = false;

  Future<void> _handleConfirm(TwoFaMethodOption option) async {
    setState(() => _isLoading = true);
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    Navigator.of(context).pop(option);
  }

  @override
  Widget build(BuildContext context) {
    return TwoFaMethodBottomSheet(
      email: widget.email,
      phone: widget.phone,
      otpLimitExceeded: widget.otpLimitExceeded,
      initialSelectedType: widget.initialSelectedType,
      isLoading: _isLoading,
      onConfirm: _handleConfirm,
      onCancel: () => Navigator.of(context).pop(),
      onClose: () => Navigator.of(context).pop(),
    );
  }
}

enum _VerifySheetOutcome {
  verified,
  changeMethod,
  lockedFailedThreeTimes,
}

class _InteractiveVerifySheetHost extends StatefulWidget {
  final TwoFaMethodType methodType;
  final String target;
  final int initialCountdownSeconds;
  final String initialOtp;
  final int? initialAttemptsLeft;
  final String? initialErrorMessage;
  final bool initialOtpLimitExceeded;
  final bool initialSessionExpired;

  const _InteractiveVerifySheetHost({
    required this.methodType,
    required this.target,
    required this.initialCountdownSeconds,
    this.initialOtp = '',
    this.initialAttemptsLeft,
    this.initialErrorMessage,
    this.initialOtpLimitExceeded = false,
    this.initialSessionExpired = false,
  });

  @override
  State<_InteractiveVerifySheetHost> createState() =>
      _InteractiveVerifySheetHostState();
}

class _InteractiveVerifySheetHostState
    extends State<_InteractiveVerifySheetHost> {
  late final TextEditingController _otpController;
  late int _countdownKey;
  late int _countdownSeconds;
  int _wrongCount = 0;
  int _resendCount = 0;
  int? _attemptsLeft;
  String? _errorMessage;
  late bool _otpLimitExceeded;
  late bool _isSessionExpired;
  bool _isLoading = false;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController(text: widget.initialOtp);
    _countdownKey = 0;
    _countdownSeconds = widget.initialCountdownSeconds;
    _attemptsLeft = widget.initialAttemptsLeft;
    _errorMessage = widget.initialErrorMessage;
    _otpLimitExceeded = widget.initialOtpLimitExceeded;
    _isSessionExpired = widget.initialSessionExpired;
    if (widget.initialAttemptsLeft != null) {
      _wrongCount = (3 - widget.initialAttemptsLeft!).clamp(0, 3);
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleConfirm(String otp) async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;

    if (otp == '123456') {
      Navigator.of(context).pop(_VerifySheetOutcome.verified);
      return;
    }

    _wrongCount++;
    final remaining = 3 - _wrongCount;
    if (remaining <= 0) {
      Navigator.of(context).pop(_VerifySheetOutcome.lockedFailedThreeTimes);
      return;
    }

    setState(() {
      _isLoading = false;
      _attemptsLeft = remaining;
    });
  }

  Future<void> _handleResend() async {
    setState(() {
      _isResending = true;
      _errorMessage = null;
      _attemptsLeft = null;
    });

    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;

    _resendCount++;
    setState(() {
      _isResending = false;
      if (_resendCount >= 3) {
        _otpLimitExceeded = true;
      } else {
        _countdownKey++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TwoFaVerifyOtpBottomSheet(
      methodType: widget.methodType,
      target: widget.target,
      controller: _otpController,
      initialCountdownSeconds: _countdownSeconds,
      countdownKey: _countdownKey,
      attemptsLeft: _attemptsLeft,
      errorMessage: _errorMessage,
      otpLimitExceeded: _otpLimitExceeded,
      isSessionExpired: _isSessionExpired,
      isLoading: _isLoading,
      isResending: _isResending,
      onConfirm: _handleConfirm,
      onResend: _handleResend,
      onChangeMethod: () =>
          Navigator.of(context).pop(_VerifySheetOutcome.changeMethod),
      onClose: () => Navigator.of(context).pop(),
    );
  }
}
