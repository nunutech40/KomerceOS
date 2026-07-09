
import 'package:dartz/dartz.dart';

import '../../../common/failure.dart';
import '../repositories/auth_repository.dart';

class ChangePasswordUseCase {
  final AuthRepository repository;

  ChangePasswordUseCase(this.repository);

  Future<Either<Failure, bool>> execute(
      String oldPass, String newPass, String confirmPass) {
    return repository.changePassword(oldPass, newPass, confirmPass);
  }
}
