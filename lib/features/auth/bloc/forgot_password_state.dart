part of 'forgot_password_bloc.dart';

class ForgotPasswordState extends Equatable {
  const ForgotPasswordState(
      {this.message = '',
      this.status = RequestStatus.empty,
      this.email = '',
      this.emailErrorMessage = ''});

  final String message;
  final RequestStatus status;
  final String email;
  final String emailErrorMessage;

  ForgotPasswordState copyWith({
    RequestStatus? status,
    String? message,
    String? email,
    String? emailErrorMessage,
  }) {
    return ForgotPasswordState(
      status: status ?? this.status,
      message: message ?? this.message,
      email: email ?? this.email,
      emailErrorMessage: emailErrorMessage ?? this.emailErrorMessage,
    );
  }

  @override
  List<Object?> get props => [message, status, email, emailErrorMessage];
}
