import 'package:dartz/dartz.dart';
import 'package:komtim_partner/common/failure.dart';
import 'package:komtim_partner/core/domain/entities/balance_analytics_model.dart';
import 'package:komtim_partner/core/domain/repositories/withdrawal_kompay_repository.dart';

class GetBalanceAnalyticsUseCase {
  final WithdrawalKompayRepository _repository;

  const GetBalanceAnalyticsUseCase(this._repository);

  Future<Either<Failure, DashboardBalanceModel>> execute(int id) {
    return _repository.balanceAnalytics(id);
  }
}
