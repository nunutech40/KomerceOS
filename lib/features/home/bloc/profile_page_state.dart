part of 'profile_page_bloc.dart';

class ProfilePageState extends Equatable {
  const ProfilePageState({
    this.message = '',
    this.status = RequestStatus.empty,
    this.profileData,
    this.operation = '',
    this.pinData,
  });

  final String message;
  final RequestStatus status;
  final ProfileModel? profileData;
  final String operation;
  final ChekPinModel? pinData;

  ProfilePageState copyWith({
    RequestStatus? status,
    String? message,
    ProfileModel? profileData,
    String? operation,
    ChekPinModel? pinData,
  }) {
    return ProfilePageState(
      status: status ?? this.status,
      message: message ?? this.message,
      profileData: profileData ?? this.profileData,
      operation: operation ?? this.operation,
      pinData: pinData ?? this.pinData,
    );
  }

  @override
  List<Object?> get props => [
        message,
        status,
        profileData,
        operation,
        pinData,
      ];
}
