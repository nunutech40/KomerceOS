import '../../../common/exception.dart';
import '../../domain/entities/two_fa_failure.dart';

class PartnerLoginException extends ServerException {
  final PartnerLoginErrorType errorType;
  final int? loginAttempt;
  final int? lock;
  final String? lockSource;

  PartnerLoginException(
    super.message, {
    required this.errorType,
    this.loginAttempt,
    this.lock,
    this.lockSource,
  });

  PartnerLoginFailure toFailure() => PartnerLoginFailure(
        message,
        errorType: errorType,
        loginAttempt: loginAttempt,
        lock: lock,
        lockSource: lockSource,
      );
}

class VerifyOtpException extends ServerException {
  final VerifyOtpErrorType errorType;
  final int? attemptLeft;
  final int? lock;

  VerifyOtpException(
    super.message, {
    required this.errorType,
    this.attemptLeft,
    this.lock,
  });

  VerifyOtpFailure toFailure() => VerifyOtpFailure(
        message,
        errorType: errorType,
        attemptLeft: attemptLeft,
        lock: lock,
      );
}

PartnerLoginException? tryParsePartnerLoginException(
  int? statusCode,
  dynamic responseData,
) {
  if (responseData is! Map) return null;
  final body = Map<String, dynamic>.from(responseData);

  if (body['status'] == false &&
      body['error_code'] == 'ERR_ROLE_TEAM_INTERNAL_BLOCKED') {
    return null;
  }

  final rawMeta = body['meta'];
  final meta =
      rawMeta is Map ? Map<String, dynamic>.from(rawMeta) : null;
  if (meta?['code']?.toString() == 'ERR_ROLE_TEAM_INTERNAL_BLOCKED') {
    return null;
  }

  final rawData = body['data'];
  final data =
      rawData is Map ? Map<String, dynamic>.from(rawData) : null;

  final responseCode = _parseInt(meta?['code']) ?? statusCode ?? 0;
  final message = (meta?['message'] ?? body['message'] ?? '').toString().trim();
  final lowerMessage = message.toLowerCase();

  if (lowerMessage.contains('user is non partner') ||
      lowerMessage.contains('user is not partner') ||
      lowerMessage.contains('non partner') ||
      lowerMessage.contains('non-partner')) {
    return null;
  }

  final lock = _parseInt(data?['lock']) ?? 0;
  final lockSource = (data?['lock_source'] ?? '').toString().trim();
  final lowerLockSource = lockSource.toLowerCase();
  final loginAttempt = _parseInt(data?['login_attempt']);

  if ((statusCode == 500 || responseCode == 500) &&
      lowerMessage == 'user not found') {
    return PartnerLoginException(
      message.isEmpty ? 'user not found' : message,
      errorType: PartnerLoginErrorType.userNotFound,
    );
  }

  if ((statusCode == 400 || responseCode == 400 || lowerLockSource == 'otp') &&
      lock == 1 &&
      lowerLockSource == 'otp') {
    return PartnerLoginException(
      message.isEmpty ? 'Please wait 24 hours to login!' : message,
      errorType: PartnerLoginErrorType.otpLocked24Hours,
      lock: lock,
      lockSource: lockSource,
    );
  }

  if (lock == 1 ||
      lowerMessage.contains('please wait 24 hour') ||
      lowerMessage.contains('account locked') ||
      lowerMessage.contains('akun terkunci')) {
    return PartnerLoginException(
      message.isEmpty ? 'Please wait 24 hours to login!' : message,
      errorType: PartnerLoginErrorType.passwordLocked24Hours,
      loginAttempt: loginAttempt,
      lock: lock,
      lockSource: lockSource.isEmpty ? null : lockSource,
    );
  }

  if ((statusCode == 400 || responseCode == 400 || loginAttempt != null) &&
      (lowerMessage == 'incorrect password' ||
          lowerMessage == 'wrong password' ||
          loginAttempt != null)) {
    return PartnerLoginException(
      message.isEmpty ? 'Incorrect Password' : message,
      errorType: PartnerLoginErrorType.incorrectPassword,
      loginAttempt: loginAttempt,
      lock: lock,
      lockSource: lockSource.isEmpty ? null : lockSource,
    );
  }

  return null;
}

VerifyOtpException? tryParseVerifyOtpException(
  int? statusCode,
  dynamic responseData,
) {
  if (responseData is! Map) return null;
  final body = Map<String, dynamic>.from(responseData);
  final rawMeta = body['meta'];
  final meta =
      rawMeta is Map ? Map<String, dynamic>.from(rawMeta) : null;
  final rawData = body['data'];
  final data =
      rawData is Map ? Map<String, dynamic>.from(rawData) : null;

  final responseCode = _parseInt(meta?['code']) ?? statusCode ?? 0;
  final message = (meta?['message'] ?? body['message'] ?? '').toString().trim();
  final lowerMessage = message.toLowerCase();
  final lock = _parseInt(data?['lock']) ?? 0;
  final attemptLeft = _parseInt(data?['attempt_left']);

  if (statusCode == 422 || responseCode == 422) {
    if (lowerMessage.contains('expired token')) {
      return VerifyOtpException(
        message.isEmpty ? 'Expired token' : message,
        errorType: VerifyOtpErrorType.expiredToken,
        lock: lock,
      );
    }

    if (lowerMessage == 'otp not valid' && lock == 1) {
      return VerifyOtpException(
        message.isEmpty ? 'OTP not valid' : message,
        errorType: VerifyOtpErrorType.otpInvalidLocked,
        attemptLeft: attemptLeft ?? 0,
        lock: 1,
      );
    }

    if (lowerMessage == 'otp not valid') {
      return VerifyOtpException(
        message.isEmpty ? 'OTP not valid' : message,
        errorType: VerifyOtpErrorType.otpInvalid,
        attemptLeft: attemptLeft ?? 0,
        lock: lock,
      );
    }
  }

  return null;
}

int? _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim());
  return null;
}

