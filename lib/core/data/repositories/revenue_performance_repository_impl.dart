import 'package:dartz/dartz.dart';
import 'package:komtim_partner/common/failure.dart';
import 'package:komtim_partner/core/data/datasources/remote/revenue_performance_remote_datasource.dart';
import 'package:komtim_partner/core/data/repositories/base_repository.dart';
import 'package:komtim_partner/core/domain/entities/revenue_performance_model.dart';
import 'package:komtim_partner/core/domain/repositories/revenue_performance_repository.dart';

class RevenuePerformanceRepositoryImpl extends BaseRepository
    implements RevenuePerformanceRepository {
  final RevenuePerformanceRemoteDataSource remoteDataSource;

  RevenuePerformanceRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, RevenuePerformanceModel>> getRevenueOrderPerformance({
    required String startDate,
    required String endDate,
    String? paymentMethod,
  }) async {
    return executeEither<RevenuePerformanceModel>(() async {
      final response = await remoteDataSource.getRevenueOrderPerformance(
        startDate: startDate,
        endDate: endDate,
        paymentMethod: paymentMethod,
      );
      return response.toEntity();
    });
  }
}
