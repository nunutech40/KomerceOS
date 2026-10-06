import 'package:equatable/equatable.dart';

import '../../domain/entities/check_pin_model.dart';

class CheckPinResponse extends Equatable {
  final bool isExist;

  const CheckPinResponse({
    required this.isExist,
  });

  Map<String, dynamic> toJson() => {
        "is_exist": isExist,
      };

  factory CheckPinResponse.fromJson(dynamic json) {
    if (json is! Map) {
      throw const FormatException('Status PIN tidak valid');
    }
    final value = json['is_set'] ?? json['is_exist'];
    if (value is! bool) {
      throw const FormatException('Status PIN tidak valid');
    }
    return CheckPinResponse(isExist: value);
  }

  ChekPinModel toEntity() {
    return ChekPinModel(
      isExist: isExist,
    );
  }

  @override
  List<Object?> get props => [
        isExist,
      ];
}
