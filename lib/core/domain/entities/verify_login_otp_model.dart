import 'package:equatable/equatable.dart';

class VerifyLoginOtpModel extends Equatable {
  final String? jwtToken;
  final int? attemptLeft;

  const VerifyLoginOtpModel({
    this.jwtToken,
    this.attemptLeft,
  });

  @override
  List<Object?> get props => [jwtToken, attemptLeft];
}

