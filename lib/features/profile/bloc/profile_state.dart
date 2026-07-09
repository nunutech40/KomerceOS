part of 'profile_bloc.dart';

class ProfileState extends Equatable {
  const ProfileState({
    this.message = '',
    this.status = RequestStatus.empty,
    this.profileData,
  });

  final String message;
  final RequestStatus status;
  final ProfileModel? profileData;

  ProfileState copyWith({
    RequestStatus? status,
    String? message,
    ProfileModel? profileData,
  }) {
    return ProfileState(
      status: status ?? this.status,
      message: message ?? this.message,
      profileData: profileData ?? this.profileData,
    );
  }

  @override
  List<Object?> get props => [
        message,
        status,
        profileData,
      ];
}
