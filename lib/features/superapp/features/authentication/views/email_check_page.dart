import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
//   - Validasi email client-side (tanpa API)
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
  String? _inlineError;
  Timer? _debounce;

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
  // Email listener — validasi client-side realtime
  // ---------------------------------------------------------------------------

  void _onEmailChanged() {
    final blocState = context.read<CheckEmailBloc>().state;

    if (blocState is! CheckEmailInitial && blocState is! CheckEmailLoading) {
      context.read<CheckEmailBloc>().add(const CheckEmailReset());
    }

    final email = _emailController.text;

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

    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 800), () {
      if (email.isEmpty) {
        context.read<CheckEmailBloc>().add(const CheckEmailReset());
        return;
      }
      if (_isValidEmail(email) && !email.contains(' ')) {
        _onSubmit();
      }
    });
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
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _inlineError = 'Email wajib diisi');
      return;
    }
    if (!_isValidEmail(email)) {
      setState(() => _inlineError = 'Format email tidak valid');
      return;
    }
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
          blocState: state,
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
    if (state is CheckEmailFailure) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(state.message)));
    }

    if (state is CheckEmailFound) {
      context.pushNamed(
        PAGES.login.screenName,
        extra: state.email,
      );
    }

    if (state is CheckEmailBanned) {
      LoginErrorPopups.showAccountNotActive(context, () async {
        final Uri url = Uri.parse('https://wa.me/6281234567890');
        if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
          debugPrint('Could not launch $url');
        }
      });
    }

    if (state is CheckEmailNotAllowed) {
      VerificationRequiredBottomSheet.show(
        context: context,
        email: state.email,
        partnerProducts: state.partnerProducts,
      );
    }
  }
}
