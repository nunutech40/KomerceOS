import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:komtim_partner/common/failure.dart';
import 'package:komtim_partner/core/data/datasources/remote/kompay_remote_datasource.dart';
import 'package:komtim_partner/core/domain/entities/balance_analytics_model.dart';
import 'package:komtim_partner/core/domain/entities/bank_accounts_model.dart';
import 'package:komtim_partner/core/domain/entities/basic_meta_data_model.dart';
import 'package:komtim_partner/core/domain/entities/ideal_balance_model.dart';
import 'package:komtim_partner/core/domain/repositories/withdrawal_kompay_repository.dart';
import 'base_repository.dart';

class KompayRepositoryImpl extends BaseRepository
    implements WithdrawalKompayRepository {
  final KompayRemoteDataSource remoteDataSource;

  KompayRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<BankAccountsDataModel>>> getBankList() async {
    return executeEither(() async {
      final result = await remoteDataSource.getBankList();
      final bankAccountsModel = result.map((item) => item.toEntity()).toList();
      return bankAccountsModel;
    });
  }

  @override
  Future<Either<Failure, BasicMetaDataModels>> paymentKompay(String id) async {
    return executeEither(() async {
      final result = await remoteDataSource.paymentKompay(id);
      final payment = result.toEntity();
      return payment;
    });
  }

  @override
  Future<Either<Failure, DashboardBalanceModel>> balanceAnalytics(
      int id) async {
    return executeEither(() async {
      final result = await remoteDataSource.balanceAnalytics(id);
      final balance = result.toEntity();
      return balance;
    });
  }

  @override
  Future<Either<Failure, IdealBalanceModel>> getIdealBalanceSaldo(
      {required int partnerId}) async {
    return executeEither(() async {
      final result =
          await remoteDataSource.getIdealBalance(partnerId: partnerId);
      final idealBalance = result.toEntity();
      return idealBalance;
    });
  }
}
