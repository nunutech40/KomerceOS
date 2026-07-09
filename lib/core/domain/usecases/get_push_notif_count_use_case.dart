import 'package:dartz/dartz.dart';
import 'package:komtim_partner/core/domain/entities/feed_notif_count_model.dart';
import 'package:komtim_partner/core/domain/repositories/transaction_history_repository.dart';

import '../../../common/failure.dart';

class GetNotifCountUseCase {
  final TransactionHistoryRepository _repository;

  const GetNotifCountUseCase(this._repository);

  Future<Either<Failure, ModelFeedNotifCount>> execute() {
    return _repository.getFeedNotifCount();
  }
}
