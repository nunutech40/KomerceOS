import 'package:dartz/dartz.dart';
import 'package:komtim_partner/core/domain/entities/verify_pin_model.dart';
import 'package:komtim_partner/core/domain/repositories/pin_repository.dart';

import '../../../common/failure.dart';

class ForgetPinUseCase {
  final PinRepository _repository;

  const ForgetPinUseCase(this._repository);

  Future<Either<Failure, DataOtpModel>> execute() {
    return _repository.forgetPin();
    
      // final dummyData = DataOtpModel(expiredAt: '2023-10-12 10:00:00');
      // return Future.value(Right(dummyData));
  }
}
