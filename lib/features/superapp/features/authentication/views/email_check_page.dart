import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:komtim_partner/common/global/bloc/auth/auth_bloc.dart';
import 'package:komtim_partner/common/global/router/router_utils.dart';

import 'package:url_launcher/url_launcher.dart';
import '../bloc/check_email_bloc.dart';
import '../widgets/email_check_body.dart';
import '../widgets/login_error_popups.dart';
import '../widgets/verification_required_bottom_sheet.dart';

// -----------------------------------------------------------------------------
// EmailCheckPage
//
// Step pertama alur login — user memasukkan email.
// Halaman ini menerima BlocProvider(CheckEmailBloc) dari Router.
//
// Bertanggung jawab atas:
//   - TextEditingController lifecycle (init + dispose)
//   - Validasi format realtime dan pengecekan API otomatis dengan debounce
//   - Dispatch event ke BLoC
//   - Handle side effects dari BLoC state (SnackBar, navigasi)
// -----------------------------------------------------------------------------

class EmailCheckPage extends StatefulWidget {
  const EmailCheckPage({super.key});

  @override
  State<EmailCheckPage> createState() => _EmailCheckPageState();
}

class _EmailCheckPageState extends State<EmailCheckPage> {
  late final TextEditingController _emailController;
  Timer? _emailDebounce;
  String _lastEmailText = '';
  String? _pendingEmail;
  String? _inlineError;
  bool _navigatingToPassword = false;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _emailController.addListener(_onEmailChanged);
    context.read<CheckEmailBloc>().add(const CheckEmailReset());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !context.read<AuthBloc>().state.sessionExpired) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Sesi berakhir. Silakan masuk kembali.'),
      ));
    });
  }

  @override
  void dispose() {
    _emailDebounce?.cancel();
    _emailController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Email listener — validasi client-side realtime
  // ---------------------------------------------------------------------------

  void _onEmailChanged() {
    final email = _emailController.text;
    // Controller listeners also fire for selection/focus changes. Returning
    // from Password must not immediately send the same email again.
    if (email == _lastEmailText) return;
    _lastEmailText = email;
    _emailDebounce?.cancel();
    _pendingEmail = null;
    // Reset BLoC saat email berubah — termasuk saat sedang Loading.
    // Tanpa ini: jika API request lama selesai setelah email berganti,
    // CheckEmailFailure-nya masih trigger snackbar (race condition).
    context.read<CheckEmailBloc>().add(const CheckEmailReset());

    // Bersihkan snackbar yang mungkin masih di-queue dari halaman sebelumnya
    // (misal: LoginPage) agar tidak muncul secara anomali di halaman ini.
    ScaffoldMessenger.of(context).clearSnackBars();

    setState(() {
      if (email.isEmpty) {
        _inlineError = null;
      } else if (email.contains(' ')) {
        _inlineError = 'Email tidak boleh mengandung spasi';
      } else if (!_isValidEmail(email)) {
        _inlineError = 'Format email tidak valid';
      } else {
        _inlineError = null;
      }
    });

    _navigatingToPassword = false;
    if (_isValidEmail(email)) {
      _emailDebounce = Timer(const Duration(milliseconds: 500), () {
        if (!mounted ||
            ModalRoute.of(context)?.isCurrent != true ||
            _emailController.text != email) {
          return;
        }
        _onSubmit();
      });
    }
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
    _emailDebounce?.cancel();
    if (_navigatingToPassword) return;
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _inlineError = 'Email wajib diisi');
      return;
    }
    if (!_isValidEmail(email)) {
      setState(() => _inlineError = 'Format email tidak valid');
      return;
    }
    if (_pendingEmail == email) return;
    _pendingEmail = email;
    context.read<CheckEmailBloc>().add(CheckEmailSubmitted(email));
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CheckEmailBloc, CheckEmailState>(
      listener: _onBlocStateChanged,
      builder: (context, state) {
        return EmailCheckBody(
          emailController: _emailController,
          // An app-scoped result from a previous route/session must not flash
          // on a new Email page before its reset event has been processed.
          blocState: _pendingEmail == null ? CheckEmailInitial() : state,
          inlineError: _inlineError,
          onSubmit: _onSubmit,
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // BLoC listener
  // ---------------------------------------------------------------------------

  void _onBlocStateChanged(BuildContext context, CheckEmailState state) {
    if (_pendingEmail == null || ModalRoute.of(context)?.isCurrent != true) {
      return;
    }

    if (state is CheckEmailFailure) {
      _pendingEmail = null;
      if (LoginErrorPopups.isTeamInternalBlocked(state.message)) {
        LoginErrorPopups.showTeamInternalBlocked(context);
      } else if (LoginErrorPopups.isOtherRoleError(state.message)) {
        LoginErrorPopups.showOtherRole(context);
      } else {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(state.message)));
      }
    }

    if (state is CheckEmailFound) {
      if (_navigatingToPassword ||
          state.email.trim().toLowerCase() !=
              _emailController.text.trim().toLowerCase()) {
        return;
      }
      _navigatingToPassword = true;
      _emailDebounce?.cancel();
      _pendingEmail = null;
      FocusScope.of(context).unfocus();
      // The email-check bloc is app-scoped. Clear its successful result before
      // pushing LoginPage so returning to this route (or logging out later)
      // cannot leave a blank email field paired with a stale success/loading UI.
      context.read<CheckEmailBloc>().add(const CheckEmailReset());
      context
          .pushNamed(
        PAGES.login.screenName,
        extra: state.email,
      )
          .then((_) {
        if (mounted) _navigatingToPassword = false;
      });
    }

    if (state is CheckEmailBanned) {
      _pendingEmail = null;
      LoginErrorPopups.showAccountNotActive(context, () async {
        final Uri url = Uri.parse('https://wa.me/6281234567890');
        if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
          debugPrint('Could not launch $url');
        }
      });
    }

    if (state is CheckEmailNotAllowed) {
      _pendingEmail = null;
      VerificationRequiredBottomSheet.show(
        context: context,
        email: state.email,
        partnerProducts: state.partnerProducts,
      );
    }
  }
}
