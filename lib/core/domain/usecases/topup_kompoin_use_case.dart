import 'package:dartz/dartz.dart';
import 'package:komtim_partner/core/domain/entities/topup_kompoin_model.dart';
import 'package:komtim_partner/core/domain/repositories/kompoin_repository.dart';

import '../../../common/failure.dart';

class TopupKompoinUseCase {
  final KompoinRepository _repository;

  const TopupKompoinUseCase(this._repository);

  Future<Either<Failure, TopupKompoinModel>> execute(int nominal) {
    return _repository.topUp(nominal);
  }
}
