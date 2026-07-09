import 'package:equatable/equatable.dart';
import 'package:komtim_partner/core/domain/entities/verify_pin_model.dart';

class VerifyPinResponse extends Equatable {
  final bool isValid;

  const VerifyPinResponse({
    required this.isValid,
  });

  Map<String, dynamic> toJson() => {
        "is_valid": isValid,
      };

  factory VerifyPinResponse.fromJson(Map<String, dynamic> json) {
    return VerifyPinResponse(
      isValid: json['is_valid'],
    );
  }

  VerifyPinModel toEntity() {
    return VerifyPinModel(
      isValid: isValid,
    );
  }

  @override
  List<Object?> get props => [
        isValid,
      ];
}
