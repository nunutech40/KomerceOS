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

  factory CheckPinResponse.fromJson(Map<String, dynamic> json) {
    return CheckPinResponse(
      isExist: json['is_exist'],
    );
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
