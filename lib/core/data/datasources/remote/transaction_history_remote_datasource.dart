import 'package:komtim_partner/core/data/models/notification_count_reponse.dart';
import 'package:komtim_partner/core/data/models/notifications_response.dart';
import 'package:komtim_partner/core/data/models/transaction_history_response.dart';

import '../../apiservice/constat_endpoint.dart';
import '../../apiservice/dio_client.dart';
import '../../apiservice/dio_response_parser.dart';

abstract class TransactionHistoryRemoteDataSource {
  Future<List<TransactionHistoryResponseData>> getDataTransactionHistory(
      String? type, int offset, int limit);
  Future<List<TransactionHistoryResponseData>>
      getDataTransactionNeedProcessHistory();
  Future<List<NotificationsResponseData>> getDataNotifications();
  Future<NotificationCountReponse> getNotificationCount();
  Future<bool> getNotifRead(int id);
}

class TransactionHistoryRemoteDataSourceImpl
    implements TransactionHistoryRemoteDataSource {
  final DioClient client;
  final DioResponseParser responseParser;

  TransactionHistoryRemoteDataSourceImpl(
      {required this.client, required this.responseParser});

  @override
  Future<List<TransactionHistoryResponseData>> getDataTransactionHistory(
      String? type, int offset, int limit) async {
    final queryParams = <String, dynamic>{
      'offset': offset,
      'limit': limit,
    };

    if (type != null &&
        (type == "invoice" || type == "topup" || type == "withdrawal")) {
      queryParams['type'] = type;
    }

    final response = await client.get(
      Endpoints.transactionHistory,
      queryParameters: queryParams,
    );

    return responseParser.parseResponse<List<TransactionHistoryResponseData>>(
        response,
        (json) => ((json as List?) ?? [])
            .map((item) => TransactionHistoryResponseData.fromJson(item))
            .toList());
  }

  @override
  Future<List<NotificationsResponseData>> getDataNotifications() async {
    final response = await client.get(Endpoints.notifications);

    return responseParser.parseResponse<List<NotificationsResponseData>>(
        response,
        (json) => ((json as List?) ?? [])
            .map((item) => NotificationsResponseData.fromJson(item))
            .toList());
  }

  @override
  Future<List<TransactionHistoryResponseData>>
      getDataTransactionNeedProcessHistory() async {
    final response = await client.get(Endpoints.transactionNeedProcessHistory);

    return responseParser.parseResponse<List<TransactionHistoryResponseData>>(
        response,
        (json) => ((json as List?) ?? [])
            .map((item) => TransactionHistoryResponseData.fromJson(item))
            .toList());
  }

  @override
  Future<bool> getNotifRead(id) async {
    final response = await client.patch(
      '${Endpoints.notificationsRead}/$id',
    );

    return responseParser.parseResponseMeta<bool>(response, (_) => true);
  }

  @override
  Future<NotificationCountReponse> getNotificationCount() async {
    final response = await client.get(Endpoints.notificationsCount);

    return responseParser.parseResponse<NotificationCountReponse>(
        response, (json) => NotificationCountReponse.fromJson(json));
  }
}
