import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';

enum PinFlow { create, change, forgot }

enum _PinStep { oldPin, chooseEmail, otp, newPin, confirmPin, success, login }

/// Alur UI PIN Superapp. Integrasi API akan dipasang di layer terpisah.
class PinFlowPage extends StatefulWidget {
  const PinFlowPage({
    super.key,
    required this.flow,
    required this.email,
    this.onCompleted,
  });

  final PinFlow flow;
  final String email;
  final VoidCallback? onCompleted;

  @override
  State<PinFlowPage> createState() => _PinFlowPageState();
}

class _PinFlowPageState extends State<PinFlowPage> {
  static const _mockCode = '123456';
  static const _maxOldPinAttempts = 3;
  static const _maxOtpAttempts = 5;

  late _PinStep _step;
  String _firstPin = '';
  String _verifiedOldPin = '';
  String _input = '';
  String? _error;
  int _oldPinAttempts = 0;
  int _otpAttempts = 0;
  int _resendCount = 0;
  late bool _isRecovery;
  int _resendSeconds = 0;
  int _fieldEpoch = 0;
  Timer? _timer;
  Timer? _confirmationTimer;
  bool _isConfirming = false;

  @override
  void initState() {
    super.initState();
    _isRecovery = widget.flow == PinFlow.forgot;
    _step = switch (widget.flow) {
      PinFlow.create => _PinStep.newPin,
      PinFlow.change => _PinStep.oldPin,
      PinFlow.forgot => _PinStep.chooseEmail,
    };
  }

  @override
  void dispose() {
    _timer?.cancel();
    _confirmationTimer?.cancel();
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
    _confirmationTimer?.cancel();
    setState(() {
      _step = step;
      _input = '';
      _error = null;
      _isConfirming = false;
      _fieldEpoch++;
    });
  }

  void _startCooldown() {
    _timer?.cancel();
    final seconds = switch (_resendCount) {
      0 => 60,
      1 => 120,
      2 => 240,
      _ => 480,
    };
    setState(() => _resendSeconds = seconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _resendSeconds <= 1) {
        timer.cancel();
        if (mounted) setState(() => _resendSeconds = 0);
        return;
      }
      setState(() => _resendSeconds--);
    });
  }

  void _submit() {
    if (_input.length != 6) return;
    switch (_step) {
      case _PinStep.oldPin:
        if (_input != _mockCode) {
          setState(() {
            _oldPinAttempts++;
            final remaining = _maxOldPinAttempts - _oldPinAttempts;
            _error = remaining > 0
                ? 'PIN salah. Kamu memiliki $remaining percobaan lagi sebelum akun kamu logout secara otomatis'
                : null;
          });
          if (_oldPinAttempts >= _maxOldPinAttempts) _showLockSheet();
          return;
        }
        _verifiedOldPin = _input;
        _go(_PinStep.newPin);
        break;
      case _PinStep.otp:
        if (_input != _mockCode) {
          setState(() {
            _otpAttempts++;
            _error = _otpAttempts < _maxOtpAttempts
                ? 'OTP yang kamu masukkan salah'
                : null;
          });
          if (_otpAttempts >= _maxOtpAttempts) {
            _showLockSheet();
          }
          return;
        }
        _go(_PinStep.newPin);
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
        // Simulasi verifikasi sampai API PIN tersedia.
        _confirmationTimer = Timer(const Duration(milliseconds: 700), () {
          if (!mounted || _step != _PinStep.confirmPin) return;
          _firstPin = '';
          _verifiedOldPin = '';
          _go(_PinStep.success);
        });
        break;
      default:
        break;
    }
  }

  void _showLockSheet() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      DsBottomSheet.show<void>(
        context: context,
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
                    _PinStep.chooseEmail => 'Kirim OTP',
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
                      : _step == _PinStep.chooseEmail ||
                              (_input.length == 6 &&
                                  !(_step == _PinStep.otp && _error != null) &&
                                  (_step != _PinStep.confirmPin ||
                                      _input == _firstPin))
                          ? DsButtonState.enabled
                          : DsButtonState.disabled,
                  onPressed: () {
                    if (_step == _PinStep.chooseEmail) {
                      _startCooldown();
                      _go(_PinStep.otp);
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
          const SizedBox(height: AppSpacing.xl2),
          SvgPicture.asset(
            'assets/images/superapp/auth/verify_code_email.svg',
            width: 112,
            height: 112,
          ),
          const SizedBox(height: AppSpacing.md3),
          Text(
            isChoosingEmail ? 'Pilih Metode Verifikasi' : 'Masukkan Kode OTP',
            style: AppTypography.headingXxs,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
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
                  const Icon(Icons.mail_outline,
                      size: AppSpacing.iconMd, color: AppColors.grey600),
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
                  ? () {
                      setState(() {
                        _resendCount++;
                        _input = '';
                        _error = null;
                        _fieldEpoch++;
                      });
                      _startCooldown();
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
        const SizedBox(height: AppSpacing.xl2),
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
          if (_step == _PinStep.oldPin ||
              _step == _PinStep.newPin ||
              (_step == _PinStep.otp && _input != _mockCode)) {
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
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_step == _PinStep.success)
                          SvgPicture.asset(
                            'assets/images/superapp/auth/success_reset_password.svg',
                            height: 220,
                          )
                        else
                          const Icon(Icons.lock_clock_outlined,
                              size: 180, color: AppColors.primaryBase),
                        const SizedBox(height: AppSpacing.lg),
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
                              ? 'PIN baru kamu telah dibuat dan dapat digunakan untuk proses verifikasi akun.'
                              : 'Sesi berakhir. Silakan masuk kembali.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                DsButton(
                  text: _step == _PinStep.success ? 'Kembali' : 'Selesai',
                  onPressed: () {
                    if (_step == _PinStep.success) widget.onCompleted?.call();
                    Navigator.of(context).pop();
                  },
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
