import 'package:dartz/dartz.dart';
import 'package:komtim_partner/core/domain/entities/bank_accounts_model.dart';
import 'package:komtim_partner/core/domain/repositories/withdrawal_kompay_repository.dart';

import '../../../common/failure.dart';

class GetBankListWithdrawalUseCase {
  final WithdrawalKompayRepository _repository;

  const GetBankListWithdrawalUseCase(this._repository);

  Future<Either<Failure, List<BankAccountsDataModel>>> execute() {
    return _repository.getBankList();
  }
}
