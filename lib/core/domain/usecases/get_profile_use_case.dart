import 'package:dartz/dartz.dart';

import '../../../common/failure.dart';
import '../entities/profile_model.dart';
import '../repositories/profile_repository.dart';

class GetProfileUseCase {
  final ProfileRepository _repository;

  const GetProfileUseCase(this._repository);

  Future<Either<Failure, ProfileModel>> execute() {
    return _repository.getProfile();
  }
}
