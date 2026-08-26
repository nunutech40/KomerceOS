import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import 'package:komtim_partner/common/global/router/router_utils.dart';
import 'package:komtim_partner/core/domain/usecases/reset_password_use_case.dart';

import '../widgets/email_check_header.dart';

// -----------------------------------------------------------------------------
// NewForgotPasswordPage
//
// Halaman Atur Password Baru setelah user klik link reset di email.
// Menerima `code` dari deep link (komerce://reset-password?code=xxx)
// dan mengirimkan password baru ke API via ResetPasswordUseCase.
// -----------------------------------------------------------------------------

class NewForgotPasswordPage extends StatefulWidget {
  final String? code;
  final ResetPasswordUseCase resetPasswordUseCase;

  const NewForgotPasswordPage({
    super.key,
    this.code,
    required this.resetPasswordUseCase,
  });

  @override
  State<NewForgotPasswordPage> createState() => _NewForgotPasswordPageState();
}

class _NewForgotPasswordPageState extends State<NewForgotPasswordPage> {
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  bool _hasMinLength = false;
  bool _hasLetterAndNumber = false;
  bool _hasUpperAndLowerCase = false;

  bool _isLoading = false;

  // Validation
  void _validatePassword(String value) {
    setState(() {
      _hasMinLength = value.length >= 8;
      _hasLetterAndNumber =
          RegExp(r'^(?=.*[a-zA-Z])(?=.*\d).+$').hasMatch(value);
      _hasUpperAndLowerCase =
          RegExp(r'^(?=.*[a-z])(?=.*[A-Z]).+$').hasMatch(value);
    });
  }

  bool get _isPasswordValid =>
      _hasMinLength && _hasLetterAndNumber && _hasUpperAndLowerCase;

  bool get _isConfirmPasswordMatch {
    if (_confirmPassController.text.isEmpty) {
      return true; // Don't show error if empty
    }
    return _passController.text == _confirmPassController.text;
  }

  bool get _isFormValid =>
      _isPasswordValid &&
      _confirmPassController.text.isNotEmpty &&
      _isConfirmPasswordMatch;

  // Success Timer
  Timer? _redirectTimer;

  @override
  void dispose() {
    _passController.dispose();
    _confirmPassController.dispose();
    _redirectTimer?.cancel();
    super.dispose();
  }

  void _onSubmit() async {
    if (!_isFormValid) return;

    final code = widget.code;
    if (code == null || code.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Kode reset tidak valid. Silakan coba lagi dari email.'),
            backgroundColor: AppColors.errorBase,
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final password = _passController.text;
    debugPrint('Resetting password with code: $code');

    final result = await widget.resetPasswordUseCase.execute(code, password);

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(failure.message),
              backgroundColor: AppColors.errorBase,
            ),
          );
      },
      (_) {
        setState(() {
          _isLoading = false;
        });
        // Pindah ke halaman sukses
        context.goNamed(PAGES.successNewPassword.screenName);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- BG + Logo ---
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
                          // rasionya setara menaikkan ~20px dari pusat terhadap tinggi BG
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

                  // --- Konten di bawah BG ---
                  Transform.translate(
                    offset: Offset(0, -constraints.maxWidth * 0.10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.pageMarginLg,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // --- Header ---
                          const AuthHeader(
                            title: 'Atur Password Baru',
                            subtitle:
                                'Buat password baru untuk akunmu. Pastikan password\nmudah diingat dan tidak digunakan di akun lain.',
                          ),
                          const SizedBox(height: AppSpacing.xl),

                          // --- Card Form ---
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(AppRadius.xl),
                              border: Border.all(color: AppColors.grey200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Password Field
                                DsPasswordField(
                                  label: 'Password',
                                  controller: _passController,
                                  onChanged: _validatePassword,
                                ),
                                const SizedBox(height: AppSpacing.sm),

                                // Validation Rules
                                if (_passController.text.isNotEmpty) ...[
                                  _buildValidationItem(
                                    text: 'Minimal 8 karakter',
                                    isValid: _hasMinLength,
                                  ),
                                  const SizedBox(height: 4),
                                  _buildValidationItem(
                                    text: 'Mengandung huruf dan angka',
                                    isValid: _hasLetterAndNumber,
                                  ),
                                  const SizedBox(height: 4),
                                  _buildValidationItem(
                                    text: 'Mengandung huruf besar dan kecil',
                                    isValid: _hasUpperAndLowerCase,
                                  ),
                                ],
                                const SizedBox(height: AppSpacing.lg),

                                // Konfirmasi Password Field
                                DsPasswordField(
                                  label: 'Konfirmasi Password Baru',
                                  hintText: 'Masukkan Ulang Password',
                                  controller: _confirmPassController,
                                  onChanged: (_) => setState(() {}),
                                  errorText: (!_isConfirmPasswordMatch &&
                                          _confirmPassController
                                              .text.isNotEmpty)
                                      ? 'Password tidak sama'
                                      : null,
                                ),

                                const SizedBox(height: AppSpacing.xl),

                                // Submit Button
                                DsButton(
                                  text: 'Simpan',
                                  state: _isLoading
                                      ? DsButtonState.loading
                                      : (_isFormValid
                                          ? DsButtonState.enabled
                                          : DsButtonState.disabled),
                                  onPressed: _onSubmit,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          // Padding keyboard — bg naik saat keyboard muncul
                          SizedBox(height: keyboardHeight),
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

  Widget _buildValidationItem({required String text, required bool isValid}) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle_outline : Icons.radio_button_unchecked,
          size: 16,
          color: isValid ? AppColors.successBase : AppColors.grey400,
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          text,
          style: AppTypography.bodySmRegular.copyWith(
            color: isValid ? AppColors.successBase : AppColors.grey400,
          ),
        ),
      ],
    );
  }
}
