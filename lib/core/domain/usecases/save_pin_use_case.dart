import 'package:dartz/dartz.dart';
import 'package:komtim_partner/core/domain/repositories/pin_repository.dart';

import '../../../common/failure.dart';

class SavePinUseCase {
  final PinRepository _repository;

  const SavePinUseCase(this._repository);

  Future<Either<Failure, bool>> execute(String pin) {
    return _repository.savePin(pin);
  }
}
