part of 'change_password_bloc.dart';

@immutable
abstract class ChangePasswordEvent extends Equatable {
  const ChangePasswordEvent();
  @override
  List<Object?> get props => [];
}

class ChangePassButtonPressedEvent extends ChangePasswordEvent {
  const ChangePassButtonPressedEvent();
}

class StatusResetEvent extends ChangePasswordEvent {}

class ChangeNewPasswordChangedEvent extends ChangePasswordEvent {
  const ChangeNewPasswordChangedEvent({required this.newPass});

  final String newPass;

  @override
  List<Object> get props => [newPass];
}

class ChangeOldPasswordChangedEvent extends ChangePasswordEvent {
  const ChangeOldPasswordChangedEvent({required this.oldPass});

  final String oldPass;

  @override
  List<Object> get props => [oldPass];
}

class ChangeConfirmPasswordChangedEvent extends ChangePasswordEvent {
  const ChangeConfirmPasswordChangedEvent({required this.confirmPass});

  final String confirmPass;

  @override
  List<Object> get props => [confirmPass];
}
