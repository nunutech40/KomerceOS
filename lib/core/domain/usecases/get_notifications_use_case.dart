import 'package:dartz/dartz.dart';
import 'package:komtim_partner/core/domain/entities/notifications_model.dart';
import 'package:komtim_partner/core/domain/repositories/transaction_history_repository.dart';

import '../../../common/failure.dart';

class GetNotificationsUseCase {
  final TransactionHistoryRepository _repository;

  const GetNotificationsUseCase(this._repository);

  Future<Either<Failure, List<NotificationsDataModel>>> execute() {
    return _repository.getNotifications();
  }
}
