
import 'package:dartz/dartz.dart';

import '../../../common/failure.dart';
import '../repositories/auth_repository.dart';

class GetAuthStateUseCase {
  final AuthRepository _repository;

  const GetAuthStateUseCase(this._repository);

  Future<Either<Failure, bool>> execute() {
    return _repository.getAuthState();
  }
}
