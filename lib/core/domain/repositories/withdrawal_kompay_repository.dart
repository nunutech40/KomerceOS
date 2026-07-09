import 'package:dartz/dartz.dart';
import 'package:komtim_partner/core/domain/entities/balance_analytics_model.dart';
import 'package:komtim_partner/core/domain/entities/bank_accounts_model.dart';
import 'package:komtim_partner/core/domain/entities/basic_meta_data_model.dart';
import 'package:komtim_partner/core/domain/entities/ideal_balance_model.dart';
import '../../../common/failure.dart';

abstract class WithdrawalKompayRepository {
  Future<Either<Failure, List<BankAccountsDataModel>>> getBankList();
  Future<Either<Failure, BasicMetaDataModels>> paymentKompay(String id);
  Future<Either<Failure, DashboardBalanceModel>> balanceAnalytics(int id);
  Future<Either<Failure, IdealBalanceModel>> getIdealBalanceSaldo(
      {required int partnerId});
}
