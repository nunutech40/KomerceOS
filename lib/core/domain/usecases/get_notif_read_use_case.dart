import 'package:dartz/dartz.dart';
import 'package:komtim_partner/core/domain/repositories/transaction_history_repository.dart';

import '../../../common/failure.dart';

class GetNotifReadUseCase {
  final TransactionHistoryRepository _repository;

  const GetNotifReadUseCase(this._repository);

  Future<Either<Failure, bool>> execute(int id) {
    return _repository.getNotificationsRead(id);
  }
}
