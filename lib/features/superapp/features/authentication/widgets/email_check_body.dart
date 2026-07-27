import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:komtim_partner/DI/injection.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';

import '../bloc/check_email_bloc.dart';
import '../bloc/verification_bloc.dart';
import '../views/email_verif_sent_page.dart';
import 'email_check_card.dart';
import 'email_check_header.dart';
import 'email_check_status.dart';

// -----------------------------------------------------------------------------
// EmailCheckBody
//
// Widget body halaman EmailCheckPage.
// Bertanggung jawab atas layout + semua widget presentasi:
//   - EmailCheckHeader
//   - EmailCheckCard
//   - Bottom sheet unverified (di-trigger dari listener)
//
// Tidak ada logika bisnis di sini — semua state datang dari BLoC via parameter.
// -----------------------------------------------------------------------------

class EmailCheckBody extends StatelessWidget {
  final TextEditingController emailController;
  final CheckEmailState blocState;
  final String? inlineError;
  final VoidCallback onSubmit;

  const EmailCheckBody({
    super.key,
    required this.emailController,
    required this.blocState,
    required this.inlineError,
    required this.onSubmit,
  });

  bool get _isButtonActive {
    if (blocState is CheckEmailLoading ||
        blocState is CheckEmailFound ||
        blocState is CheckEmailUnregistered) {
      return false;
    }
    return _isValidEmail(emailController.text);
  }

  bool _isValidEmail(String email) {
    if (email.isEmpty || email.contains(' ')) return false;
    return RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$').hasMatch(email);
  }

  EmailCheckStatus get _status => switch (blocState) {
        CheckEmailLoading() => EmailCheckStatus.loading,
        CheckEmailFound() => EmailCheckStatus.found,
        CheckEmailUnregistered() => EmailCheckStatus.unregistered,
        CheckEmailNotAllowed() => EmailCheckStatus.unverified,
        _ => EmailCheckStatus.idle,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background SVG — lebar penuh, tinggi proporsional (414×248)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AspectRatio(
              aspectRatio: 414 / 248,
              child: SvgPicture.asset(
                'assets/images/superapp/bg_auth.svg',
                fit: BoxFit.fill,
              ),
            ),
          ),
          SafeArea(
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
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            height:
                                (constraints.maxHeight * 0.20).clamp(80.0, 220.0),
                          ),
                          const AuthHeader(),
                          const SizedBox(height: AppSpacing.xl),
                          EmailCheckCard(
                            emailController: emailController,
                            status: _status,
                            inlineError: inlineError,
                            isButtonActive: _isButtonActive,
                            isLoading: blocState is CheckEmailLoading,
                            onSubmit: onSubmit,
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// EmailUnverifiedBottomSheet
//
// Bottom sheet yang muncul saat status email = unverified.
// Ditrigger dari BlocListener di EmailCheckPage.
//
// Tombol "Kembali" → tutup sheet + reset bloc + clear field
// Tombol "Kirim Ulang" → tutup sheet + navigate ke EmailVerifPage
// -----------------------------------------------------------------------------

class EmailUnverifiedBottomSheet {
  const EmailUnverifiedBottomSheet._();

  static void show({
    required BuildContext context,
    required String email,
    required VoidCallback onBack,
  }) {
    DsBottomSheet.show(
      context: context,
      isDismissible: true,
      title: 'Email kamu belum\ndiverifikasi',
      description:
          'Tenang, kamu bisa mengirim ulang\nverifikasi dengan klik \'Kirim Ulang\'',
      image: SvgPicture.asset(
        'assets/images/superapp/auth/verify_email.svg',
        width: 200,
        height: 300,
        fit: BoxFit.contain,
      ),
      secondaryButtonText: 'Kembali',
      onSecondaryPressed: () {
        Navigator.pop(context);
        onBack();
      },
      primaryButtonText: 'Kirim Ulang',
      onPrimaryPressed: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider<VerificationBloc>(
              create: (_) => locator<VerificationBloc>(),
              child: EmailVerifSentPage(email: email),
            ),
          ),
        );
      },
    );
  }
}
