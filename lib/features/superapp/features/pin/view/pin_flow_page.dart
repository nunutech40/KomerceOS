import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komtim_partner/common/global/bloc/auth/auth_bloc.dart';
import 'package:komtim_partner/common/global/bloc/auth/auth_event.dart';
import 'package:komtim_partner/common/global/bloc/superapp_profile/superapp_profile_bloc.dart';
import 'package:komtim_partner/DI/injection.dart' as di;
import '../bloc/account_pin_cubit.dart';

enum PinFlow { create, change, forgot }

enum _PinStep { oldPin, chooseEmail, otp, newPin, confirmPin, success, login }

/// Alur UI PIN Superapp. Integrasi API akan dipasang di layer terpisah.
class PinFlowPage extends StatefulWidget {
  const PinFlowPage({
    super.key,
    required this.flow,
    required this.email,
    this.onCompleted,
    this.controller,
    this.now,
    this.onLocked,
  });

  final PinFlow flow;
  final String email;
  final VoidCallback? onCompleted;
  final AccountPinCubit? controller;
  final DateTime Function()? now;
  final VoidCallback? onLocked;

  @override
  State<PinFlowPage> createState() => _PinFlowPageState();
}

class _PinFlowPageState extends State<PinFlowPage> {
  late final AccountPinCubit _controller;
  late _PinStep _step;
  String _firstPin = '';
  String _verifiedOldPin = '';
  String _verifiedOldToken = '';
  String _otpToken = '';
  String _input = '';
  String? _error;
  late bool _isRecovery;
  int _resendSeconds = 0;
  DateTime? _nextRequestAt;
  int _fieldEpoch = 0;
  Timer? _timer;
  bool _isConfirming = false;
  bool _lockHandled = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? di.locator<AccountPinCubit>();
    _isRecovery = widget.flow == PinFlow.forgot;
    _step = switch (widget.flow) {
      PinFlow.create => _PinStep.newPin,
      PinFlow.change => _PinStep.oldPin,
      PinFlow.forgot => _PinStep.chooseEmail,
    };
    if (widget.flow == PinFlow.change) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _checkAttemptLeft());
    } else if (widget.flow == PinFlow.forgot) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _restorePendingOtp());
    }
  }

  Future<void> _restorePendingOtp() async {
    final result = await _controller.restorePendingOtp();
    if (!mounted || _step != _PinStep.chooseEmail) return;
    result.fold(
      (_) {},
      (challenge) {
        if (challenge == null || (challenge.token ?? '').isEmpty) return;
        final deadline = challenge.nextRequestAt == null
            ? null
            : DateTime.tryParse(
                challenge.nextRequestAt!.replaceFirst(' ', 'T'));
        if (deadline == null) return;
        final now = widget.now?.call() ?? DateTime.now();
        final expiry =
            DateTime.tryParse(challenge.expiredAt.replaceFirst(' ', 'T'));
        if (deadline.isBefore(now) &&
            (expiry == null || expiry.isBefore(now))) {
          _controller.clearPendingOtp();
          return;
        }
        _otpToken = challenge.token!;
        _startCooldown(challenge.nextRequestAt);
        if (expiry == null || expiry.isAfter(now)) _go(_PinStep.otp);
      },
    );
  }

  Future<void> _checkAttemptLeft() async {
    final result = await _controller.attemptLeft();
    if (!mounted || _step != _PinStep.oldPin) return;
    result.fold(
      (failure) => setState(() => _error = failure.message),
      (remaining) {
        if (remaining <= 0) _showLockSheet();
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    if (widget.controller == null) _controller.close();
    _firstPin = '';
    _verifiedOldPin = '';
    _input = '';
    super.dispose();
  }

  String get _title => switch (_step) {
        _PinStep.oldPin => 'Ubah PIN',
        _PinStep.chooseEmail || _PinStep.otp => 'Lupa PIN',
        _PinStep.newPin ||
        _PinStep.confirmPin =>
          widget.flow == PinFlow.change && !_isRecovery
              ? 'Ubah PIN'
              : 'Buat PIN',
        _PinStep.success => 'PIN',
        _PinStep.login => 'Masuk',
      };

  void _go(_PinStep step) {
    if (!mounted) return;
    setState(() {
      _step = step;
      _input = '';
      _error = null;
      _isConfirming = false;
      _fieldEpoch++;
    });
  }

  void _startCooldown(String? nextRequestAt) {
    _timer?.cancel();
    _nextRequestAt = nextRequestAt == null
        ? null
        : DateTime.tryParse(nextRequestAt.replaceFirst(' ', 'T'));
    void tick() {
      if (!mounted) return;
      final deadline = _nextRequestAt;
      final remaining = deadline == null
          ? Duration.zero
          : deadline.difference(widget.now?.call() ?? DateTime.now());
      setState(() => _resendSeconds = remaining.isNegative
          ? 0
          : (remaining.inMicroseconds / Duration.microsecondsPerSecond).ceil());
      if (_resendSeconds == 0) _timer?.cancel();
    }

    tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      tick();
    });
  }

  Future<void> _requestOtp() async {
    if (_isConfirming || _resendSeconds > 0) return;
    setState(() => _isConfirming = true);
    final result = await _controller.requestOtp();
    if (!mounted) return;
    result.fold(
      (failure) => setState(() => _error = failure.message),
      (data) {
        if ((data.token ?? '').isEmpty ||
            data.nextRequestAt == null ||
            DateTime.tryParse(data.nextRequestAt!.replaceFirst(' ', 'T')) ==
                null) {
          setState(() =>
              _error = 'Waktu kirim ulang OTP tidak tersedia. Coba lagi.');
          return;
        }
        _otpToken = data.token!;
        _startCooldown(data.nextRequestAt);
        _go(_PinStep.otp);
      },
    );
    if (mounted) setState(() => _isConfirming = false);
  }

  Future<void> _submit() async {
    if (_input.length != 6) return;
    switch (_step) {
      case _PinStep.oldPin:
        final enteredPin = _input;
        setState(() => _isConfirming = true);
        final result = await _controller.verifyPin(enteredPin);
        if (!mounted) return;
        result.fold(
          (failure) {
            final remaining =
                RegExp(r'Sisa percobaan:\s*(\d+)', caseSensitive: false)
                    .firstMatch(failure.message);
            final attempts = int.tryParse(remaining?.group(1) ?? '');
            if (attempts == 0 ||
                RegExp(r'lock:\s*(true|1)', caseSensitive: false)
                    .hasMatch(failure.message)) {
              _showLockSheet();
            } else {
              setState(() => _error = attempts == null
                  ? failure.message
                  : 'PIN salah. Kamu memiliki $attempts percobaan lagi sebelum akun kamu logout secara otomatis');
            }
          },
          (data) {
            if (data.isValid) {
              if ((data.usableToken ?? '').isEmpty) {
                setState(() =>
                    _error = 'Token verifikasi PIN tidak tersedia. Coba lagi.');
                return;
              }
              _verifiedOldPin = enteredPin;
              _verifiedOldToken = data.usableToken!;
              _go(_PinStep.newPin);
            } else if (data.attemptLeft <= 0) {
              _showLockSheet();
            } else {
              setState(() => _error =
                  'PIN salah. Kamu memiliki ${data.attemptLeft} percobaan lagi sebelum akun kamu logout secara otomatis');
            }
          },
        );
        if (mounted) setState(() => _isConfirming = false);
        break;
      case _PinStep.otp:
        setState(() => _isConfirming = true);
        final otpResult = await _controller.verifyOtp(_input, _otpToken);
        if (!mounted) return;
        otpResult.fold(
          (failure) => setState(() => _error = failure.message),
          (data) {
            if (data.isValid) {
              _go(_PinStep.newPin);
            } else {
              setState(() => _error =
                  'Kode OTP salah. Harap cek OTP pada email, lalu coba lagi.');
            }
          },
        );
        if (mounted) setState(() => _isConfirming = false);
        break;
      case _PinStep.newPin:
        if (widget.flow == PinFlow.change &&
            !_isRecovery &&
            _input == _verifiedOldPin) {
          setState(
              () => _error = 'PIN baru tidak boleh sama dengan PIN sebelumnya');
          return;
        }
        _firstPin = _input;
        _go(_PinStep.confirmPin);
        break;
      case _PinStep.confirmPin:
        if (_input != _firstPin || _isConfirming) return;
        setState(() => _isConfirming = true);
        final saveResult = widget.flow == PinFlow.create
            ? await _controller.createPin(_input)
            : _isRecovery
                ? await _controller.resetPin(_input, _otpToken)
                : await _controller.changePin(
                    _input, _verifiedOldPin, _verifiedOldToken);
        if (!mounted) return;
        saveResult.fold(
          (failure) => setState(() => _error = failure.message),
          (_) {
            _firstPin = '';
            _verifiedOldPin = '';
            _verifiedOldToken = '';
            _otpToken = '';
            _go(_PinStep.success);
          },
        );
        if (mounted) setState(() => _isConfirming = false);
        break;
      default:
        break;
    }
  }

  void _showLockSheet() {
    if (_lockHandled) return;
    _lockHandled = true;
    if (widget.onLocked != null) {
      widget.onLocked!();
    } else {
      context
          .read<SuperappProfileBloc>()
          .add(const ClearSuperappProfileEvent());
      context.read<AuthBloc>().add(AuthLogoutRequested());
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      DsBottomSheet.show<void>(
        context: context,
        isDismissible: false,
        title: 'Terlalu Banyak Percobaan PIN',
        description: 'Kamu telah mencapai batas maksimal percobaan PIN. '
            'Demi keamanan akun, silakan coba kembali dalam 24 jam.',
        primaryButtonText: 'Lanjut',
        onPrimaryPressed: () {
          Navigator.of(context).pop();
          _timer?.cancel();
          _verifiedOldPin = '';
          _go(_PinStep.login);
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_step == _PinStep.success || _step == _PinStep.login) {
      return _buildResult();
    }
    return Scaffold(
      backgroundColor: AppColors.alwaysWhite,
      appBar: DsAppBar(title: _title),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: _buildStep(),
              ),
            ),
            if (_step == _PinStep.chooseEmail ||
                _step == _PinStep.otp ||
                _step == _PinStep.confirmPin)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: DsButton(
                  text: switch (_step) {
                    _PinStep.chooseEmail => _resendSeconds > 0
                        ? 'Kirim Ulang ($_resendSeconds detik)'
                        : 'Kirim OTP',
                    _PinStep.otp => 'Verifikasi',
                    _ => 'Konfirmasi',
                  },
                  loadingText: _step == _PinStep.confirmPin
                      ? 'Memverifikasi PIN...'
                      : null,
                  loadingTextStyle: _step == _PinStep.confirmPin
                      ? AppTypography.bodySmRegular
                      : null,
                  state: _isConfirming
                      ? DsButtonState.loading
                      : (_step == _PinStep.chooseEmail &&
                                  _resendSeconds == 0) ||
                              (_input.length == 6 &&
                                  !(_step == _PinStep.otp && _error != null) &&
                                  (_step != _PinStep.confirmPin ||
                                      _input == _firstPin))
                          ? DsButtonState.enabled
                          : DsButtonState.disabled,
                  onPressed: () {
                    if (_step == _PinStep.chooseEmail) {
                      _requestOtp();
                    } else {
                      _submit();
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep() {
    if (_step == _PinStep.chooseEmail || _step == _PinStep.otp) {
      final isChoosingEmail = _step == _PinStep.chooseEmail;
      return Column(
        children: [
          const SizedBox(height: 88),
          SvgPicture.asset(
            'assets/images/superapp/auth/verify_code_email.svg',
            width: 112,
            height: 112,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            isChoosingEmail ? 'Pilih Metode Verifikasi' : 'Masukkan Kode OTP',
            style: AppTypography.headingXxs,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            isChoosingEmail
                ? 'Pilih metode OTP untuk memverifikasi akunmu. Pastikan data kontak yang kamu pilih sudah benar'
                : 'Kode OTP telah dikirimkan melalui email ke ${_maskEmail(widget.email)}',
            style:
                AppTypography.bodySmRegular.copyWith(color: AppColors.grey600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          if (isChoosingEmail)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.alwaysWhite,
                border: Border.all(color: AppColors.grey300),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/images/superapp/setting/ic_otp_email_figma.svg',
                    width: AppSpacing.iconMd,
                    height: AppSpacing.iconMd,
                  ),
                  const SizedBox(width: AppSpacing.md3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Email', style: AppTypography.bodyMdMedium),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Kode OTP akan dikirim via email ke ${_maskEmail(widget.email)}',
                          style: AppTypography.bodySmRegular
                              .copyWith(color: AppColors.grey600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else ...[
            _otpField(obscure: true),
            _errorLabel(),
            const SizedBox(height: AppSpacing.lg3),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.errorBase,
                disabledForegroundColor: AppColors.errorBase,
              ),
              onPressed: _resendSeconds == 0
                  ? () async {
                      setState(() {
                        _input = '';
                        _error = null;
                        _fieldEpoch++;
                      });
                      await _requestOtp();
                    }
                  : null,
              child: Text(_resendSeconds == 0
                  ? 'Kirim Ulang'
                  : 'Kirim Ulang ($_resendSeconds detik)'),
            ),
          ],
        ],
      );
    }

    return Column(
      children: [
        const SizedBox(height: 88),
        Text(
          switch (_step) {
            _PinStep.oldPin => 'Masukkan 6 Digit PIN Kamu',
            _PinStep.newPin => 'Masukkan 6 Digit PIN Baru',
            _ => 'Masukkan Ulang PIN Baru',
          },
          style: AppTypography.headingXxs,
          textAlign: TextAlign.center,
        ),
        if (_step != _PinStep.oldPin) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            switch (_step) {
              _PinStep.confirmPin =>
                'Masukkan kembali 6 digit PIN yang telah kamu buat untuk mengonfirmasi PIN akunmu.',
              _PinStep.newPin
                  when widget.flow == PinFlow.change && !_isRecovery =>
                'Gunakan PIN 6 digit yang berbeda dari PIN sebelumnya dan mudah kamu ingat.',
              _ =>
                'Buat PIN 6 digit yang mudah diingat dan jangan bagikan kepada siapa pun.',
            },
            style: AppTypography.bodySmRegular,
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: AppSpacing.lg3),
        _otpField(obscure: true),
        _errorLabel(),
        if (_step == _PinStep.oldPin) ...[
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.primaryBase),
            onPressed: () {
              _isRecovery = true;
              _verifiedOldPin = '';
              _go(_PinStep.chooseEmail);
              _restorePendingOtp();
            },
            child: const Text('Lupa PIN?'),
          ),
        ],
      ],
    );
  }

  Widget _otpField({required bool obscure}) => DsOtpField(
        key: ValueKey('${_step.name}-$_fieldEpoch'),
        obscureText: obscure,
        centerInputGroups: _step == _PinStep.otp ||
            _step == _PinStep.oldPin ||
            _step == _PinStep.newPin ||
            _step == _PinStep.confirmPin,
        autoFocus: true,
        onChanged: (value) {
          setState(() {
            _input = value;
            if (_step == _PinStep.confirmPin) {
              _error = value.length == 6 && value != _firstPin
                  ? 'PIN yang kamu masukkan salah'
                  : null;
            } else if (_step == _PinStep.otp ||
                _step == _PinStep.oldPin ||
                _step == _PinStep.newPin) {
              // Kesalahan sebelumnya hilang saat pengguna mengubah digit.
              _error = null;
            } else if (value.length < 6) {
              _error = null;
            }
          });
        },
        onCompleted: (_) {
          if (_step == _PinStep.confirmPin && _input == _firstPin) {
            FocusScope.of(context).unfocus();
          }
          if (_step == _PinStep.oldPin || _step == _PinStep.newPin) {
            _submit();
          }
        },
      );

  Widget _errorLabel() => _error == null
      ? const SizedBox.shrink()
      : Padding(
          padding: const EdgeInsets.only(top: AppSpacing.sm),
          child: Text(
            _error!,
            textAlign: TextAlign.center,
            style: AppTypography.bodySmRegular
                .copyWith(color: AppColors.errorBase),
          ),
        );

  Widget _buildResult() => Scaffold(
        backgroundColor: AppColors.alwaysWhite,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      if (_step == _PinStep.success)
                        const Spacer(flex: 2)
                      else
                        const Spacer(),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_step == _PinStep.login) ...[
                            const Icon(Icons.lock_clock_outlined,
                                size: 180, color: AppColors.primaryBase),
                            const SizedBox(height: AppSpacing.lg),
                          ],
                          Text(
                            _step == _PinStep.success
                                ? 'PIN Kamu Berhasil ${widget.flow == PinFlow.change && !_isRecovery ? 'Diubah' : 'Dibuat'}'
                                : 'Masuk ke Akun Kamu',
                            style: AppTypography.bodyLgBold,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            _step == _PinStep.success
                                ? widget.flow == PinFlow.change && !_isRecovery
                                    ? 'PIN baru kamu telah diubah dan dapat digunakan untuk proses verifikasi akun.'
                                    : 'PIN baru kamu telah dibuat dan dapat digunakan untuk proses verifikasi akun.'
                                : 'Sesi berakhir. Silakan masuk kembali.',
                            textAlign: TextAlign.center,
                          ),
                          if (_step == _PinStep.success) ...[
                            const SizedBox(height: AppSpacing.lg),
                            SvgPicture.asset(
                              'assets/images/superapp/auth/success_reset_password.svg',
                              height: 220,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            DsButton(
                              text: 'Kembali',
                              onPressed: () {
                                widget.onCompleted?.call();
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ],
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
                if (_step == _PinStep.login)
                  DsButton(
                    text: 'Selesai',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
              ],
            ),
          ),
        ),
      );

  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final name = parts.first;
    if (name.isEmpty) return email;
    if (name.length == 1) return '*@${parts.last}';
    return '${name[0]}${'*' * (name.length - 2 < 4 ? 4 : name.length - 2)}${name[name.length - 1]}@${parts.last}';
  }
}
