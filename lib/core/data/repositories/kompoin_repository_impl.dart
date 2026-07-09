import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:komtim_partner/common/failure.dart';
import 'package:komtim_partner/core/data/datasources/remote/kompoin_remote_datasource.dart';
import 'package:komtim_partner/core/domain/entities/topup_kompoin_model.dart';
import 'package:komtim_partner/core/domain/repositories/kompoin_repository.dart';
import 'base_repository.dart';

class KompoinRepositoryImpl extends BaseRepository
    implements KompoinRepository {
  final KompoinRemoteDataSource remoteDataSource;

  KompoinRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, bool>> withdraw(int nominal, int bankAccountId) async {
    return executeEither(() async {
      final result = await remoteDataSource.withdraw(nominal, bankAccountId);
      return result;
    });
  }

  @override
  Future<Either<Failure, TopupKompoinModel>> topUp(int nominal) async {
    return executeEither(() async {
      final result = await remoteDataSource.topUp(nominal);
      final komPoinModel = result.toEntity();
      return komPoinModel;
    });
  }
}
