import 'package:dartz/dartz.dart';
import 'package:komtim_partner/common/failure.dart';
import 'package:komtim_partner/core/domain/repositories/pin_repository.dart';

class DeleteTimeUseCase {
  final PinRepository _repository;

  const DeleteTimeUseCase(this._repository);

  Future<Either<Failure, bool>> execute() {
    return _repository.deleteTime();
  }
}