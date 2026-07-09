import 'package:dartz/dartz.dart';
import 'package:komtim_partner/common/failure.dart';
import 'package:komtim_partner/core/domain/entities/report_performance_model.dart';
import 'package:komtim_partner/core/domain/repositories/report_performance_repository.dart';

class GetReportPerformanceUseCase {
  final ReportPerformanceRepository _repository;
  GetReportPerformanceUseCase(this._repository);

  Future<Either<Failure, List<ReportPerformanceModel>>> execute({
    required String search,
    required String limit,
    required String offset,
    required String startDate,
    required String endDate,
  }) {
    return _repository.getReportPerformance(
      search: search,
      limit: limit,
      offset: offset,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
