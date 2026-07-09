part of 'pin_bloc.dart';

class PinState extends Equatable {
  const PinState(
      {this.message = '',
      this.status = RequestStatus.empty,
      this.operation = '',
      this.isSetPin = false,
      this.pinData,
      this.expiredAt,
    this.profileData,});

  final String message;
  final RequestStatus status;
  final String operation;
  final VerifyPinModel? pinData;
  final bool isSetPin;
  final DataOtpModel? expiredAt;
  final ProfileModel? profileData;

  PinState copyWith(
      {RequestStatus? status,
      String? message,
      String? operation,
      bool isSetPin = false,
      VerifyPinModel? pinData,
      DataOtpModel? expiredAt,
    ProfileModel? profileData,}) {
    return PinState(
        status: status ?? this.status,
        message: message ?? this.message,
        operation: operation ?? this.operation,
        isSetPin: isSetPin,
        pinData: pinData ?? this.pinData,
        expiredAt: expiredAt,
      profileData: profileData ?? this.profileData,);
  }

  @override
  List<Object?> get props => [
        message,
        status,
        operation,
        isSetPin,
        pinData,
        expiredAt,
        profileData,
      ];
}
