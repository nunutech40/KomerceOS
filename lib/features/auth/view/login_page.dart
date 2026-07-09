import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komtim_partner/DI/injection.dart' as di;
import 'package:komtim_partner/common/global/mixin/handling_error_page.dart';
import 'package:komtim_partner/common/global/pages/custom_circular_indicator.dart';
import 'package:komtim_partner/common/string.dart';
import 'package:komtim_partner/common/styles.dart';
import 'package:komtim_partner/firebase_options.dart';

import '../../../common/enum_status.dart';
import '../../../common/global/router/app_router.dart';
import '../../../common/global/router/router_utils.dart';
import '../../../common/global/widgets/custom_button.dart';
import '../../../common/global/widgets/custom_password_field.dart';
import '../../../common/global/widgets/custom_text_field.dart';
import '../../../core/data/datasources/preferences/shared_pref.dart';
import '../bloc/login_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with ErrorHandlingMixin {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginBloc, LoginState>(
      listener: (context, state) {
        switch (state.status) {
          case RequestStatus.success:
            break;
          case RequestStatus.failure:
            handleFailureState(context, state, state.usernameErrorMessage);
            break;
          default:
            break;
        }
      },
      builder: (context, state) {
        return Stack(
          children: [
            const _LoginForm(),
            if (state.status == RequestStatus.loading)
              const CustomCircularIndicator(),
          ],
        );
      },
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: FullBody(),
    );
  }
}

class FullBody extends StatelessWidget {
  const FullBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: SingleChildScrollView(
            // Wrap with SingleChildScrollView
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _LoginHeader(),
                const SizedBox(height: 32.0),
                _LoginUsername(),
                const SizedBox(height: 24.0),
                _LoginPassword(),
                const SizedBox(height: 24.0),
                const _ForgotPasswordText(),
                const SizedBox(height: 32.0),
                const _SubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginHeader extends StatelessWidget {
  const _LoginHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Strings.label_login_to,
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
          textAlign: TextAlign.left,
        ),
        Text(
          Strings.label_your_account,
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
          textAlign: TextAlign.left,
        ),
      ],
    );
  }
}

class _LoginUsername extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        return CustomTextField(
          key: const Key('login_email_input'),
          label: Strings.label_username,
          hint: Strings.label_input_username,
          errorText: state.usernameErrorMessage.isNotEmpty
              ? state.usernameErrorMessage
              : null,
          onChanged: (value) {
            context.read<LoginBloc>().add(LoginEmailChangedEvent(email: value));
          },
        );
      },
    );
  }
}

class _LoginPassword extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        return CustomPasswordField(
          key: const Key('login_pass_input'),
          label: Strings.label_pass,
          hint: Strings.label_your_pass,
          errorText: state.passwordErrorMessage.isNotEmpty
              ? state.passwordErrorMessage
              : null,
          onChanged: (value) {
            context
                .read<LoginBloc>()
                .add(LoginPasswordChangedEvent(password: value));
          },
        );
      },
    );
  }
}

class _ForgotPasswordText extends StatelessWidget {
  const _ForgotPasswordText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AppRouter.router.push(PAGES.forgotPasswrod.screenPath);
      },
      child: const Text(
        Strings.label_forget_pass,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: primaryColor,
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({
    Key? key,
  }) : super(key: key);

  Future<void> _checkFcmToken(BuildContext context) async {
    final pref = di.locator<SharedPref>();
    String lastToken = '';

    lastToken = await pref.getFcmToken();
    if (!context.mounted) return;

    if (lastToken.isEmpty) {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      final fcmToken = await FirebaseMessaging.instance.getToken();
      await pref.saveFcmToken(fcmToken ?? '');
      if (!context.mounted) return;

      context.read<LoginBloc>().add(const LoginButtonPressedEvent());
    } else {
      context.read<LoginBloc>().add(const LoginButtonPressedEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: CustomButton(
        key: const Key('button_submit'),
        text: Strings.label_login,
        onPressed: () async {
          _checkFcmToken(context);
        },
      ),
    );
  }
}
