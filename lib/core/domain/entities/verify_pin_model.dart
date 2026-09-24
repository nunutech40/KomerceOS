import 'package:equatable/equatable.dart';

class VerifyPinModel extends Equatable {
  final bool isValid;
  final String? usableToken;
  final int attemptLeft;

  const VerifyPinModel({
    required this.isValid,
    this.usableToken,
    this.attemptLeft = 0,
  });

  @override
  List<Object?> get props => [isValid, usableToken, attemptLeft];
}

class DataOtpModel extends Equatable {
  final String expiredAt;
  final String? token;
  final String? nextRequestAt;

  const DataOtpModel({
    required this.expiredAt,
    this.token,
    this.nextRequestAt,
  });

  @override
  List<Object?> get props => [expiredAt, token, nextRequestAt];
}
