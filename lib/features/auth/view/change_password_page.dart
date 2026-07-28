import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komtim_partner/DI/injection.dart' as di;
import 'package:komtim_partner/common/global/mixin/handling_error_page.dart';
import 'package:komtim_partner/common/global/pages/custom_circular_indicator.dart';
import 'package:komtim_partner/common/string.dart';
import '../../../common/enum_status.dart';
import '../../../common/styles.dart';
import '../../../common/global/router/app_router.dart';
import '../../../common/global/widgets/confirmation_dialog.dart';
import '../../../common/global/widgets/confirmation_dialog_oke.dart';
import '../../../common/global/widgets/custom_button.dart';
import '../../../common/global/widgets/custom_password_field.dart';
import 'package:komtim_partner/common/global/bloc/auth/auth_bloc.dart';
import 'package:komtim_partner/common/global/bloc/auth/auth_event.dart';
import '../bloc/change_password_bloc.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({Key? key}) : super(key: key);

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();

  static void showConfirmation(
      BuildContext context, ChangePasswordBloc changePasswordBloc) {
    ConfirmationDialogOke.show(
      context,
      onYesPressed: () async {
        Navigator.of(context).pop();
        di.locator<AuthBloc>().add(AuthLogoutRequested());
      },
    );
  }

  static void showConfirmationChangePass(BuildContext context,
      ChangePasswordBloc changePasswordBloc, String textConfir) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          onYesPressed: () {
            changePasswordBloc.add(const ChangePassButtonPressedEvent());
            Navigator.of(context).pop();
          },
          onNoPressed: () {
            Navigator.of(context).pop();
          },
          textConfirmation: textConfir,
        );
      },
    );
  }
}

class _ChangePasswordPageState extends State<ChangePasswordPage>
    with ErrorHandlingMixin {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ChangePasswordBloc, ChangePasswordState>(
        listener: (context, state) {
          if (state.status == RequestStatus.success) {
            ChangePasswordPage.showConfirmation(
                context, context.read<ChangePasswordBloc>());
          } else if (state.status == RequestStatus.failure) {
            handleFailureState(context, state, state.message);
          }
        },
        builder: (context, state) => Stack(
          children: [
            Column(
              children: [
                AppBar(
                  title: const Text(Strings.label_change_pass,
                      style: AppTypography.interSemiBold16),
                  leading: IconButton(
                    icon: SvgPicture.asset('assets/images/ic-arrow-left.svg'),
                    onPressed: () => AppRouter.router.pop(),
                  ),
                ),
                Expanded(child: _buildChangePasswordBody())
              ],
            ),
            if (state.status == RequestStatus.loading) _buildLoadingOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildChangePasswordBody() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  const SizedBox(height: 2.0),
                  _OldPassword(),
                  const SizedBox(height: 24.0),
                  _NewPassword(),
                  const SizedBox(height: 24.0),
                  _ConfirmPassword(),
                  const SizedBox(height: 24.0),
                ],
              ),
              _SubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black38,
        child: const Center(
          child: CustomCircularIndicator(),
        ),
      ),
    );
  }
}

class _NewPassword extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChangePasswordBloc, ChangePasswordState>(
      builder: (context, state) {
        return CustomPasswordField(
          label: Strings.label_new_pass,
          hint: '',
          errorText: state.newPassErrorMessage.isNotEmpty
              ? state.newPassErrorMessage
              : null,
          onChanged: (value) {
            context
                .read<ChangePasswordBloc>()
                .add(ChangeNewPasswordChangedEvent(newPass: value));
          },
        );
      },
    );
  }
}

class _OldPassword extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChangePasswordBloc, ChangePasswordState>(
      builder: (context, state) {
        return CustomPasswordField(
          label: Strings.label_old_pass,
          hint: '',
          errorText: state.oldPassErrorMessage.isNotEmpty
              ? state.oldPassErrorMessage
              : null,
          onChanged: (value) {
            context
                .read<ChangePasswordBloc>()
                .add(ChangeOldPasswordChangedEvent(oldPass: value));
          },
        );
      },
    );
  }
}

class _ConfirmPassword extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChangePasswordBloc, ChangePasswordState>(
      builder: (context, state) {
        return CustomPasswordField(
          label: Strings.label_confirm_new_pass,
          hint: '',
          errorText: state.confirmPassErrorMessage.isNotEmpty
              ? state.confirmPassErrorMessage
              : null,
          onChanged: (value) {
            context
                .read<ChangePasswordBloc>()
                .add(ChangeConfirmPasswordChangedEvent(confirmPass: value));
          },
        );
      },
    );
  }
}

class _SubmitButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChangePasswordBloc, ChangePasswordState>(
      builder: (context, state) {
        bool isButtonActive = state.isSubmitButtonActive;

        return SizedBox(
          width: double.infinity,
          child: CustomButton(
            text: Strings.label_save,
            isActive: isButtonActive, // Use the bool value here
            onPressed: () {
              ChangePasswordPage.showConfirmationChangePass(
                  context,
                  context.read<ChangePasswordBloc>(),
                  Strings.dialog_confirm_change_pass);
            },
          ),
        );
      },
    );
  }
}
