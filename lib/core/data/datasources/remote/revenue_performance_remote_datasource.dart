import 'package:komtim_partner/core/data/apiservice/constat_endpoint.dart';
import 'package:komtim_partner/core/data/apiservice/dio_client.dart';
import 'package:komtim_partner/core/data/apiservice/dio_response_parser.dart';
import 'package:komtim_partner/core/data/models/revenue_performance_response.dart';

abstract class RevenuePerformanceRemoteDataSource {
  Future<RevenuePerformanceResponse> getRevenueOrderPerformance({
    required String startDate,
    required String endDate,
    String? paymentMethod,
  });
}

class RevenuePerformanceRemoteDataSourceImpl
    implements RevenuePerformanceRemoteDataSource {
  final DioClient client;
  final DioResponseParser responseParser;

  RevenuePerformanceRemoteDataSourceImpl({
    required this.client,
    required this.responseParser,
  });

  @override
  Future<RevenuePerformanceResponse> getRevenueOrderPerformance({
    required String startDate,
    required String endDate,
    String? paymentMethod,
  }) async {
    final queryParams = {
      'start_date': startDate,
      'end_date': endDate,
    };
    
    if (paymentMethod != null && paymentMethod.isNotEmpty) {
      queryParams['payment_method'] = paymentMethod;
    }

    final response = await client.get(
      Endpoints.revenueOrderPerformance,
      queryParameters: queryParams,
    );

    return responseParser.parseResponse<RevenuePerformanceResponse>(
      response,
      (json) => RevenuePerformanceResponse.fromJson(json),
    );
  }
}
