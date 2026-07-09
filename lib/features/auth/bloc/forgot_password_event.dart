part of 'forgot_password_bloc.dart';

@immutable
abstract class ForgotPasswordEvent extends Equatable {
  const ForgotPasswordEvent();
  @override
  List<Object?> get props => [];
}

class SendButtonPressedEvent extends ForgotPasswordEvent {
  const SendButtonPressedEvent();
}

class SendStatusResetEvent extends ForgotPasswordEvent {}

class ForgotEmailChangedEvent extends ForgotPasswordEvent {
  const ForgotEmailChangedEvent({required this.email});

  final String email;

  @override
  List<Object> get props => [email];
}
