import 'package:dartz/dartz.dart';
import 'package:komtim_partner/common/failure.dart';
import 'package:komtim_partner/core/domain/entities/revenue_performance_model.dart';

abstract class RevenuePerformanceRepository {
  Future<Either<Failure, RevenuePerformanceModel>> getRevenueOrderPerformance({
    required String startDate,
    required String endDate,
    String? paymentMethod,
  });
}
