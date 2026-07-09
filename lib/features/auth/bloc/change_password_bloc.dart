import 'package:equatable/equatable.dart';
import 'package:komtim_partner/common/string.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';

import '../../../common/enum_status.dart';
import '../../../core/domain/usecases/change_password_use_case.dart';

part 'change_password_event.dart';
part 'change_password_state.dart';

class ChangePasswordBloc
    extends Bloc<ChangePasswordEvent, ChangePasswordState> {
  final ChangePasswordUseCase changePasswordUseCase;

  ChangePasswordBloc({required this.changePasswordUseCase})
      : super(const ChangePasswordState()) {
    on<ChangePassButtonPressedEvent>(_handleChangePasswordSubmit);
    on<StatusResetEvent>(_handleStatusResetEvent);
    on<ChangeNewPasswordChangedEvent>(_handleNewPassChangeEvent);
    on<ChangeOldPasswordChangedEvent>(_handleOldPassChangeEvent);
    on<ChangeConfirmPasswordChangedEvent>(_handleConfirmPassChangeEvent);
  }

  Future<void> _handleOldPassChangeEvent(
    ChangeOldPasswordChangedEvent event,
    Emitter<ChangePasswordState> emit,
  ) async {
    var newState = state.copyWith(oldPassword: event.oldPass);

    if (event.oldPass.length < 8) {
      newState = newState.copyWith(
        oldPassErrorMessage: Strings.label_pass_min_8,
      );
    } else if (event.oldPass.contains(' ')) {
      newState = newState.copyWith(
        oldPassErrorMessage: Strings.label_pass_cant_use_space,
      );
    } else {
      newState = newState.copyWith(
        oldPassErrorMessage: '',
      );
    }

    emit(newState);
  }

  Future<void> _handleNewPassChangeEvent(
    ChangeNewPasswordChangedEvent event,
    Emitter<ChangePasswordState> emit,
  ) async {
    var newState = state.copyWith(newPassword: event.newPass);

    if (event.newPass.length < 8) {
      newState = newState.copyWith(
        newPassErrorMessage: Strings.label_pass_min_8,
      );
    } else if (event.newPass.contains(' ')) {
      newState = newState.copyWith(
        newPassErrorMessage: Strings.label_pass_cant_use_space,
      );
    } else {
      newState = newState.copyWith(
        newPassErrorMessage: '',
      );
    }

    emit(newState);
  }

  Future<void> _handleConfirmPassChangeEvent(
    ChangeConfirmPasswordChangedEvent event,
    Emitter<ChangePasswordState> emit,
  ) async {
    var newState = state.copyWith(confirmPassword: event.confirmPass);

    if (event.confirmPass.length < 8) {
      newState = newState.copyWith(
        confirmPassErrorMessage: Strings.label_pass_min_8,
      );
    } else if (event.confirmPass.contains(' ')) {
      newState = newState.copyWith(
        confirmPassErrorMessage: Strings.label_pass_cant_use_space,
      );
    } else {
      newState = newState.copyWith(
        confirmPassErrorMessage: '',
      );
    }

    emit(newState);
  }

  Future<void> _handleStatusResetEvent(
    StatusResetEvent event,
    Emitter<ChangePasswordState> emit,
  ) async {
    emit(state.copyWith(
      status: RequestStatus.empty,
      newPassErrorMessage: '',
      oldPassErrorMessage: '',
      confirmPassErrorMessage: '',
    ));
  }

  Future<void> _handleChangePasswordSubmit(
    ChangePassButtonPressedEvent event,
    Emitter<ChangePasswordState> emit,
  ) async {
    final newPass = state.newPassword;
    final oldPass = state.oldPassword;
    final confirmPass = state.confirmPassword;

    if (newPass.isEmpty || oldPass.isEmpty || confirmPass.isEmpty) {
      emit(state.copyWith(
        status: RequestStatus.empty,
        newPassErrorMessage:
            newPass.isEmpty ? Strings.label_new_pass_cant_empty : '',
        oldPassErrorMessage:
            oldPass.isEmpty ? Strings.label_old_pass_cant_empty : '',
        confirmPassErrorMessage:
            confirmPass.isEmpty ? Strings.label_confirm_pass_cant_empty : '',
      ));
      return;
    }

    emit(state.copyWith(status: RequestStatus.loading));
    final result =
        await changePasswordUseCase.execute(oldPass, newPass, confirmPass);

    result.fold(
      (failure) {
        String newMessageError = failure.message;

        if (newMessageError.contains(Strings.label_invalid_old_pass)) {
          newMessageError = Strings.label_wrong_input_old_pass;
          emit(state.copyWith(
            status: RequestStatus.empty,
            oldPassErrorMessage: newMessageError,
          ));
        } else if (newMessageError
            .contains(Strings.label_confirm_pass_not_match)) {
          newMessageError = Strings.label_wrong_input_confirm_pass;
          emit(state.copyWith(
            status: RequestStatus.empty,
            confirmPassErrorMessage: newMessageError,
          ));
        } else {
          newMessageError =
              newMessageError.replaceFirst(Strings.label_unexpected_error, '');
          emit(state.copyWith(
            status: RequestStatus.empty,
            newPassErrorMessage: newMessageError,
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
