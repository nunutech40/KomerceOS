import 'package:dartz/dartz.dart';
import 'package:komtim_partner/common/failure.dart';
import 'package:komtim_partner/core/domain/entities/report_performance_product_model.dart';
import 'package:komtim_partner/core/domain/repositories/report_performance_repository.dart';

class GetReportPerformanceProductUseCase {
  final ReportPerformanceRepository reportPerformanceRepository;

  GetReportPerformanceProductUseCase(this.reportPerformanceRepository);

  Future<Either<Failure, List<ReportPerformanceProductModel>>> call(
      {required String keyword, required String partnerId}) async {
    return reportPerformanceRepository.getProductReportPerformance(
      keyword: keyword,
      partnerId: partnerId,
    );
  }
}
