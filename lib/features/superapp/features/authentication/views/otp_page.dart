import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import 'package:komtim_partner/common/global/router/router_utils.dart';

import '../widgets/email_check_header.dart';

// -----------------------------------------------------------------------------
// OtpPage
//
// Halaman untuk memverifikasi kode OTP yang dikirim ke email.
// -----------------------------------------------------------------------------

class OtpPage extends StatefulWidget {
  final String email;

  const OtpPage({super.key, required this.email});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  String _otpCode = '';
  String? _errorText;
  bool _isLoading = false;

  // Timer properties
  Timer? _countdownTimer;
  int _secondsRemaining = 45;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _secondsRemaining = 45;
    });
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _onResendCode() {
    if (_secondsRemaining > 0) return;

    // TODO: Call API to resend code
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kode OTP telah dikirim ulang')),
    );

    _startTimer();
  }

  void _onVerify() async {
    if (_otpCode.length < 6) return;

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    // --- DUMMY SCENARIO ---
    await Future.delayed(const Duration(seconds: 1));

    if (_otpCode != '123456') {
      setState(() {
        _isLoading = false;
        _errorText = 'Kode verifikasi yang kamu masukkan salah.';
      });
      return;
    }

    setState(() {
      _isLoading = false;
    });

    // Navigasi ke halaman Atur Password Baru
    if (mounted) {
      context.pushNamed(PAGES.newForgotPassword.screenName);
    }
  }

  // Obfuscate email
  String _maskEmail(String email) {
    if (!email.contains('@')) return email;
    final parts = email.split('@');
    final name = parts[0];
    final domain = parts[1];

    final maskedName = name.length > 3
        ? '${name.substring(0, 3)}****${name.substring(name.length - 1)}'
        : '$name****';

    final domainParts = domain.split('.');
    final domainName = domainParts[0];
    final tld =
        domainParts.length > 1 ? '.${domainParts.sublist(1).join('.')}' : '';

    final maskedDomain = domainName.length > 1
        ? '${domainName.substring(0, 1)}******'
        : '******';

    return '$maskedName@$maskedDomain$tld';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pageMarginLg,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: AppSpacing.xl),

                      // --- Illustration ---
                      SvgPicture.asset(
                        'assets/images/superapp/auth/verify_code_email.svg',
                        height: 250,
                        // Fallback icon if asset is not present
                        placeholderBuilder: (context) => const Icon(
                          Icons.mark_email_read_rounded,
                          size: 100,
                          color: AppColors.primaryBase,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // --- Header ---
                      AuthHeader(
                        title: 'Masukkan Kode Verifikasi',
                        subtitle:
                            'Masukkan kode verifikasi (OTP) yang telah dikirim\nmelalui email ke ${_maskEmail(widget.email)}',
                      ),

                      const SizedBox(height: AppSpacing.xl2),

                      // --- OTP Field ---
                      DsOtpField(
                        onChanged: (val) {
                          setState(() {
                            _otpCode = val;
                            _errorText = null;
                          });
                        },
                        onCompleted: (val) {
                          setState(() {
                            _otpCode = val;
                          });
                        },
                        errorText: _errorText,
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // --- Resend / Timer text ---
                      Center(
                        child: _secondsRemaining > 0
                            ? Text.rich(
                                TextSpan(
                                  text: 'Kirim ulang kode dalam ',
                                  style: AppTypography.bodySmRegular.copyWith(
                                    color: AppColors.grey600,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: '$_secondsRemaining detik',
                                      style:
                                          AppTypography.bodySmRegular.copyWith(
                                        color: AppColors.primaryBase,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Text.rich(
                                TextSpan(
                                  text: 'Tidak menerima kode? ',
                                  style: AppTypography.bodySmRegular.copyWith(
                                    color: AppColors.grey600,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Kirim ulang',
                                      style: AppTypography.labelSmSemiBold
                                          .copyWith(
                                        color: AppColors.primaryBase,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = _onResendCode,
                                    ),
                                  ],
                                ),
                              ),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // --- Verify Button ---
                      DsButton(
                        text: 'Verifikasi',
                        state: _isLoading
                            ? DsButtonState.loading
                            : (_otpCode.length == 6
                                ? DsButtonState.enabled
                                : DsButtonState.disabled),
                        onPressed: _onVerify,
                      ),

                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
