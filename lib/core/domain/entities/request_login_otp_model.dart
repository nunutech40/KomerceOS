import 'package:equatable/equatable.dart';

class RequestLoginOtpModel extends Equatable {
  final String? token;
  final String? expiredAt;
  final int? expiresIn;
  final String? email;
  final String? phone;
  final bool otpLimitExceeded;

  const RequestLoginOtpModel({
    this.token,
    this.expiredAt,
    this.expiresIn,
    this.email,
    this.phone,
    this.otpLimitExceeded = false,
  });

  @override
  List<Object?> get props => [
        token,
        expiredAt,
        expiresIn,
        email,
        phone,
        otpLimitExceeded,
      ];
}

