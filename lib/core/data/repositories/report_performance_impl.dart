import 'package:dartz/dartz.dart';
import 'package:komtim_partner/common/failure.dart';
import 'package:komtim_partner/core/data/datasources/remote/report_performance_datasource.dart';
import 'package:komtim_partner/core/data/repositories/base_repository.dart';
import 'package:komtim_partner/core/domain/entities/report_performance_model.dart';
import 'package:komtim_partner/core/domain/entities/report_performance_monthly_model.dart';
import 'package:komtim_partner/core/domain/entities/report_performance_product_model.dart';
import 'package:komtim_partner/core/domain/entities/report_performance_weekly_model.dart';
import 'package:komtim_partner/core/domain/repositories/report_performance_repository.dart';

class ReportPerformanceImpl extends BaseRepository
    implements ReportPerformanceRepository {
  final ReportPerformanceDataSource reportPerformanceDataSource;

  ReportPerformanceImpl({required this.reportPerformanceDataSource});

  @override
  Future<Either<Failure, List<ReportPerformanceModel>>> getReportPerformance(
      {required String search,
      required String limit,
      required String offset,
      required String startDate,
      required String endDate}) {
    return executeEither(() async {
      final response = await reportPerformanceDataSource.getReportPerformance(
        search: search,
        limit: limit,
        offset: offset,
        startDate: startDate,
        endDate: endDate,
      );
      final data = response.map((item) => item.toEntity()).toList();
      return data;
    });
  }

  @override
  Future<Either<Failure, List<ReportPerformanceMonthlyModel>>>
      getMonthlyReportPerformance(
          {required String limit,
          required String offset,
          required String month}) {
    return executeEither(() async {
      final response =
          await reportPerformanceDataSource.getMonthlyReportPerformance(
        limit: limit,
        offset: offset,
        month: month,
      );
      final data = response.map((item) => item.toEntity()).toList();
      return data;
    });
  }

  @override
  Future<Either<Failure, List<ReportPerformanceProductModel>>>
      getProductReportPerformance(
          {required String keyword, required String partnerId}) {
    return executeEither(() async {
      final response =
          await reportPerformanceDataSource.getProductReportPerformance(
        keyword: keyword,
        partnerId: partnerId,
      );
      final data = response.map((item) => item.toEntity()).toList();
      return data;
    });
  }

  @override
  Future<Either<Failure, List<ReportPerformanceWeeklyModel>>>
      getWeeklyReportPerformance(
          {required String limit,
          required String offset,
          required String week,
          required String month,
          required String productId}) {
    return executeEither(() async {
      final response =
          await reportPerformanceDataSource.getWeeklyReportPerformance(
        limit: limit,
        offset: offset,
        week: week,
        month: month,
        productId: productId,
      );
      final data = response.map((item) => item.toEntity()).toList();
      return data;
    });
  }
}
