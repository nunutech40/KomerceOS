import 'package:equatable/equatable.dart';

import '../../domain/entities/request_login_otp_model.dart';

class RequestLoginOtpResponse extends Equatable {
  final String? token;
  final String? expiredAt;
  final int? expiresIn;
  final String? email;
  final String? phone;
  final bool otpLimitExceeded;

  const RequestLoginOtpResponse({
    this.token,
    this.expiredAt,
    this.expiresIn,
    this.email,
    this.phone,
    this.otpLimitExceeded = false,
  });

  factory RequestLoginOtpResponse.fromJson(dynamic jsonData) {
    final Map<String, dynamic> json = jsonData is Map
        ? Map<String, dynamic>.from(jsonData)
        : <String, dynamic>{};

    return RequestLoginOtpResponse(
      token: _parseNullableString(json['token']),
      expiredAt: _parseNullableString(json['expired_at']),
      expiresIn: _parseInt(json['expires_in']),
      email: _parseNullableString(json['email']),
      phone: _parseNullableString(json['phone']),
      otpLimitExceeded: _parseBool(json['otp_limit_exceeded']),
    );
  }

  Map<String, dynamic> toJson() => {
        'token': token,
        'expired_at': expiredAt,
        'expires_in': expiresIn,
        'email': email,
        'phone': phone,
        'otp_limit_exceeded': otpLimitExceeded,
      };

  RequestLoginOtpModel toEntity() {
    return RequestLoginOtpModel(
      token: token,
      expiredAt: expiredAt,
      expiresIn: expiresIn,
      email: email,
      phone: phone,
      otpLimitExceeded: otpLimitExceeded,
    );
  }

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

String? _parseNullableString(dynamic value) {
  if (value == null) return null;
  return value.toString();
}

int? _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim());
  return null;
}

bool _parseBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value == 1;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    return normalized == 'true' || normalized == '1';
  }
  return false;
}

