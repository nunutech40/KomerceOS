import 'package:dartz/dartz.dart';
import 'package:komtim_partner/core/domain/repositories/pin_repository.dart';

import '../../../common/failure.dart';

class UpdatePinSecuredUseCase {
  final PinRepository _repository;

  const UpdatePinSecuredUseCase(this._repository);

  /// Update PIN via internal auth API.
  /// [token] berasal dari response request-otp.
  Future<Either<Failure, bool>> execute(String pin, String token) {
    return _repository.updatePinSecured(pin, token);
  }
}