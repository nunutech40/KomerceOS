import 'package:dartz/dartz.dart';
import 'package:komtim_partner/core/domain/entities/verify_pin_model.dart';
import 'package:komtim_partner/core/domain/repositories/pin_repository.dart';

import '../../../common/failure.dart';

class VerifyPinUseCase {
  final PinRepository _repository;

  const VerifyPinUseCase(this._repository);

  Future<Either<Failure, VerifyPinModel>> execute(String pin) {
    return _repository.verifyPin(pin);
  }
}
