import 'package:dartz/dartz.dart';
import 'package:komtim_partner/core/domain/repositories/pin_repository.dart';

import '../../../common/failure.dart';
import '../entities/check_pin_model.dart';

class CheckPinUseCase {
  final PinRepository _repository;

  const CheckPinUseCase(this._repository);

  Future<Either<Failure, ChekPinModel>> execute() {
    return _repository.checkPin();
  }
}
