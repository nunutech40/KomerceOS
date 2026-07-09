import 'package:dartz/dartz.dart';
import 'package:komtim_partner/core/data/models/topup_qris_response.dart';
import 'package:komtim_partner/core/domain/repositories/top_up_repository.dart';

import '../../../common/failure.dart';

class TopUpDetailuseCase {
  final TopUpRepository _repository;

  const TopUpDetailuseCase(this._repository);

  Future<Either<Failure, TopupDetailResponse>> execute(int transactionId) {
    return _repository.topUpdetail(transactionId);
  }
}
