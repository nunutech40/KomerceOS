import 'package:equatable/equatable.dart';
import 'package:komtim_partner/core/domain/entities/verify_pin_model.dart';

class ForgetPinResponse extends Equatable {
  final String expiredAt;
  final String? token;
  final String? nextRequestAt;

  const ForgetPinResponse({
    required this.expiredAt,
    this.token,
    this.nextRequestAt,
  });

  Map<String, dynamic> toJson() => {
        "expired_at": expiredAt,
        "token": token,
        "next_request_at": nextRequestAt,
      };

  factory ForgetPinResponse.fromJson(Map<String, dynamic> json) {
    return ForgetPinResponse(
      expiredAt: json['expired_at']?.toString() ?? '',
      token: json['token']?.toString(),
      nextRequestAt: json['next_request_at']?.toString(),
    );
  }

  DataOtpModel toEntity() {
    return DataOtpModel(
      expiredAt: expiredAt,
      token: token,
      nextRequestAt: nextRequestAt,
    );
  }

  @override
  List<Object?> get props => [expiredAt, token, nextRequestAt];
}
