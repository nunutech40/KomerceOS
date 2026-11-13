import 'package:dartz/dartz.dart';

import '../../../common/failure.dart';
import '../entities/partner_login_model.dart';
import '../repositories/auth_repository.dart';

class PartnerLoginUseCase {
  final AuthRepository repository;

  PartnerLoginUseCase(this.repository);

  Future<Either<Failure, PartnerLoginModel>> call(
    String username,
    String password, {
    String? recaptchaToken,
  }) {
    return repository.partnerLogin(
      username,
      password,
      recaptchaToken: recaptchaToken,
    );
  }
}

