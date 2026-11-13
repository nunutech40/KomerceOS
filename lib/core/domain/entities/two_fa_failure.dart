import '../../../common/failure.dart';

class _AbsentValue {
  const _AbsentValue();
}

const _absent = _AbsentValue();

enum PartnerLoginErrorType {
  userNotFound,
  otpLocked24Hours,
  passwordLocked24Hours,
  incorrectPassword,
  generic,
}

class PartnerLoginFailure extends ServerFailure {
  final PartnerLoginErrorType errorType;
  final int? loginAttempt;
  final int? lock;
  final String? lockSource;

  const PartnerLoginFailure(
    super.message, {
    required this.errorType,
    this.loginAttempt,
    this.lock,
    this.lockSource,
  });

  @override
  List<Object> get props => [
        message,
        errorType,
        loginAttempt ?? _absent,
        lock ?? _absent,
        lockSource ?? _absent,
      ];
}

enum VerifyOtpErrorType {
  expiredToken,
  otpInvalidLocked,
  otpInvalid,
  generic,
}

class VerifyOtpFailure extends ServerFailure {
  final VerifyOtpErrorType errorType;
  final int? attemptLeft;
  final int? lock;

  const VerifyOtpFailure(
    super.message, {
    required this.errorType,
    this.attemptLeft,
    this.lock,
  });

  @override
  List<Object> get props => [
        message,
        errorType,
        attemptLeft ?? _absent,
        lock ?? _absent,
      ];
}

