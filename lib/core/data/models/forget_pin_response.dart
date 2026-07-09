import 'package:equatable/equatable.dart';
import 'package:komtim_partner/core/domain/entities/verify_pin_model.dart';

class ForgetPinResponse extends Equatable {
  final String expiredAt;

  const ForgetPinResponse({
    required this.expiredAt,
  });

  Map<String, dynamic> toJson() => {
        "expired_at": expiredAt,
      };

  factory ForgetPinResponse.fromJson(Map<String, dynamic> json) {
    return ForgetPinResponse(
      expiredAt: json['expired_at'],
    );
  }

  DataOtpModel toEntity() {
    return DataOtpModel(
      expiredAt: expiredAt,
    );
  }

  @override
  List<Object?> get props => [
        expiredAt,
      ];
}
