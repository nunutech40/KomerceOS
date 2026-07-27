import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import 'package:komtim_partner/common/global/router/router_utils.dart';
import 'package:komtim_partner/features/superapp/features/authentication/widgets/email_check_header.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../common/enum_status.dart';
import '../bloc/login_bloc.dart';
import '../widgets/login_error_popups.dart';
import '../widgets/verification_required_bottom_sheet.dart';

class LoginPage extends StatefulWidget {
  final String email;

  const LoginPage({super.key, required this.email});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  String? _inlineError;
  Timer? _debounce;
  bool _wasEmailChecked = false;
  bool _showSuccessAnim = false;

  /// Guard: cegah listener trigger saat controller baru di-init dengan initial value.
  /// Tanpa ini, addListener dipanggil saat text berubah dari '' → widget.email,
  /// yang memicu debounce check email dan menghasilkan snackbar anomali.
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.email);
    _passwordController = TextEditingController();
    // Set flag setelah init agar listener tidak trigger saat initial value di-set
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isInitialized = true;
    });
    _emailController.addListener(_onFormChanged);
    _passwordController.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    if (email.isEmpty || email.contains(' ')) return false;
    return RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$').hasMatch(email);
  }

  void _onFormChanged() {
    // Guard: abaikan panggilan pertama saat controller baru di-init
    if (!_isInitialized) return;

    final blocState = context.read<LoginBloc>().state;
    final email = _emailController.text;

    // Validasi format email secara real-time
    setState(() {
      if (!blocState.isEmailChecked) {
        if (email.isEmpty) {
          _inlineError = null;
        } else if (email.contains(' ')) {
          _inlineError = 'Email tidak boleh mengandung spasi';
        } else if (!_isValidEmail(email)) {
          _inlineError = 'Format email tidak valid';
        } else {
          _inlineError = null;
        }
      } else {
        _inlineError = null;
      }
    });

    // Jika email berubah saat sudah checked → reset password field juga
    if (blocState.isEmailChecked && blocState.username != email) {
      _passwordController.clear();
    }

    // Auto check email via debounce (seperti komcard_mobile)
    if (!blocState.isEmailChecked) {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 1200), () {
        if (!mounted) return;
        if (email.isNotEmpty && _isValidEmail(email)) {
          _onCheckEmail(context);
        }
      });
    }

    // Sync state ke BLoC setiap perubahan (hanya jika ada perubahan)
    if (blocState.username != _emailController.text) {
      context
          .read<LoginBloc>()
          .add(LoginEmailChangedEvent(email: _emailController.text));
    }
    if (blocState.password != _passwordController.text) {
      context
          .read<LoginBloc>()
          .add(LoginPasswordChangedEvent(password: _passwordController.text));
    }
  }

  /// Tombol "Lanjut" — Check Email ke API
  void _onCheckEmail(BuildContext context) {
    _debounce?.cancel(); // batalkan debounce jika user klik manual
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _inlineError = 'Email wajib diisi');
      return;
    }
    if (!_isValidEmail(email)) {
      setState(() => _inlineError = 'Format email tidak valid');
      return;
    }
    setState(() => _inlineError = null);
    context.read<LoginBloc>().add(LoginEmailChangedEvent(email: email));
    context.read<LoginBloc>().add(const LoginButtonPressedEvent());
  }

  /// Tombol "Masuk" — Login ke API
  void _onSubmitLogin(BuildContext context) {
    context
        .read<LoginBloc>()
        .add(LoginPasswordChangedEvent(password: _passwordController.text));
    context.read<LoginBloc>().add(const LoginButtonPressedEvent());
  }

  void _onBlocStateChanged(BuildContext context, LoginState state) {
    // Tangani animasi sukses
    if (state.isEmailChecked && !_wasEmailChecked) {
      _wasEmailChecked = true;
      setState(() {
        _showSuccessAnim = true;
      });
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            _showSuccessAnim = false;
          });
        }
      });
    } else if (!state.isEmailChecked && _wasEmailChecked) {
      _wasEmailChecked = false;
    }

    if (state.isAccountBanned) {
      // Akun tidak aktif → tampilkan Bottom Sheet "Akun Tidak Aktif"
      LoginErrorPopups.showAccountNotActive(context, () async {
        final Uri url = Uri.parse('https://partner.komerce.id/login');
        if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
          debugPrint('Could not launch $url');
        }
      });
      context.read<LoginBloc>().add(LoginStatusResetEvent());
    } else if (state.isVerificationRequired &&
        state.unverifiedProducts.isNotEmpty) {
      // Tampilkan Bottom Sheet Verifikasi
      VerificationRequiredBottomSheet.show(
        context: context,
        email: state.username,
        partnerProducts: state.unverifiedProducts,
      );
      context.read<LoginBloc>().add(LoginStatusResetEvent());
    } else if (state.status == RequestStatus.failure) {
      final errorMsg = state.passwordErrorMessage.isNotEmpty
          ? state.passwordErrorMessage
          : state.usernameErrorMessage;

      final lowerError = errorMsg.toLowerCase();

      // Saat fase check email (sebelum password dimasukkan), abaikan error yang
      // hanya relevan di fase login (login_attempt, lock, dsb.).
      // Error lain (user not registered, user is non partner) tetap tampilkan via bottom sheet.
      final isCheckEmailPhase =
          !state.isEmailChecked && state.passwordErrorMessage.isEmpty;

      // Saat fase check email, error ditampilkan INLINE di bawah TextField.
      // Kecuali error khusus yang butuh Bottom Sheet (seperti user not registered), kita abaikan SnackBar.
      if (isCheckEmailPhase) {
        if (!lowerError.contains('user not registered') &&
            !lowerError.contains('user is non partner')) {
          // Reset status agar tidak terus-terusan trigger failure state, tapi biarkan usernameErrorMessage
          context.read<LoginBloc>().add(LoginStatusResetEvent());
          return;
        }
      }

      if (lowerError.contains('login_attempt') ||
          lowerError.contains('lock') ||
          lowerError.contains('please wait 24 hour') ||
          lowerError.contains('incorrect password') ||
          lowerError.contains('wrong password')) {
        int remaining = 0;
        int lock = 0;
        final attemptMatch =
            RegExp(r'login_attempt:\s*(\d+)').firstMatch(errorMsg);
        final lockMatch = RegExp(r'lock:\s*(\d+)').firstMatch(errorMsg);

        if (attemptMatch != null) {
          // login_attempt dari API = SISA percobaan (Remaining)
          remaining = int.tryParse(attemptMatch.group(1) ?? '0') ?? 0;
        } else if (lowerError.contains('incorrect password') ||
            lowerError.contains('wrong password')) {
          // Jika backend tidak mengirimkan sisa percobaan di kegagalan pertama, asumsikan sisa 2
          remaining = 2;
        }
        if (lockMatch != null) {
          lock = int.tryParse(lockMatch.group(1) ?? '0') ?? 0;
        }

        if (lock == 1 ||
            remaining == 0 ||
            lowerError.contains('please wait 24 hour')) {
          DsBottomSheet.show(
            context: context,
            title: 'Gagal Login',
            description:
                'Anda telah gagal login sebanyak 3 kali.\nSilakan coba kembali dalam 24 jam ke\ndepan atau reset password',
            image: SvgPicture.asset(
              'assets/images/superapp/auth/attempt_count_login.svg',
              height: 200,
            ),
            secondaryButtonText: 'Kembali',
            onSecondaryPressed: () {
              Navigator.pop(context);
              context.read<LoginBloc>().add(LoginStatusResetEvent());
            },
            primaryButtonText: 'Reset Password',
            onPrimaryPressed: () {
              Navigator.pop(context);
              context.pushNamed(PAGES.forgotPasswrod.screenName);
            },
            isDismissible: true,
          );
        } else {
          DsBottomSheet.show(
            context: context,
            title: 'Gagal Login',
            description:
                'Periksa kembali email dan password\nyang kamu masukkan. Tersisa $remaining kali\npercobaan.',
            image: SvgPicture.asset(
              'assets/images/superapp/auth/attempt_count_login.svg',
              height: 200,
            ),
            secondaryButtonText: 'Kembali',
            onSecondaryPressed: () {
              Navigator.pop(context);
              context.read<LoginBloc>().add(LoginStatusResetEvent());
            },
            primaryButtonText: 'Coba Lagi',
            onPrimaryPressed: () {
              Navigator.pop(context);
              context.read<LoginBloc>().add(LoginStatusResetEvent());
            },
            isDismissible: true,
          );
        }
      } else if (lowerError.contains('user not registered')) {
        DsBottomSheet.show(
          context: context,
          title: 'Belum Ada Produk Terhubung',
          description:
              'Kami tidak menemukan produk yang terhubung dengan akun ini. Hubungkan atau daftarkan produk untuk mulai menggunakan layanan yang tersedia.',
          image: SvgPicture.asset(
            'assets/images/superapp/auth/account_not_active.svg',
            height: 200,
          ),
          secondaryButtonText: 'Kembali',
          onSecondaryPressed: () {
            Navigator.pop(context);
            context.read<LoginBloc>().add(LoginStatusResetEvent());
          },
          primaryButtonText: 'Jelajahi Produk',
          onPrimaryPressed: () async {
            Navigator.pop(context);
            context.read<LoginBloc>().add(LoginStatusResetEvent());
            final Uri url = Uri.parse('https://komerce.id/');
            if (!await launchUrl(url)) {
              debugPrint('Could not launch \$url');
            }
          },
          isDismissible: true,
        );
      } else if (lowerError.contains('user is non partner')) {
        DsBottomSheet.show(
          context: context,
          title: 'Akun Terdaftar di Peran Lain',
          description:
              'Akun kamu terdaftar di peran lain.\nTenang, kamu bisa menanyakan hal ini\nke live chat Customer Support.',
          image: SvgPicture.asset(
            'assets/images/superapp/auth/account_not_active.svg',
            height: 200,
          ),
          secondaryButtonText: 'Kembali',
          onSecondaryPressed: () {
            Navigator.pop(context);
            context.read<LoginBloc>().add(LoginStatusResetEvent());
          },
          primaryButtonText: 'Hubungi Customer Support',
          onPrimaryPressed: () async {
            Navigator.pop(context);
            context.read<LoginBloc>().add(LoginStatusResetEvent());
            final Uri url = Uri.parse('https://partner.komerce.id/');
            if (!await launchUrl(url)) {
              debugPrint('Could not launch \$url');
            }
          },
          isDismissible: true,
        );
      } else {
        // Tampilkan error umum
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: AppColors.errorBase,
          ),
        );
        context.read<LoginBloc>().add(LoginStatusResetEvent());
      }
    } else if (state.status == RequestStatus.success) {
      // Navigasi ke halaman beranda sudah di-handle oleh GoRouter via AuthBloc.
      // Tidak perlu menampilkan SnackBar sukses.
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginBloc, LoginState>(
      listener: _onBlocStateChanged,
      builder: (context, state) {
        final isLoading = state.status == RequestStatus.loading;

        return Scaffold(
          backgroundColor: AppColors.background,
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;
                return SingleChildScrollView(
                  child: Stack(
                    children: [
                      // Background SVG — ikut scroll bersama konten
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
                      // Konten — non-positioned, menentukan tinggi Stack
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.pageMarginLg,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: (constraints.maxHeight * 0.20)
                                  .clamp(80.0, 220.0),
                            ),
                            // --- Header ---
                            const AuthHeader(
                              title: 'Masuk ke Akun Kamu',
                              subtitle:
                                  'Pantau transaksi bisnis kamu kapan aja,\nlangsung dari aplikasi',
                            ),
                            const SizedBox(height: AppSpacing.xl),

                            // --- Card Form ---
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.lg),
                                border: Border.all(color: AppColors.grey200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  DsEmailInput(
                                    label: 'Email',
                                    controller: _emailController,
                                    errorText: _inlineError,
                                  ),
                                  // Server-side status messages (with icons)
                                  if (state.usernameErrorMessage.isNotEmpty &&
                                      _inlineError == null) ...[
                                    const SizedBox(height: AppSpacing.xs2),
                                    Row(
                                      children: [
                                        Container(
                                          width: 16,
                                          height: 16,
                                          decoration: BoxDecoration(
                                            color: AppColors.bgLight,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: AppColors.errorBase,
                                                width: 1.5),
                                          ),
                                          child: const Center(
                                            child: Icon(
                                              Icons.close_rounded,
                                              size: 10,
                                              color: AppColors.errorBase,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.xs2),
                                        Text(
                                          state.usernameErrorMessage
                                                  .toLowerCase()
                                                  .contains(
                                                      'user not registered')
                                              ? 'Email belum terdaftar'
                                              : state.usernameErrorMessage,
                                          style: AppTypography.bodySmRegular
                                              .copyWith(
                                            color: AppColors.errorBase,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ] else if (_showSuccessAnim &&
                                      _inlineError == null) ...[
                                    const SizedBox(height: AppSpacing.xs),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.check_circle_rounded,
                                          size: 16,
                                          color: AppColors.successBase,
                                        ),
                                        const SizedBox(width: AppSpacing.xs),
                                        Text(
                                          'Email berhasil ditemukan',
                                          style: AppTypography.bodySmRegular
                                              .copyWith(
                                            color: AppColors.successBase,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  if (state.isEmailChecked &&
                                      !_showSuccessAnim) ...[
                                    const SizedBox(height: AppSpacing.lg),
                                    DsPasswordField(
                                      label: 'Password',
                                      controller: _passwordController,
                                      errorText: (_passwordController
                                                  .text.isNotEmpty &&
                                              _passwordController.text.length <
                                                  8)
                                          ? 'Karakter harus minimal 8 karakter'
                                          : null,
                                      topTrailing: GestureDetector(
                                        onTap: () {
                                          context.pushNamed(
                                            PAGES.forgotPasswrod.screenName,
                                          );
                                        },
                                        child: Text(
                                          'Lupa Password?',
                                          style: AppTypography.labelMdSemiBold
                                              .copyWith(
                                            color: AppColors.primaryBase,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: AppSpacing.xl),
                                  if (!state.isEmailChecked || _showSuccessAnim)
                                    DsButton(
                                      text: 'Lanjut',
                                      loadingText: _showSuccessAnim
                                          ? 'Memuat halaman login...'
                                          : 'Memverifikasi email...',
                                      state: (isLoading || _showSuccessAnim)
                                          ? DsButtonState.loading
                                          : ((_isValidEmail(
                                                      _emailController.text) ||
                                                  _showSuccessAnim)
                                              ? DsButtonState.enabled
                                              : DsButtonState.disabled),
                                      onPressed: () => _onCheckEmail(context),
                                    )
                                  else
                                    DsButton(
                                      text: 'Masuk',
                                      loadingText: 'Memuat...',
                                      state: isLoading
                                          ? DsButtonState.loading
                                          : ((_emailController
                                                      .text.isNotEmpty &&
                                                  _passwordController
                                                          .text.length >=
                                                      8)
                                              ? DsButtonState.enabled
                                              : DsButtonState.disabled),
                                      onPressed: () => _onSubmitLogin(context),
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
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
