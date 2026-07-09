import 'package:dartz/dartz.dart';
import 'package:komtim_partner/core/domain/repositories/top_up_repository.dart';

import '../../../common/failure.dart';

class TopUpCancelUseCase {
  final TopUpRepository _repository;

  const TopUpCancelUseCase(this._repository);

  Future<Either<Failure, bool>> execute(int id) {
    return _repository.topUpCancel(id);
  }
}
