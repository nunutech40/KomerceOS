import 'package:dartz/dartz.dart';
import 'package:komtim_partner/common/failure.dart';
import 'package:komtim_partner/core/domain/entities/ideal_balance_model.dart';
import 'package:komtim_partner/core/domain/repositories/withdrawal_kompay_repository.dart';

class GetIdealBalanceUseCase {
  final WithdrawalKompayRepository repository;

  const GetIdealBalanceUseCase(this.repository);

  Future<Either<Failure, IdealBalanceModel>> call(
      {required int partnerId}) async {
    return await repository.getIdealBalanceSaldo(partnerId: partnerId);
  }
}
