part of 'change_password_bloc.dart';

class ChangePasswordState extends Equatable {
  const ChangePasswordState(
      {this.message = '',
      this.status = RequestStatus.empty,
      this.newPassword = '',
      this.oldPassword = '',
      this.confirmPassword = '',
      this.newPassErrorMessage = '',
      this.oldPassErrorMessage = '',
      this.confirmPassErrorMessage = ''});

  final String message;
  final RequestStatus status;
  final String oldPassword;
  final String newPassword;
  final String confirmPassword;
  final String newPassErrorMessage;
  final String oldPassErrorMessage;
  final String confirmPassErrorMessage;
  bool get isSubmitButtonActive =>
      newPassword.isNotEmpty &&
      oldPassword.isNotEmpty &&
      confirmPassword.isNotEmpty;

  ChangePasswordState copyWith({
    RequestStatus? status,
    String? message,
    String? newPassword,
    String? oldPassword,
    String? confirmPassword,
    String? newPassErrorMessage,
    String? oldPassErrorMessage,
    String? confirmPassErrorMessage,
  }) {
    return ChangePasswordState(
      status: status ?? this.status,
      message: message ?? this.message,
      newPassword: newPassword ?? this.newPassword,
      oldPassword: oldPassword ?? this.oldPassword,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      newPassErrorMessage: newPassErrorMessage ?? this.newPassErrorMessage,
      oldPassErrorMessage: oldPassErrorMessage ?? this.oldPassErrorMessage,
      confirmPassErrorMessage:
          confirmPassErrorMessage ?? this.confirmPassErrorMessage,
    );
  }

  @override
  List<Object?> get props => [
        message,
        status,
        newPassword,
        oldPassword,
        confirmPassword,
        newPassErrorMessage,
        oldPassErrorMessage,
        confirmPassErrorMessage,
      ];
}
