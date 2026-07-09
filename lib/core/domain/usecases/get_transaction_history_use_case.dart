import 'package:dartz/dartz.dart';
import 'package:komtim_partner/core/domain/entities/transaction_history_model.dart';
import 'package:komtim_partner/core/domain/repositories/transaction_history_repository.dart';

import '../../../common/failure.dart';

class GetTransactionHistoryUseCase {
  final TransactionHistoryRepository _repository;

  const GetTransactionHistoryUseCase(this._repository);

  Future<Either<Failure, List<TransactionHistoryDataModel>>> execute(
      String? type, int offset, int limit) {
    return _repository.getDataTransactionHistory(type, offset, limit);
  }
}
