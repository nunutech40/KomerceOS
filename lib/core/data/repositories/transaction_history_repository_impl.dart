import 'package:komtim_partner/core/data/datasources/remote/transaction_history_remote_datasource.dart';
import 'package:komtim_partner/core/domain/entities/feed_notif_count_model.dart';
import 'package:komtim_partner/core/domain/entities/notifications_model.dart';
import 'package:komtim_partner/core/domain/entities/transaction_history_model.dart';
import 'package:komtim_partner/core/domain/repositories/transaction_history_repository.dart';

import '../../../common/failure.dart';
import 'base_repository.dart';

import 'package:dartz/dartz.dart';

class TransactionHistoryRepositoryImpl extends BaseRepository
    implements TransactionHistoryRepository {
  final TransactionHistoryRemoteDataSource remoteDataSource;
  final TransactionHistoryRemoteDataSource remoteDataSourceNeedProcess;

  TransactionHistoryRepositoryImpl(
      {required this.remoteDataSource,
      required this.remoteDataSourceNeedProcess});

  @override
  Future<Either<Failure, List<TransactionHistoryDataModel>>>
      getDataTransactionHistory(String? type, int offset, int limit) async {
    return executeEither(() async {
      final result =
          await remoteDataSource.getDataTransactionHistory(type, offset, limit);
      final invoiceData = result.map((item) => item.toEntity()).toList();

      return invoiceData;
    });
  }

  @override
  Future<Either<Failure, List<NotificationsDataModel>>>
      getNotifications() async {
    return executeEither(() async {
      final result = await remoteDataSource.getDataNotifications();
      final notificationsData = result.map((item) => item.toEntity()).toList();

      return notificationsData;
    });
  }

  @override
  Future<Either<Failure, List<TransactionHistoryDataModel>>>
      getDataTransactionNeedProcessHistory() {
    return executeEither(() async {
      final result = await remoteDataSourceNeedProcess
          .getDataTransactionNeedProcessHistory();
      final invoiceData = result.map((item) => item.toEntity()).toList();

      return invoiceData;
    });
  }

  @override
  Future<Either<Failure, ModelFeedNotifCount>> getFeedNotifCount() {
    return executeEither(() async {
      final result = await remoteDataSourceNeedProcess.getNotificationCount();
      final data = result;
      return data.toEntity();
    });
  }

  @override
  Future<Either<Failure, bool>> getNotificationsRead(int id) {
    return executeEither(() async {
      final result = await remoteDataSourceNeedProcess.getNotifRead(id);
      final data = result;
      return data;
    });
  }
}
