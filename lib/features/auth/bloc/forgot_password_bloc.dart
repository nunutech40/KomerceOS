import 'package:equatable/equatable.dart';
import 'package:komtim_partner/common/string.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';

import '../../../common/enum_status.dart';
import '../../../common/failure.dart';
import '../../../core/domain/usecases/send_forgot_password_use_case.dart';

part 'forgot_password_event.dart';
part 'forgot_password_state.dart';

class ForgotPasswordBloc
    extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  final SendForgotPasswordUseCase sendForgotPasswordUseCase;

  ForgotPasswordBloc({required this.sendForgotPasswordUseCase})
      : super(const ForgotPasswordState()) {
    on<SendButtonPressedEvent>(_handleSendForgotPassword);
    on<SendStatusResetEvent>(_handleStatusResetEvent);
    on<ForgotEmailChangedEvent>(_handleEmailNameChangeEvent);
  }

  Future<void> _handleEmailNameChangeEvent(
    ForgotEmailChangedEvent event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    final email = event.email;

    if (email.isEmpty) {
      emit(state.copyWith(
        email: email,
        emailErrorMessage: Strings.label_email_cant_empty,
      ));
      return;
    }

    final emailRegex =
        RegExp(r'^[\w-]+(\.[\w-]+)*@[a-z0-9-]+(\.[a-z0-9-]+)*(\.[a-z]{2,})$');
    if (!emailRegex.hasMatch(email)) {
      emit(state.copyWith(
        email: email,
        emailErrorMessage: Strings.label_email_format_not_valid,
      ));
      return;
    }

    emit(state.copyWith(email: email, emailErrorMessage: ''));
  }

  Future<void> _handleStatusResetEvent(
    SendStatusResetEvent event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(state.copyWith(
      status: RequestStatus.empty,
      emailErrorMessage: '',
    ));
  }

  Future<void> _handleSendForgotPassword(
    SendButtonPressedEvent event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    final email = state.email;

    if (email.isEmpty) {
      emit(state.copyWith(
        emailErrorMessage: Strings.label_email_cant_empty,
      ));
      return;
    }

    emit(state.copyWith(status: RequestStatus.loading));

    // --- DUMMY SCENARIO ---
    if (email == 'unverified@gmail.com') {
      await Future.delayed(const Duration(seconds: 1));
      emit(state.copyWith(
        status: RequestStatus.failure,
        emailErrorMessage: 'unverified',
      ));
      return;
    }

    final result = await sendForgotPasswordUseCase.execute(state.email);

    result.fold(
      (failure) {
        bool isIdentifiedError = true;
        String newMessageError = failure.message;

        if (failure is ConnectionFailure || failure is ServerFailure) {
          emit(state.copyWith(
              message: failure.message, status: RequestStatus.failure));
        } else {
          if (newMessageError.contains(Strings.label_email_not_found)) {
            newMessageError = Strings.label_email_not_registered;
          } else {
            newMessageError =
                newMessageError.replaceFirst(Strings.label_unexpected_error, '');
          }
          emit(state.copyWith(
            status:
                isIdentifiedError ? RequestStatus.empty : RequestStatus.failure,
            emailErrorMessage: newMessageError,
          ));
        }
      },
      (forgotPassword) {
        emit(state.copyWith(
          message: 'Success',
          status: RequestStatus.success,
        ));
      },
    );
  }
}
