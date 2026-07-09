import 'package:dartz/dartz.dart';
import 'package:komtim_partner/core/domain/repositories/pin_repository.dart';

import '../../../common/failure.dart';

class SaveTimeUseCase {
  final PinRepository _repository;

  const SaveTimeUseCase(this._repository);

  Future<Either<Failure, bool>> execute(String time) {
    return _repository.saveTime(time);
  }
}