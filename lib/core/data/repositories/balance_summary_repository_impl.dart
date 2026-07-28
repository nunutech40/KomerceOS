import 'package:dartz/dartz.dart';
import '../../../common/failure.dart';
import '../../domain/entities/balance_summary_model.dart';
import '../../domain/repositories/balance_summary_repository.dart';
import '../datasources/remote/balance_summary_remote_datasource.dart';
import 'base_repository.dart';

class BalanceSummaryRepositoryImpl extends BaseRepository
    implements BalanceSummaryRepository {
  final BalanceSummaryRemoteDataSource remoteDataSource;

  BalanceSummaryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, BalanceSummaryModel>> getBalanceSummary(
      String partnerId) async {
    return executeEither<BalanceSummaryModel>(() async {
      final response = await remoteDataSource.getBalanceSummary(partnerId);
      return response.toEntity();
    });
  }
}
