import 'package:dartz/dartz.dart';
import 'package:komtim_partner/core/domain/repositories/pin_repository.dart';

import '../../../common/failure.dart';

class UpdatePinUseCase {
  final PinRepository _repository;

  const UpdatePinUseCase(this._repository);

  /// Update PIN via endpoint legacy (flow ubah PIN dengan PIN lama).
  Future<Either<Failure, bool>> execute(String pin) {
    return _repository.savePin(pin);
  }
}