import 'package:komtim_partner/core/data/models/notification_info_response.dart';
import 'package:komtim_partner/core/data/models/notification_v2_response.dart';
import '../../apiservice/constat_endpoint.dart';
import '../../apiservice/dio_client.dart';
import '../../apiservice/dio_response_parser.dart';

abstract class NotificationV2RemoteDataSource {
  Future<List<NotificationV2GroupResponse>> getNotifications(
    int offset,
    int limit,
    String status,
    String service,
  );
  Future<NotificationInfoResponse> getNotificationInfo();
}

class NotificationV2RemoteDataSourceImpl implements NotificationV2RemoteDataSource {
  final DioClient client;
  final DioResponseParser responseParser;

  NotificationV2RemoteDataSourceImpl({
    required this.client,
    required this.responseParser,
  });

  @override
  Future<List<NotificationV2GroupResponse>> getNotifications(
    int offset,
    int limit,
    String status,
    String service,
  ) async {
    final queryParams = <String, dynamic>{
      'offset': offset,
      'limit': limit,
    };

    if (status.isNotEmpty) {
      queryParams['status'] = status;
    }
    
    // For service, we should only pass if it's not empty and not "semua"
    if (service.isNotEmpty && service.toLowerCase() != 'semua') {
      queryParams['service'] = service.toLowerCase();
    }

    final response = await client.get(
      Endpoints.superappNotificationsList,
      queryParameters: queryParams,
    );

    return responseParser.parseResponse<List<NotificationV2GroupResponse>>(
      response,
      (json) => ((json as List?) ?? [])
          .map((item) => NotificationV2GroupResponse.fromJson(item))
          .toList(),
    );
  }

  @override
  Future<NotificationInfoResponse> getNotificationInfo() async {
    final response = await client.get(Endpoints.superappNotificationInfo);

    return responseParser.parseResponse<NotificationInfoResponse>(
      response,
      (json) => NotificationInfoResponse.fromJson(json),
    );
  }
}
