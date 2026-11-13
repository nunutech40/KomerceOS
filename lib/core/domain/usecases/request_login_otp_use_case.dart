import 'package:dartz/dartz.dart';

import '../../../common/failure.dart';
import '../entities/request_login_otp_model.dart';
import '../repositories/auth_repository.dart';

class RequestLoginOtpUseCase {
  final AuthRepository repository;

  RequestLoginOtpUseCase(this.repository);

  Future<Either<Failure, RequestLoginOtpModel>> call(
    String loginToken,
    String method, {
    String? recaptchaToken,
  }) {
    return repository.requestLoginOtp(
      loginToken,
      method,
      recaptchaToken: recaptchaToken,
    );
  }
}

