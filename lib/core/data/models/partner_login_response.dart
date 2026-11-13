import 'package:equatable/equatable.dart';

import '../../domain/entities/partner_login_model.dart';

class PartnerLoginResponse extends Equatable {
  final String? token;
  final String? email;
  final String? phone;
  final PendingOtpResponse? pendingOtp;
  final bool otpLimitExceeded;

  const PartnerLoginResponse({
    this.token,
    this.email,
    this.phone,
    this.pendingOtp,
    this.otpLimitExceeded = false,
  });

  factory PartnerLoginResponse.fromJson(dynamic jsonData) {
    final Map<String, dynamic> json = jsonData is Map
        ? Map<String, dynamic>.from(jsonData)
        : <String, dynamic>{};

    return PartnerLoginResponse(
      token: _parseNullableString(json['token']),
      email: _parseNullableString(json['email']),
      phone: _parseNullableString(json['phone']),
      pendingOtp: json['pending_otp'] is Map
          ? PendingOtpResponse.fromJson(json['pending_otp'])
          : null,
      otpLimitExceeded: _parseBool(json['otp_limit_exceeded']),
    );
  }

  Map<String, dynamic> toJson() => {
        'token': token,
        'email': email,
        'phone': phone,
        'pending_otp': pendingOtp?.toJson(),
        'otp_limit_exceeded': otpLimitExceeded,
      };

  PartnerLoginModel toEntity() {
    return PartnerLoginModel(
      token: token,
      email: email,
      phone: phone,
      pendingOtp: pendingOtp?.toEntity(),
      otpLimitExceeded: otpLimitExceeded,
    );
  }

  @override
  List<Object?> get props => [
        token,
        email,
        phone,
        pendingOtp,
        otpLimitExceeded,
      ];
}

class PendingOtpResponse extends Equatable {
  final String? token;
  final String? expiredAt;
  final int? expiresIn;
  final String? typeToken;

  const PendingOtpResponse({
    this.token,
    this.expiredAt,
    this.expiresIn,
    this.typeToken,
  });

  factory PendingOtpResponse.fromJson(dynamic jsonData) {
    final Map<String, dynamic> json = jsonData is Map
        ? Map<String, dynamic>.from(jsonData)
        : <String, dynamic>{};

    return PendingOtpResponse(
      token: _parseNullableString(json['token']),
      expiredAt: _parseNullableString(json['expired_at']),
      expiresIn: _parseInt(json['expires_in']),
      typeToken: _parseNullableString(json['type_token']),
    );
  }

  Map<String, dynamic> toJson() => {
        'token': token,
        'expired_at': expiredAt,
        'expires_in': expiresIn,
        'type_token': typeToken,
      };

  PendingOtpModel toEntity() {
    return PendingOtpModel(
      token: token,
      expiredAt: expiredAt,
      expiresIn: expiresIn,
      typeToken: typeToken,
    );
  }

  @override
  List<Object?> get props => [
        token,
        expiredAt,
        expiresIn,
        typeToken,
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

