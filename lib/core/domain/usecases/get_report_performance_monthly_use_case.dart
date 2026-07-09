import 'package:dartz/dartz.dart';
import 'package:komtim_partner/common/failure.dart';
import 'package:komtim_partner/core/domain/entities/report_performance_monthly_model.dart';
import 'package:komtim_partner/core/domain/repositories/report_performance_repository.dart';

class GetReportPerformanceMonthlyUseCase {
  final ReportPerformanceRepository reportPerformanceRepository;

  GetReportPerformanceMonthlyUseCase(this.reportPerformanceRepository);

  Future<Either<Failure, List<ReportPerformanceMonthlyModel>>> call({
    required String limit,
    required String offset,
    required String month,
  }) async {
    return reportPerformanceRepository.getMonthlyReportPerformance(
      limit: limit,
      offset: offset,
      month: month,
    );
  }
}
