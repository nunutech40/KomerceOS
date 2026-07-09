import 'package:dartz/dartz.dart';

import '../../../common/failure.dart';
import '../repositories/auth_repository.dart';

class ResetPasswordUseCase {
  final AuthRepository repository;

  ResetPasswordUseCase(this.repository);

  Future<Either<Failure, bool>> execute(String code, String password) {
    return repository.resetPassword(code, password);
  }
}
