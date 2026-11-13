import 'package:equatable/equatable.dart';

class PartnerLoginModel extends Equatable {
  final String? token;
  final String? email;
  final String? phone;
  final PendingOtpModel? pendingOtp;
  final bool otpLimitExceeded;

  const PartnerLoginModel({
    this.token,
    this.email,
    this.phone,
    this.pendingOtp,
    this.otpLimitExceeded = false,
  });

  @override
  List<Object?> get props => [
        token,
        email,
        phone,
        pendingOtp,
        otpLimitExceeded,
      ];
}

class PendingOtpModel extends Equatable {
  final String? token;
  final String? expiredAt;
  final int? expiresIn;
  final String? typeToken;

  const PendingOtpModel({
    this.token,
    this.expiredAt,
    this.expiresIn,
    this.typeToken,
  });

  @override
  List<Object?> get props => [
        token,
        expiredAt,
        expiresIn,
        typeToken,
      ];
}

