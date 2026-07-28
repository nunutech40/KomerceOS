import 'package:dartz/dartz.dart';
import '../../../common/failure.dart';
import '../entities/balance_summary_model.dart';

abstract class BalanceSummaryRepository {
  Future<Either<Failure, BalanceSummaryModel>> getBalanceSummary(
      String partnerId);
}
