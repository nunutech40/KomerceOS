import 'package:komtim_partner/core/data/models/balance_summary_response.dart';

import '../../apiservice/constat_endpoint.dart';
import '../../apiservice/dio_client.dart';
import '../../apiservice/dio_response_parser.dart';

abstract class BalanceSummaryRemoteDataSource {
  Future<BalanceSummaryResponse> getBalanceSummary(String partnerId);
}

class BalanceSummaryRemoteDataSourceImpl
    implements BalanceSummaryRemoteDataSource {
  final DioClient client;
  final DioResponseParser responseParser;

  BalanceSummaryRemoteDataSourceImpl({
    required this.client,
    required this.responseParser,
  });

  @override
  Future<BalanceSummaryResponse> getBalanceSummary(String partnerId) async {
    final response = await client.get(Endpoints.balanceSummary(partnerId));
    return responseParser.parseResponse<BalanceSummaryResponse>(
      response,
      (json) => BalanceSummaryResponse.fromJson(json),
    );
  }
}
