import 'package:dartz/dartz.dart';
import 'package:komtim_partner/common/failure.dart';
import 'package:komtim_partner/core/domain/entities/report_performance_weekly_model.dart';
import 'package:komtim_partner/core/domain/repositories/report_performance_repository.dart';

class GetReportPerformanceWeeklyUseCase {
  final ReportPerformanceRepository reportPerformanceRepository;

  GetReportPerformanceWeeklyUseCase(this.reportPerformanceRepository);

  Future<Either<Failure, List<ReportPerformanceWeeklyModel>>> call({
    required String limit,
    required String offset,
    required String week,
    required String month,
    required String keyword,
    required String productId,
  }) async {
    return reportPerformanceRepository.getWeeklyReportPerformance(
      limit: limit,
      offset: offset,
      week: week,
      month: month,
      productId: productId,
    );
  }
}
