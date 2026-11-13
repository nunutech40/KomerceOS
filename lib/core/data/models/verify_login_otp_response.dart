import 'package:equatable/equatable.dart';

import '../../domain/entities/verify_login_otp_model.dart';

class VerifyLoginOtpResponse extends Equatable {
  final String? jwtToken;
  final int? attemptLeft;

  const VerifyLoginOtpResponse({
    this.jwtToken,
    this.attemptLeft,
  });

  factory VerifyLoginOtpResponse.fromJson(dynamic jsonData) {
    final Map<String, dynamic> json = jsonData is Map
        ? Map<String, dynamic>.from(jsonData)
        : <String, dynamic>{};

    return VerifyLoginOtpResponse(
      jwtToken: _parseNullableString(json['jwt_token']),
      attemptLeft: _parseInt(json['attempt_left']),
    );
  }

  Map<String, dynamic> toJson() => {
        'jwt_token': jwtToken,
        'attempt_left': attemptLeft,
      };

  VerifyLoginOtpModel toEntity() {
    return VerifyLoginOtpModel(
      jwtToken: jwtToken,
      attemptLeft: attemptLeft,
    );
  }

  @override
  List<Object?> get props => [jwtToken, attemptLeft];
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

