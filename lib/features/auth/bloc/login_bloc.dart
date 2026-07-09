import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:komtim_partner/common/string.dart';
import 'package:recaptcha_enterprise_flutter/recaptcha_action.dart';

import '../../../common/enum_status.dart';
import '../../../core/domain/entities/partner_product_model.dart';
import '../../../core/domain/usecases/check_email_login_use_case.dart';
import '../../../core/domain/usecases/do_login_use_case.dart';
import '../../../core/domain/usecases/recaptcha_use_case.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final CheckEmailLoginUseCase checkEmailLoginUseCase;
  final DoLoginUseCase doLoginUseCase;
  final RecaptchaUseCase recaptchaUseCase;

  LoginBloc({
    required this.checkEmailLoginUseCase,
    required this.doLoginUseCase,
    required this.recaptchaUseCase,
  }) : super(const LoginState()) {
    on<LoginButtonPressedEvent>(_handleLoginWithUsernameAndPasswordEvent);
    on<LoginEmailChangedEvent>(_handleLoginUsernameChangedEvent);
    on<LoginPasswordChangedEvent>(_handleLoginPasswordChangedEvent);
    on<LoginStatusResetEvent>(_handleStatusResetEvent);
  }

  Future<void> _handleStatusResetEvent(
    LoginStatusResetEvent event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(
      status: RequestStatus.empty,
      usernameErrorMessage: '',
      passwordErrorMessage: '',
    ));
  }

  Future<void> _handleLoginUsernameChangedEvent(
    LoginEmailChangedEvent event,
    Emitter<LoginState> emit,
  ) async {
    // Reset status and errors when user types
    emit(state.copyWith(
      username: event.email,
      usernameErrorMessage: '',
      passwordErrorMessage: '',
      status: RequestStatus.empty,
      isEmailChecked: false,
    ));
  }

  Future<void> _handleLoginPasswordChangedEvent(
    LoginPasswordChangedEvent event,
    Emitter<LoginState> emit,
  ) async {
    // Verify that the password doesn't contain any whitespace
    if (event.password.contains(' ')) {
      emit(state.copyWith(
        password: event.password,
        passwordErrorMessage: Strings.label_pass_cant_use_space,
        status: RequestStatus.empty, // Prevent triggering failure listener
      ));
      return;
    }
    // Verify that the password is at least 8 characters long
    if (event.password.length < 8) {
      emit(state.copyWith(
        password: event.password,
        passwordErrorMessage: Strings.label_pass_min_8,
        status: RequestStatus.empty, // Prevent triggering failure listener
      ));
      return;
    }

    // If the password passed all validation checks, update the state without an error message
    // Also reset usernameErrorMessage to clear any previous API errors
    emit(state.copyWith(
      password: event.password,
      passwordErrorMessage: '',
      usernameErrorMessage: '',
      status: RequestStatus.empty,
    ));
  }

  Future<void> _handleLoginWithUsernameAndPasswordEvent(
    LoginButtonPressedEvent event,
    Emitter<LoginState> emit,
  ) async {
    if (!state.isEmailChecked) {
      // Step 1: hanya butuh email
      if (state.username.isEmpty) {
        emit(state.copyWith(
          status: RequestStatus.empty,
          usernameErrorMessage: Strings.label_username_cant_empty,
          passwordErrorMessage: '',
        ));
        return;
      }
    } else {
      // Step 2: butuh email + password
      if (state.username.isEmpty || state.password.isEmpty) {
        emit(state.copyWith(
          status: RequestStatus.empty,
          usernameErrorMessage:
              state.username.isEmpty ? Strings.label_username_cant_empty : '',
          passwordErrorMessage:
              state.password.isEmpty ? Strings.label_pass_cant_empty : '',
        ));
        return;
      }
    }

    // Emit the loading state first
    emit(state.copyWith(status: RequestStatus.loading));

    String? recaptchaToken;
    try {
      if (!recaptchaUseCase.isInitialized) {
        await recaptchaUseCase.initializeClient();
      }
      recaptchaToken = await recaptchaUseCase.getToken(RecaptchaAction.LOGIN());
    } catch (e) {
      debugPrint("reCAPTCHA failed: $e");
    }

    if (!state.isEmailChecked) {
      // 1. Check Email Status
      final checkResult = await checkEmailLoginUseCase.call(
        state.username,
        recaptchaToken: recaptchaToken ?? '',
      );

      checkResult.fold(
        (failure) {
          emit(state.copyWith(
            status: RequestStatus.failure,
            usernameErrorMessage: failure.message,
            passwordErrorMessage: '',
          ));
        },
        (data) {
          if (data.isBanned) {
            // banned == true → tampilkan Bottom Sheet "Akun Tidak Aktif"
            emit(state.copyWith(
              status: RequestStatus.empty,
              isAccountBanned: true,
            ));
          } else if (data.isAllowedLogin) {
            emit(state.copyWith(
              status: RequestStatus.empty,
              isEmailChecked: true,
              usernameErrorMessage: '',
            ));
          } else if (data.isNotAllowedLogin) {
            emit(state.copyWith(
              status: RequestStatus.empty,
              isVerificationRequired: true,
              unverifiedProducts: data.unverifiedProducts,
            ));
          } else {
            emit(state.copyWith(
              status: RequestStatus.failure,
              usernameErrorMessage: 'Akun tidak valid',
              passwordErrorMessage: '',
            ));
          }
        },
      );
      return;
    }

    // 2. Proceed to Login
    final result = await doLoginUseCase.execute(state.username, state.password,
        recaptchaToken: recaptchaToken);

    result.fold(
      (failure) {
        bool isIdentifiedError = true;
        String newMessageError = failure.message;

        if (newMessageError == Strings.label_invalid_user_or_pass ||
            newMessageError.contains(Strings.label_resource_not_found) ||
            newMessageError.contains(Strings.label_invalid_user_or_pass)) {
          newMessageError = Strings.label_wrong_user_or_pass;
        } else {
          newMessageError =
              newMessageError.replaceFirst(Strings.label_unexpected_error, '');
          isIdentifiedError = false;
        }
        debugPrint('error: $newMessageError');
        debugPrint('isIdentifiedError: $isIdentifiedError');
        emit(state.copyWith(
          status:
              isIdentifiedError ? RequestStatus.empty : RequestStatus.failure,
          usernameErrorMessage: '',
          passwordErrorMessage: newMessageError, // Show error mostly on password
        ));
      },
      (loginData) {
        emit(state.copyWith(
          message: 'Success',
          status: RequestStatus.success,
        ));
      },
    );
  }
}
