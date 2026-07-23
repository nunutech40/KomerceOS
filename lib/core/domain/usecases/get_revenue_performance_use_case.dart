import 'package:dartz/dartz.dart';
import 'package:komtim_partner/common/failure.dart';
import 'package:komtim_partner/core/domain/entities/revenue_performance_model.dart';
import 'package:komtim_partner/core/domain/repositories/revenue_performance_repository.dart';

class GetRevenuePerformanceUseCase {
  final RevenuePerformanceRepository repository;

  GetRevenuePerformanceUseCase(this.repository);

  Future<Either<Failure, RevenuePerformanceModel>> call({
    required String startDate,
    required String endDate,
    String? paymentMethod,
  }) {
    return repository.getRevenueOrderPerformance(
      startDate: startDate,
      endDate: endDate,
      paymentMethod: paymentMethod,
    );
  }
}
