import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import 'package:komtim_partner/common/global/router/router_utils.dart';

import '../widgets/email_check_header.dart';

class SuccessNewPasswordPage extends StatefulWidget {
  const SuccessNewPasswordPage({super.key});

  @override
  State<SuccessNewPasswordPage> createState() => _SuccessNewPasswordPageState();
}

class _SuccessNewPasswordPageState extends State<SuccessNewPasswordPage> {
  Timer? _redirectTimer;
  int _redirectSeconds = 3;

  @override
  void initState() {
    super.initState();
    _startRedirectTimer();
  }

  @override
  void dispose() {
    _redirectTimer?.cancel();
    super.dispose();
  }

  void _startRedirectTimer() {
    _redirectSeconds = 3;
    _redirectTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_redirectSeconds > 1) {
        setState(() {
          _redirectSeconds--;
        });
      } else {
        timer.cancel();
        _goToLogin();
      }
    });
  }

  void _goToLogin() {
    _redirectTimer?.cancel();
    context.goNamed(PAGES.login.screenName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppSpacing.pageMarginLg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: AppSpacing.xl2),
              const AuthHeader(
                title: 'Password Berhasil Diperbarui',
                subtitle:
                    'Password akunmu berhasil diperbarui. Kamu akan diarahkan\nke halaman login untuk masuk menggunakan\npassword baru.',
              ),
              const SizedBox(height: AppSpacing.xl),
              SvgPicture.asset(
                'assets/images/superapp/auth/success_reset_password.svg',
                height: 250,
                // Fallback icon if asset is not present
                placeholderBuilder: (context) => const Icon(
                  Icons.check_circle_rounded,
                  size: 100,
                  color: AppColors.successBase,
                ),
              ),
              const SizedBox(height: AppSpacing.xl2),
              DsButton(
                text: 'Masuk Sekarang',
                onPressed: _goToLogin,
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Mengalihkan ke login dalam $_redirectSeconds detik...',
                style: AppTypography.bodySmRegular.copyWith(
                  color: AppColors.grey600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl2),
            ],
          ),
        ),
      ),
    );
  }
}
