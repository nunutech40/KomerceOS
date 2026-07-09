part of 'profile_bloc.dart';

@immutable
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfilePageDidload extends ProfileEvent {
  const ProfilePageDidload();
}

class SaveButtonPressedEvent extends ProfileEvent {
  const SaveButtonPressedEvent();
}
