import 'package:dartz/dartz.dart';
import 'package:komtim_partner/core/domain/repositories/kompoin_repository.dart';

import '../../../common/failure.dart';

class WithdrawKompoinUseCase {
  final KompoinRepository _repository;

  const WithdrawKompoinUseCase(this._repository);

  Future<Either<Failure, bool>> execute(int nominal, int bankAccountId) {
    return _repository.withdraw(nominal, bankAccountId);
  }
}
