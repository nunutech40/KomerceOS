import 'package:dartz/dartz.dart';
import 'package:komtim_partner/core/domain/entities/verify_pin_model.dart';
import 'package:komtim_partner/core/domain/repositories/pin_repository.dart';

import '../../../common/failure.dart';

class ForgetPinUseCase {
  final PinRepository _repository;

  const ForgetPinUseCase(this._repository);

  Future<Either<Failure, DataOtpModel>> execute({String? purpose}) {
    return _repository.forgetPin(purpose: purpose);
  }
}
