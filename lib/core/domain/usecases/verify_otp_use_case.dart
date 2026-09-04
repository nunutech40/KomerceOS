import 'package:dartz/dartz.dart';
import 'package:komtim_partner/core/domain/entities/verify_pin_model.dart';
import 'package:komtim_partner/core/domain/repositories/pin_repository.dart';

import '../../../common/failure.dart';

class VerifyOtpUseCase {
  final PinRepository _repository;

  const VerifyOtpUseCase(this._repository);

  Future<Either<Failure, VerifyPinModel>> execute(String otp,
      {String? token}) {
    return _repository.verifyOtp(otp, token: token);
  }
}
