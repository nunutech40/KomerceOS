import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/mixin/handling_error_page.dart';
import 'package:komtim_partner/common/string.dart';

import 'package:komtim_partner/common/styles.dart';
import '../../../common/enum_status.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/global/pages/custom_circular_indicator.dart';
import '../../../common/global/router/app_router.dart';
import '../../../common/global/router/router_utils.dart';
import '../../../common/global/widgets/confirmation_dialog_oke.dart';
import '../../../common/global/widgets/custom_button.dart';
import '../../../common/global/widgets/custom_text_field.dart';
import '../bloc/forgot_password_bloc.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();

  static void showConfirmation(
      BuildContext context, ForgotPasswordBloc mainBloc) {
    ConfirmationDialogOke.show(
      context,
      onYesPressed: () {
        Navigator.of(context).pop();
        AppRouter.router.go(PAGES.login.screenPath);
      },
    );
  }
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage>
    with ErrorHandlingMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ForgotPasswordBloc, ForgotPasswordState>(
        listener: (context, state) {
          if (state.status == RequestStatus.success) {
            ForgotPasswordPage.showConfirmation(
                context, context.read<ForgotPasswordBloc>());
          } else if (state.status == RequestStatus.failure) {
            handleFailureState(context, state, state.message);
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              const _ForgotPasswordForm(),
              if (state.status == RequestStatus.loading)
                const Center(child: CustomCircularIndicator()),
            ],
          );
        },
      ),
    );
  }
}

class _ForgotPasswordForm extends StatelessWidget {
  const _ForgotPasswordForm({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: SingleChildScrollView(
              // Add this
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _ForgotPassHeader(),
                  const SizedBox(height: 24.0),
                  const Text(
                    Strings.dialog_link_change_pass,
                    style: AppTypography.regular12,
                  ),
                  const SizedBox(height: 32.0),
                  _inputEmail(),
                  const SizedBox(height: 24.0),
                  const _ForgotPasswordText(),
                  const SizedBox(height: 32.0),
                  _SubmitButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ForgotPassHeader extends StatelessWidget {
  const _ForgotPassHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Strings.label_forget,
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
          textAlign: TextAlign.left,
        ),
        Text(
          Strings.label_pass,
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
          textAlign: TextAlign.left,
        ),
      ],
    );
  }
}

class _inputEmail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ForgotPasswordBloc, ForgotPasswordState>(
      builder: (context, state) {
        return CustomTextField(
          label: Strings.label_email,
          hint: 'email@gmail.com',
          errorText: state.emailErrorMessage,
          onChanged: (value) {
            context
                .read<ForgotPasswordBloc>()
                .add(ForgotEmailChangedEvent(email: value));
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
    return Row(
      children: [
        const Text(
          Strings.label_remember_pass,
          style: TextStyle(
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 2), // Add some spacing between the texts
        GestureDetector(
          onTap: () {
            AppRouter.router.pop();
          },
          child: const Text(
            Strings.label_back_login,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
          ),
        )
      ],
    );
  }
}

class _SubmitButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: CustomButton(
        text: Strings.label_send,
        onPressed: () {
          context
              .read<ForgotPasswordBloc>()
              .add(const SendButtonPressedEvent());
        },
      ),
    );
  }
}
