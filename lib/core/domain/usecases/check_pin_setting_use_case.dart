import 'package:dartz/dartz.dart';
import 'package:komtim_partner/core/domain/repositories/pin_repository.dart';

import '../../../common/failure.dart';
import '../entities/check_pin_model.dart';

class CheckPinSettingUseCase {
  final PinRepository _repository;

  const CheckPinSettingUseCase(this._repository);

  Future<Either<Failure, ChekPinModel>> execute() {
    return _repository.checkPinSetting();
  }
}
