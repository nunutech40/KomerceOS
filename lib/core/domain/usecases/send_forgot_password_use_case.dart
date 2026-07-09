
import 'package:dartz/dartz.dart';

import '../../../common/failure.dart';
import '../repositories/auth_repository.dart';

class SendForgotPasswordUseCase {
  final AuthRepository repository;

  SendForgotPasswordUseCase(this.repository);

  Future<Either<Failure, bool>> execute(String email,
      {String? recaptchaToken}) {
    return repository.sendForgotPass(email, recaptchaToken: recaptchaToken);
  }
}
