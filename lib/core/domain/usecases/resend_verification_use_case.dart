import 'package:dartz/dartz.dart';

import '../../../common/failure.dart';
import '../repositories/auth_repository.dart';

class ResendVerificationUseCase {
  final AuthRepository repository;

  ResendVerificationUseCase(this.repository);

  Future<Either<Failure, bool>> execute(String email, String productName) {
    return repository.resendVerification(email, productName);
  }
}
