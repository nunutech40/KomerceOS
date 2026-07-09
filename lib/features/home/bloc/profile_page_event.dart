part of 'profile_page_bloc.dart';

@immutable
abstract class ProfilePageEvent extends Equatable {
  const ProfilePageEvent();

  @override
  List<Object?> get props => [];
}

class ProfilePageDidload extends ProfilePageEvent {
  const ProfilePageDidload();
}

class LogoutButtonPressedEvent extends ProfilePageEvent {
  const LogoutButtonPressedEvent();
}

class NextPressedButtonEvent extends ProfilePageEvent {
  const NextPressedButtonEvent();
}
