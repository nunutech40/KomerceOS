import 'package:dartz/dartz.dart';
import 'package:komtim_partner/common/failure.dart';
import 'package:komtim_partner/core/domain/entities/report_performance_model.dart';
import 'package:komtim_partner/core/domain/entities/report_performance_monthly_model.dart';
import 'package:komtim_partner/core/domain/entities/report_performance_product_model.dart';
import 'package:komtim_partner/core/domain/entities/report_performance_weekly_model.dart';

abstract class ReportPerformanceRepository {
  Future<Either<Failure, List<ReportPerformanceModel>>> getReportPerformance({
    required String search,
    required String limit,
    required String offset,
    required String startDate,
    required String endDate,
  });

  Future<Either<Failure, List<ReportPerformanceProductModel>>>
      getProductReportPerformance({
    required String keyword,
    required String partnerId,
  });
  Future<Either<Failure, List<ReportPerformanceWeeklyModel>>>
      getWeeklyReportPerformance({
    required String limit,
    required String offset,
    required String week,
    required String month,
    required String productId,
  });
  Future<Either<Failure, List<ReportPerformanceMonthlyModel>>>
      getMonthlyReportPerformance({
    required String limit,
    required String offset,
    required String month,
  });
}
