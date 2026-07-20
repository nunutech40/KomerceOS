import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import 'package:komtim_partner/features/superapp/features/authentication/bloc/verification_bloc.dart';

// -----------------------------------------------------------------------------
// EmailVerifSentPage
//
// Halaman yang ditampilkan setelah user klik "Kirim Ulang" pada
// Bottom Sheet status unverified.
// Menampilkan instruksi untuk mengecek email.
// Fitur: Kirim Ulang dengan countdown rate limit dari API.
// -----------------------------------------------------------------------------

class EmailVerifSentPage extends StatefulWidget {
  final String email;
  final String productName;
  final int initialCountDown;
  final String buttonLabel;

  const EmailVerifSentPage({
    super.key,
    required this.email,
    this.productName = '',
    this.initialCountDown = 0,
    this.buttonLabel = 'Masuk',
  });

  @override
  State<EmailVerifSentPage> createState() => _EmailVerifSentPageState();
}

class _EmailVerifSentPageState extends State<EmailVerifSentPage> {
  Timer? _countdownTimer;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    if (widget.initialCountDown > 0) {
      // Langsung mulai countdown jika ada initial value dari API
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startCountdown(widget.initialCountDown);
      });
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown(int seconds) {
    _countdownTimer?.cancel();
    setState(() {
      _remainingSeconds = seconds;
    });
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _remainingSeconds--;
      });
      if (_remainingSeconds <= 0) {
        timer.cancel();
      }
    });
  }

  void _onResendTap() {
    if (_remainingSeconds > 0) return;
    context.read<VerificationBloc>().add(
          VerificationResendEmail(
            email: widget.email,
            productName: widget.productName,
          ),
        );
  }

  void _onBlocStateChanged(BuildContext context, VerificationState state) {
    if (state.status == VerificationStatus.rateLimited && state.countDown > 0) {
      // API menolak: rate limited → mulai countdown
      _startCountdown(state.countDown);
      context.read<VerificationBloc>().add(const VerificationResetStatus());
    } else if (state.status == VerificationStatus.success) {
      // Berhasil kirim ulang → tidak ada countdown dari API,
      // UI tetap menampilkan "Kirim Ulang" tanpa countdown
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: const Text('Email verifikasi berhasil dikirim ulang'),
            backgroundColor: AppColors.successBase,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
        );
      context.read<VerificationBloc>().add(const VerificationResetStatus());
    } else if (state.status == VerificationStatus.failure &&
        state.errorMessage != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(state.errorMessage!),
            backgroundColor: AppColors.errorBase,
          ),
        );
      context.read<VerificationBloc>().add(const VerificationResetStatus());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VerificationBloc, VerificationState>(
      listener: _onBlocStateChanged,
      builder: (context, state) {
        final isLoading = state.status == VerificationStatus.loading;
        final bool isCountdownActive = _remainingSeconds > 0;

        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.grey800),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: Text(
              'Verifikasi Email',
              style: AppTypography.headingMd.copyWith(
                color: AppColors.grey800,
              ),
            ),
            titleSpacing: 0,
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  SvgPicture.asset(
                    'assets/images/superapp/auth/verify_code_email.svg',
                    width: 240,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: AppSpacing.xl2),
                  Text(
                    'Verifikasi Email',
                    style: AppTypography.headingMd.copyWith(
                      color: AppColors.grey800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Satu langkah lagi untuk mengakses akunmu. Cek email kamu dan klik link verifikasi untuk mengaktifkan akun',
                    style: AppTypography.bodyMdRegular.copyWith(
                      color: AppColors.grey600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl2),

                  // --- Kirim Ulang dengan Countdown ---
                  if (isLoading)
                    Text(
                      'Mengirim...',
                      style: AppTypography.bodyMdMedium.copyWith(
                        color: AppColors.grey400,
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: isCountdownActive ? null : _onResendTap,
                      child: Text(
                        isCountdownActive
                            ? 'Kirim Ulang ($_remainingSeconds detik)'
                            : 'Kirim Ulang',
                        style: AppTypography.bodyMdMedium.copyWith(
                          color: AppColors.primaryBase,
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  DsButton(
                    text: widget.buttonLabel,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
