import 'package:dartz/dartz.dart';
import 'package:komtim_partner/core/data/models/topup_qris_response.dart';
import 'package:komtim_partner/core/domain/repositories/top_up_repository.dart';

import '../../../common/failure.dart';

class TopUpCeckUseCase {
  final TopUpRepository _repository;

  const TopUpCeckUseCase(this._repository);

  Future<Either<Failure, TopupDetailResponse>> execute(
      String typeCheckTrasaction) {
    return _repository.topUpCeckTransaction(typeCheckTrasaction);
  }
}
