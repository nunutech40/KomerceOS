import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:komtim_partner/common/failure.dart';
import 'package:komtim_partner/core/data/datasources/remote/topup_remote_datasource.dart';
import 'package:komtim_partner/core/data/models/topup_qris_response.dart';
import 'package:komtim_partner/core/data/models/topup_response.dart';
import 'package:komtim_partner/core/domain/repositories/top_up_repository.dart';
import 'base_repository.dart';

class TopUpRepositoryImpl extends BaseRepository implements TopUpRepository {
  final TopUpRemoteDataSource remoteDataSource;

  TopUpRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, TopupResponse>> topUpBank(
      String nominal, int adminFee) async {
    return executeEither(() async {
      final result = await remoteDataSource.topUp(nominal, adminFee);

      return result.toEntity();
    });
  }

  @override
  Future<Either<Failure, TopupQRISResponse>> topUpQris(String nominal) {
    return executeEither(() async {
      final result = await remoteDataSource.topUpQRIS(nominal);
      return result.toEntity();
    });
  }

  @override
  Future<Either<Failure, TopupDetailResponse>> topUpdetail(int transactionId) {
    return executeEither(() async {
      final result = await remoteDataSource.topUpDetail(transactionId);
      return result.toEntity();
    });
  }

  @override
  Future<Either<Failure, bool>> topUpCancel(int transactionId) async {
    return executeEither(() async {
      final result = await remoteDataSource.topUpCancel(transactionId);
      return result;
    });
  }

  @override
  Future<Either<Failure, TopupDetailResponse>> topUpCeckTransaction(
      String typeCheckTrasaction) {
    return executeEither(() async {
      final result =
          await remoteDataSource.topUpCeckTransaction(typeCheckTrasaction);
      return result;
    });
  }
}
