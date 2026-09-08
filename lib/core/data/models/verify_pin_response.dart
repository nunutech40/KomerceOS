import 'package:equatable/equatable.dart';
import 'package:komtim_partner/core/domain/entities/verify_pin_model.dart';

class VerifyPinResponse extends Equatable {
  final bool isValid;
  final String? usableToken;
  final int attemptLeft;

  const VerifyPinResponse({
    required this.isValid,
    this.usableToken,
    this.attemptLeft = 0,
  });

  Map<String, dynamic> toJson() => {
        "is_valid": isValid,
        "usable_token": usableToken,
        "attempt_left": attemptLeft,
      };

  factory VerifyPinResponse.fromJson(Map<String, dynamic> json) {
    return VerifyPinResponse(
      isValid: json['is_valid'] ?? false,
      usableToken: json['usable_token']?.toString(),
      attemptLeft: json['attempt_left'] is int
          ? json['attempt_left'] as int
          : int.tryParse('${json['attempt_left'] ?? ''}') ?? 0,
    );
  }

  /// Response verify OTP (flow lupa PIN) hanya mengirim `attempt_left`:
  /// `{"data": {"attempt_left": 3}}`. Parser sudah memastikan
  /// `meta.status == success` sebelum sampai ke sini, jadi OTP dianggap
  /// valid kecuali API mengirim `is_valid: false` secara eksplisit.
  factory VerifyPinResponse.fromOtpJson(dynamic json) {
    final map = json is Map<String, dynamic> ? json : const <String, dynamic>{};
    return VerifyPinResponse(
      isValid: map['is_valid'] is bool ? map['is_valid'] as bool : true,
      usableToken: map['usable_token']?.toString(),
      attemptLeft: map['attempt_left'] is int
          ? map['attempt_left'] as int
          : int.tryParse('${map['attempt_left'] ?? ''}') ?? 0,
    );
  }

  VerifyPinModel toEntity() {
    return VerifyPinModel(
      isValid: isValid,
      usableToken: usableToken,
      attemptLeft: attemptLeft,
    );
  }

  @override
  List<Object?> get props => [isValid, usableToken, attemptLeft];
}
