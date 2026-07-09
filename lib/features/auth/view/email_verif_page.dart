import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:komtim_partner/DI/injection.dart' as di;
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import 'package:komtim_partner/common/global/mixin/handling_error_page.dart';
import 'package:komtim_partner/firebase_options.dart';

import '../../../core/data/datasources/preferences/shared_pref.dart';

// -----------------------------------------------------------------------------
// Email Verif Page
//
// Step 1: User enters email → tap "Lanjutkan"
//
// Design reference:
//   - Title: "Masukkan Email Kamu"
//   - Subtitle: "Masukkan email akun kamu\nuntuk melanjutkan proses login"
//   - Email text field with label
//   - Password text field with label
//   - Full-width "Lanjutkan" button
//   - Full-width "Masuk dengan WhatsApp" button (with icon)
// -----------------------------------------------------------------------------

class EmailVerifPage extends StatefulWidget {
  const EmailVerifPage({super.key});

  @override
  State<EmailVerifPage> createState() => _EmailVerifPageState();
}

class _EmailVerifPageState extends State<EmailVerifPage>
    with ErrorHandlingMixin {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  bool _isButtonActive = false;
  bool _isEmailError = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _emailController.addListener(_onFormChanged);
    _passwordController.addListener(_onFormChanged);
  }

  void _onFormChanged() {
    final emailText = _emailController.text;
    final passwordText = _passwordController.text;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    final isEmailValid = emailRegex.hasMatch(emailText);

    setState(() {
      _isButtonActive =
          emailText.isNotEmpty && isEmailValid && passwordText.isNotEmpty;
      _isEmailError = emailText.isNotEmpty && !isEmailValid;
    });
  }

  Future<void> _submitEmail() async {
    setState(() => _isLoading = true);
    try {
      final pref = di.locator<SharedPref>();

      String lastToken = await pref.getFcmToken();

      if (lastToken.isEmpty) {
        if (Firebase.apps.isEmpty) {
          await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          );
        }
        final fcmToken = await FirebaseMessaging.instance.getToken();
        await pref.saveFcmToken(fcmToken ?? '');
      }

      // Simulasi delay untuk testing loading (hapus di production)
      await Future.delayed(const Duration(seconds: 2));

      debugPrint("Lanjutkan pressed for email: ${_emailController.text}");

      if (mounted) {
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _EmailVerifPageBody(
      emailController: _emailController,
      passwordController: _passwordController,
      isButtonActive: _isButtonActive,
      isEmailError: _isEmailError,
      isLoading: _isLoading,
      onSubmit: _submitEmail,
    );
  }
}

// -----------------------------------------------------------------------------
// Body
// -----------------------------------------------------------------------------

class _EmailVerifPageBody extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isButtonActive;
  final bool isEmailError;
  final bool isLoading;
  final VoidCallback onSubmit;

  const _EmailVerifPageBody({
    required this.emailController,
    required this.passwordController,
    required this.isButtonActive,
    required this.isEmailError,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const _Header(),
                      const SizedBox(height: AppSpacing.xl),
                      _EmailCard(
                        emailController: emailController,
                        passwordController: passwordController,
                        isButtonActive: isButtonActive,
                        isEmailError: isEmailError,
                        isLoading: isLoading,
                        onSubmit: onSubmit,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      const _OtpSection(),
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

// -----------------------------------------------------------------------------
// Header — Title + Subtitle
// -----------------------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Masukkan Email Kamu',
          style: AppTypography.headingMd.copyWith(
            color: AppColors.grey800,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Masukkan email akun kamu\nuntuk melanjutkan proses login',
          style: AppTypography.bodyMdRegular.copyWith(
            color: AppColors.grey600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Email Card — Elevated card containing email field + button
// -----------------------------------------------------------------------------

class _EmailCard extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isButtonActive;
  final bool isEmailError;
  final bool isLoading;
  final VoidCallback onSubmit;

  const _EmailCard({
    required this.emailController,
    required this.passwordController,
    required this.isButtonActive,
    required this.isEmailError,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.grey200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Email Field ---
          _EmailField(
            controller: emailController,
            isError: isEmailError,
          ),
          const SizedBox(height: AppSpacing.md),
          // --- Password Field ---
          DsPasswordField(
            label: 'Password',
            controller: passwordController,
          ),
          const SizedBox(height: AppSpacing.xl),
          // --- Submit Button ---
          _SubmitButton(
            isActive: isButtonActive,
            isLoading: isLoading,
            onPressed: onSubmit,
          ),
          const SizedBox(height: AppSpacing.md),
          // --- WhatsApp Button with Icon ---
          DsButton(
            text: 'Masuk dengan WhatsApp',
            onPressed: () {
              DsBottomSheet.show(
                context: context,
                title: 'Gagal Login',
                description:
                    'Periksa kembali email dan password yang kamu masukkan. Tersisa 2 kali percobaan.',
                image: SvgPicture.asset(
                  'assets/images/ic_disapointed.svg',
                  width: 200,
                  height: 300,
                ),
                primaryButtonText: 'Coba Lagi',
                onPrimaryPressed: () => Navigator.pop(context),
                secondaryButtonText: 'Kembali',
                onSecondaryPressed: () => Navigator.pop(context),
              );
            },
            leftIcon: SvgPicture.asset(
              'assets/images/ic_whatsapp.svg',
              width: 24,
              height: 24,
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Email Field
// -----------------------------------------------------------------------------

class _EmailField extends StatelessWidget {
  final TextEditingController controller;
  final bool isError;

  const _EmailField({
    required this.controller,
    required this.isError,
  });

  @override
  Widget build(BuildContext context) {
    return DsEmailInput(
      label: 'Email',
      controller: controller,
      errorText: isError ? 'Format email tidak valid' : null,
    );
  }
}

// -----------------------------------------------------------------------------
// OTP Section
// -----------------------------------------------------------------------------

class _OtpSection extends StatelessWidget {
  const _OtpSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kode OTP',
          style: AppTypography.labelMdSemiBold.copyWith(
            color: AppColors.grey800,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        DsOtpField(
          autoFocus: false,
          onCompleted: (otp) {
            debugPrint('OTP completed: $otp');
          },
          onChanged: (value) {
            debugPrint('OTP changed: $value');
          },
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Submit Button
// -----------------------------------------------------------------------------

class _SubmitButton extends StatelessWidget {
  final bool isActive;
  final bool isLoading;
  final VoidCallback onPressed;

  const _SubmitButton({
    required this.isActive,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final buttonState = isLoading
        ? DsButtonState.loading
        : (isActive ? DsButtonState.enabled : DsButtonState.disabled);

    return DsButton(
      key: const Key('login_v2_submit_button'),
      text: 'Lanjutkan',
      loadingText: 'Memproses...',
      state: buttonState,
      onPressed: onPressed,
    );
  }
}
