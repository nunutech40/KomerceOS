import 'package:dartz/dartz.dart';
import 'package:komtim_partner/common/failure.dart';
import 'package:komtim_partner/core/domain/entities/transaction_history_model.dart';
import 'package:komtim_partner/core/domain/repositories/transaction_history_repository.dart';

class GetTransactionNeedProcessHistoryUseCase {
  final TransactionHistoryRepository _repository;

  const GetTransactionNeedProcessHistoryUseCase(this._repository);

  Future<Either<Failure, List<TransactionHistoryDataModel>>> execute() {
    return _repository.getDataTransactionNeedProcessHistory();
  }
}
