part of 'pin_bloc.dart';

class PinState extends Equatable {
  const PinState(
      {this.message = '',
      this.status = RequestStatus.empty,
      this.operation = '',
      this.isSetPin = false,
      this.pinData,
      this.expiredAt,
      this.profileData,
      this.otpToken,
      this.attemptLeft = 0,
      this.nextRequestAt,});

  final String message;
  final RequestStatus status;
  final String operation;
  final VerifyPinModel? pinData;
  final bool isSetPin;
  final DataOtpModel? expiredAt;
  final ProfileModel? profileData;

  /// Token dari request-otp (flow lupa PIN) — dipakai untuk
  /// update-pin via endpoint secured.
  final String? otpToken;

  /// Sisa percobaan salah OTP/PIN dari API.
  final int attemptLeft;

  /// `next_request_at` dari API — cooldown kirim ulang OTP.
  final String? nextRequestAt;

  PinState copyWith(
      {RequestStatus? status,
      String? message,
      String? operation,
      bool isSetPin = false,
      VerifyPinModel? pinData,
      DataOtpModel? expiredAt,
      ProfileModel? profileData,
      String? otpToken,
      int? attemptLeft,
      String? nextRequestAt,}) {
    return PinState(
        status: status ?? this.status,
        message: message ?? this.message,
        operation: operation ?? this.operation,
        isSetPin: isSetPin,
        pinData: pinData ?? this.pinData,
        expiredAt: expiredAt,
        profileData: profileData ?? this.profileData,
        otpToken: otpToken ?? this.otpToken,
        attemptLeft: attemptLeft ?? this.attemptLeft,
        nextRequestAt: nextRequestAt ?? this.nextRequestAt,);
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
        otpToken,
        attemptLeft,
        nextRequestAt,
      ];
}
