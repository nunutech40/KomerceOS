import 'package:dartz/dartz.dart';
import 'package:komtim_partner/core/domain/entities/feed_notif_count_model.dart';
import 'package:komtim_partner/core/domain/entities/notifications_model.dart';
import 'package:komtim_partner/core/domain/entities/transaction_history_model.dart';
import '../../../common/failure.dart';

abstract class TransactionHistoryRepository {
  Future<Either<Failure, List<TransactionHistoryDataModel>>>
      getDataTransactionHistory(String? type, int offset, int limit);
  Future<Either<Failure, List<TransactionHistoryDataModel>>>
      getDataTransactionNeedProcessHistory();
  Future<Either<Failure, List<NotificationsDataModel>>> getNotifications();
  Future<Either<Failure, ModelFeedNotifCount>> getFeedNotifCount();
  Future<Either<Failure, bool>> getNotificationsRead(int id);
}
