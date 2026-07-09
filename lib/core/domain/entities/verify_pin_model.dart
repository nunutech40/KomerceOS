import 'package:equatable/equatable.dart';

class VerifyPinModel extends Equatable {
  bool isValid;

  VerifyPinModel({
    required this.isValid,
  });

  @override
  List<Object?> get props => [
        isValid,
      ];
}

class DataOtpModel extends Equatable {
  String expiredAt;

  DataOtpModel({
    required this.expiredAt,
  });

  @override
  List<Object?> get props => [expiredAt];
}
