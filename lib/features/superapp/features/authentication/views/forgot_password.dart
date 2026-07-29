import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:komtim_partner/common/enum_status.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import 'package:komtim_partner/common/string.dart';

import '../bloc/check_email_bloc.dart';
import '../bloc/forgot_password_bloc.dart';
import '../bloc/forgot_password_event.dart';
import '../bloc/forgot_password_state.dart';
import '../widgets/email_check_header.dart';

// -----------------------------------------------------------------------------
// ForgotPasswordPage (Superapp)
//
// Halaman "Lupa Password" — user memasukkan email untuk menerima link reset.
//
// Alur UI (sesuai desain Figma):
//   1. Kosong  → tombol "Kirim" disabled
//   2. Terisi  → tombol "Kirim" aktif (oren)
//   3. Loading → spinner + "Memverifikasi email..."
//   4. Sukses  → tampilkan Bottom Sheet "Verifikasi Email"
//   5. Error   → border merah + pesan error inline
// -----------------------------------------------------------------------------

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  late final TextEditingController _emailController;
  String? _inlineError;
  String? _apiCheckError;
  Timer? _debounce;
  bool _isEmailChecked = false;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _emailController.addListener(_onEmailChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _emailController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Email listener
  // ---------------------------------------------------------------------------

  void _onEmailChanged() {
    final email = _emailController.text;

    setState(() {
      _isEmailChecked = false;
      if (email.isEmpty) {
        _inlineError = 'Email wajib diisi';
        _apiCheckError = null;
      } else if (email.contains(' ')) {
        _inlineError = 'Email tidak boleh mengandung spasi';
        _apiCheckError = null;
      } else if (!_isValidEmail(email)) {
        _inlineError = 'Format email tidak valid';
        _apiCheckError = null;
      } else {
        _inlineError = null;
      }
    });

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    if (_inlineError == null && email.isNotEmpty) {
      _debounce = Timer(const Duration(milliseconds: 1200), () {
        if (!mounted) return;
        context.read<CheckEmailBloc>().add(CheckEmailSubmitted(email));
      });
    }

    context
        .read<ForgotPasswordBloc>()
        .add(ForgotEmailChangedEvent(email: email));
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  bool _isValidEmail(String email) {
    if (email.isEmpty || email.contains(' ')) return false;
    return RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$').hasMatch(email);
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  void _onSubmit() {
    context.read<ForgotPasswordBloc>().add(const SendButtonPressedEvent());
  }

  // ---------------------------------------------------------------------------
  // BLoC listener — side effects
  // ---------------------------------------------------------------------------

  void _onBlocStateChanged(BuildContext context, ForgotPasswordState state) {
    if (state.status == RequestStatus.success && state.message == 'Success') {
      // Tampilkan Bottom Sheet "Verifikasi Email" hanya pada pengiriman pertama.
      // Jika resend (message == 'Resend success'), bottom sheet sudah terbuka.
      // countDown > 0 berarti server rate-limited → pakai countdown dari server
      _showVerifyEmailBottomSheet(
        context,
        state.email,
        initialCountDown: state.countDown > 0 ? state.countDown : 0,
      );
      context.read<ForgotPasswordBloc>().add(const SendStatusResetEvent());
    }

    if (state.status == RequestStatus.failure) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(state.message)));
      context.read<ForgotPasswordBloc>().add(const SendStatusResetEvent());
    }
  }

  // ---------------------------------------------------------------------------
  // Bottom Sheet — Verifikasi Email (sesuai desain Figma)
  // ---------------------------------------------------------------------------

  void _showVerifyEmailBottomSheet(
    BuildContext context,
    String email, {
    int initialCountDown = 0,
  }) {
    // Capture bloc reference BEFORE the builder closure.
    // Jika context sudah deactivated saat builder dipanggil ulang
    // (misal: deep link navigasi ke halaman lain), bloc tetap valid.
    final bloc = context.read<ForgotPasswordBloc>();

    showModalBottomSheet(
      context: context,
      isDismissible: true,
      enableDrag: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return BlocProvider.value(
          value: bloc,
          child: _VerifyEmailBottomSheetContent(
            email: email,
            initialCountDown: initialCountDown,
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
        listeners: [
          BlocListener<ForgotPasswordBloc, ForgotPasswordState>(
            listener: _onBlocStateChanged,
          ),
          BlocListener<CheckEmailBloc, CheckEmailState>(
            listener: (context, state) {
              if (state is CheckEmailFound ||
                  state is CheckEmailNotAllowed ||
                  state is CheckEmailBanned) {
                setState(() {
                  _apiCheckError = null;
                  _isEmailChecked = true;
                });
              } else if (state is CheckEmailFailure) {
                final lowerMsg = state.message.toLowerCase();
                if (lowerMsg.contains('not registered') ||
                    lowerMsg.contains('tidak valid') ||
                    lowerMsg.contains('tidak ditemukan')) {
                  setState(() {
                    _apiCheckError =
                        'Belum ada akun yang menggunakan email ini.';
                    _isEmailChecked = false;
                  });
                } else {
                  setState(() {
                    _apiCheckError = state.message;
                    _isEmailChecked = false;
                  });
                }
              }
            },
          ),
        ],
        child: BlocBuilder<ForgotPasswordBloc, ForgotPasswordState>(
          builder: (context, state) {
            final isLoading = state.status == RequestStatus.loading;
            final bool isUnregistered = state.status == RequestStatus.failure &&
                state.emailErrorMessage == Strings.label_email_not_registered;

            final String? apiError = isUnregistered
                ? 'Belum ada akun yang menggunakan email ini.'
                : (state.emailErrorMessage.isNotEmpty
                    ? state.emailErrorMessage
                    : null);

            // Prioritaskan error dari lokal, jika tidak ada, gunakan dari API
            final String? displayError =
                _inlineError ?? _apiCheckError ?? apiError;

            final email = _emailController.text.trim();
            final bool isButtonActive = email.isNotEmpty &&
                _isValidEmail(email) &&
                _inlineError == null &&
                _apiCheckError == null &&
                _isEmailChecked &&
                !isUnregistered;

            return Scaffold(
              backgroundColor: AppColors.background,
              resizeToAvoidBottomInset: false,
              body: SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final keyboardHeight =
                        MediaQuery.viewInsetsOf(context).bottom;
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
                                    title: 'Lupa Password',
                                    subtitle:
                                        'Tautan untuk mengatur ulang password akan dikirim\nmelalui email.',
                                  ),
                                  const SizedBox(height: AppSpacing.xl),

                                  // --- Card Form ---
                                  Container(
                                    width: double.infinity,
                                    padding:
                                        const EdgeInsets.all(AppSpacing.lg),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius:
                                          BorderRadius.circular(AppRadius.lg),
                                      border:
                                          Border.all(color: AppColors.grey200),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // --- Email Input ---
                                        DsEmailInput(
                                          label: 'Email',
                                          controller: _emailController,
                                          errorText: displayError,
                                        ),

                                        const SizedBox(height: AppSpacing.md),

                                        // --- Kembali Masuk link ---
                                        Center(
                                          child: Text.rich(
                                            TextSpan(
                                              text: 'Ayo! Kembali ',
                                              style: AppTypography.bodySmRegular
                                                  .copyWith(
                                                color: AppColors.grey600,
                                              ),
                                              children: [
                                                TextSpan(
                                                  text: 'Masuk',
                                                  style: AppTypography
                                                      .labelSmSemiBold
                                                      .copyWith(
                                                    color:
                                                        AppColors.primaryBase,
                                                  ),
                                                  recognizer:
                                                      TapGestureRecognizer()
                                                        ..onTap = () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: AppSpacing.xl),

                                        // --- Tombol Kirim ---
                                        DsButton(
                                          text: isUnregistered
                                              ? 'Lanjutkan'
                                              : 'Kirim',
                                          state: isLoading
                                              ? DsButtonState.loading
                                              : (isButtonActive
                                                  ? DsButtonState.enabled
                                                  : DsButtonState.disabled),
                                          loadingText: 'Memverifikasi...',
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
          },
        ));
  }
}

// =============================================================================
// _VerifyEmailBottomSheetContent
//
// Bottom sheet yang muncul setelah email berhasil dikirim.
// Sesuai desain Figma:
//   - Gambar ilustrasi amplop
//   - Judul "Verifikasi Email"
//   - Deskripsi: tautan reset dikirim ke email user
//   - Countdown 60 detik sebelum bisa "Kirim Ulang"
//   - Tombol "Konfirmasi/Masuk"
// =============================================================================

class _VerifyEmailBottomSheetContent extends StatefulWidget {
  final String email;
  final int initialCountDown;

  const _VerifyEmailBottomSheetContent({
    required this.email,
    this.initialCountDown = 0,
  });

  @override
  State<_VerifyEmailBottomSheetContent> createState() =>
      _VerifyEmailBottomSheetContentState();
}

class _VerifyEmailBottomSheetContentState
    extends State<_VerifyEmailBottomSheetContent> {
  Timer? _countdownTimer;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _startCountdown(widget.initialCountDown);
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  /// Format detik ke MM:SS jika > 60, atau langsung "Xs" jika <= 60
  String _formatCountdown(int seconds) {
    if (seconds <= 60) return '${seconds}s';
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
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
    context.read<ForgotPasswordBloc>().add(const ResendForgotPasswordEvent());
  }

  void _onBlocStateInBottomSheet(
      BuildContext context, ForgotPasswordState state) {
    if (state.status == RequestStatus.failure && state.countDown > 0) {
      // Server rate-limited → override countdown dengan detik dari server
      _startCountdown(state.countDown);
      // Reset bloc status agar tidak loop
      context.read<ForgotPasswordBloc>().add(const SendStatusResetEvent());
    } else if (state.status == RequestStatus.success) {
      // Resend berhasil → countdown sudah jalan (default 60s)
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: const Text('Email berhasil dikirim ulang'),
            backgroundColor: AppColors.successBase,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
        );
      context.read<ForgotPasswordBloc>().add(const SendStatusResetEvent());
    } else if (state.status == RequestStatus.failure && state.countDown == 0) {
      // Error biasa (bukan rate-limit)
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(state.message)));
      context.read<ForgotPasswordBloc>().add(const SendStatusResetEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isCountdownActive = _remainingSeconds > 0;

    return BlocListener<ForgotPasswordBloc, ForgotPasswordState>(
      listener: _onBlocStateInBottomSheet,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- Handle bar ---
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // --- Close button ---
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close, color: AppColors.grey600),
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // --- Ilustrasi ---
            SvgPicture.asset(
              'assets/images/superapp/auth/verify_code_email.svg',
              width: 200,
              height: 160,
              fit: BoxFit.contain,
            ),

            const SizedBox(height: AppSpacing.xl),

            // --- Title ---
            Text(
              'Verifikasi Email',
              style: AppTypography.headingMd.copyWith(
                color: AppColors.grey800,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSpacing.sm),

            // --- Description ---
            Text(
              'Tautan untuk mengatur ulang password telah dikirim ke email Anda. Silakan periksa kotak masuk email dan klik tautan di dalamnya.',
              style: AppTypography.bodyMdRegular.copyWith(
                color: AppColors.grey600,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSpacing.xl),

            // --- Kirim Ulang dengan countdown ---
            if (isCountdownActive)
              Text(
                'Kirim Ulang (${_formatCountdown(_remainingSeconds)})',
                style: AppTypography.bodyMdMedium.copyWith(
                  color: AppColors.grey400,
                ),
              )
            else
              BlocBuilder<ForgotPasswordBloc, ForgotPasswordState>(
                builder: (context, state) {
                  final isLoading = state.status == RequestStatus.loading;
                  if (isLoading) {
                    return Text(
                      'Mengirim...',
                      style: AppTypography.bodyMdMedium.copyWith(
                        color: AppColors.grey400,
                      ),
                    );
                  }
                  return GestureDetector(
                    onTap: _onResendTap,
                    child: Text(
                      'Kirim Ulang',
                      style: AppTypography.bodyMdMedium.copyWith(
                        color: AppColors.primaryBase,
                      ),
                    ),
                  );
                },
              ),

            const SizedBox(height: AppSpacing.xl),

            // --- Tombol Konfirmasi ---
            DsButton(
              text: 'Kembali Masuk',
              onPressed: () {
                Navigator.pop(context);
              },
            ),

            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}
