import 'package:dartz/dartz.dart';
import '../../../common/failure.dart';
import '../entities/balance_summary_model.dart';
import '../repositories/balance_summary_repository.dart';

class GetBalanceSummaryUseCase {
  final BalanceSummaryRepository repository;

  GetBalanceSummaryUseCase(this.repository);

  Future<Either<Failure, BalanceSummaryModel>> call(String partnerId) {
    return repository.getBalanceSummary(partnerId);
  }
}
