import 'package:komtim_partner/core/data/apiservice/constat_endpoint.dart';
import 'package:komtim_partner/core/data/apiservice/dio_client.dart';
import 'package:komtim_partner/core/data/apiservice/dio_response_parser.dart';
import 'package:komtim_partner/core/data/models/report_performance_monthly_response.dart';
import 'package:komtim_partner/core/data/models/report_performance_product_reponse.dart';
import 'package:komtim_partner/core/data/models/report_performance_response.dart';
import 'package:komtim_partner/core/data/models/report_performance_weekly_response.dart';

abstract class ReportPerformanceDataSource {
  Future<List<ReportPerformanceResponse>> getReportPerformance({
    required String search,
    required String limit,
    required String offset,
    required String startDate,
    required String endDate,
  });

  Future<List<ReportPerformanceProductResponse>> getProductReportPerformance({
    required String keyword,
    required String partnerId,
  });
  Future<List<ReportPerformanceWeeklyResponse>> getWeeklyReportPerformance({
    required String limit,
    required String offset,
    required String week,
    required String month,
    required String productId,
  });
  Future<List<ReportPerformanceMonthlyResponse>> getMonthlyReportPerformance({
    required String limit,
    required String offset,
    required String month,
  });
}

class ReportPerformanceDataSourceImpl implements ReportPerformanceDataSource {
  final DioClient client;
  final DioResponseParser responseParser;

  ReportPerformanceDataSourceImpl({
    required this.client,
    required this.responseParser,
  });

  @override
  Future<List<ReportPerformanceResponse>> getReportPerformance({
    required String search,
    required String limit,
    required String offset,
    required String startDate,
    required String endDate,
  }) async {
    final queryParams = {
      'search': search,
      'limit': limit,
      'offset': offset,
      'start_date': startDate,
      'end_date': endDate,
    };

    final response = await client.get(
      Endpoints.reportPerformance,
      queryParameters: queryParams,
    );

    return responseParser.parseResponse<List<ReportPerformanceResponse>>(
      response,
      (json) => ((json as List?) ?? [])
          .map((item) => ReportPerformanceResponse.fromJson(item))
          .toList(),
    );
  }

  @override
  Future<List<ReportPerformanceMonthlyResponse>> getMonthlyReportPerformance(
      {required String limit,
      required String offset,
      required String month}) async {
    final queryParams = {
      'limit': limit,
      'offset': offset,
      'month': month,
    };

    final response = await client.get(
      Endpoints.monthlyReportPerformance,
      queryParameters: queryParams,
    );

    return responseParser.parseResponse<List<ReportPerformanceMonthlyResponse>>(
      response,
      (json) => ((json as List?) ?? [])
          .map((item) => ReportPerformanceMonthlyResponse.fromJson(item))
          .toList(),
    );
  }

  @override
  Future<List<ReportPerformanceProductResponse>> getProductReportPerformance(
      {required String keyword, required String partnerId}) async {
    final queryParams = {
      'keyword': keyword,
      'partner_id': partnerId,
    };

    final response = await client.get(
      Endpoints.productReportPerformance,
      queryParameters: queryParams,
    );

    return responseParser.parseResponse<List<ReportPerformanceProductResponse>>(
      response,
      (json) => ((json as List?) ?? [])
          .map((item) => ReportPerformanceProductResponse.fromJson(item))
          .toList(),
    );
  }

  @override
  Future<List<ReportPerformanceWeeklyResponse>> getWeeklyReportPerformance(
      {required String limit,
      required String offset,
      required String week,
      required String month,
      required String productId}) async {
    final queryParams = {
      'limit': limit,
      'offset': offset,
      'week': week,
      'month': month,
      'product_id': productId,
    };

    final response = await client.get(
      Endpoints.weeklyReportPerformance,
      queryParameters: queryParams,
    );

    return responseParser.parseResponse<List<ReportPerformanceWeeklyResponse>>(
      response,
      (json) => ((json as List?) ?? [])
          .map((item) => ReportPerformanceWeeklyResponse.fromJson(item))
          .toList(),
    );
  }
}
