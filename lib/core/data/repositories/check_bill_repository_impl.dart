import 'package:dartz/dartz.dart';
import 'package:komtim_partner/common/failure.dart';
import 'package:komtim_partner/core/data/repositories/base_repository.dart';
import 'package:komtim_partner/core/domain/entities/check_bill_model.dart';
import 'package:komtim_partner/core/domain/repositories/check_bill_repository.dart';
import '../datasources/remote/check_bill_remote_datasource.dart';

class CheckBillRepositoryImpl extends BaseRepository implements CheckBillRepository {
  final CheckBillRemoteDataSource remoteDataSource;

  CheckBillRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, CheckBillModel>> checkBill() async {
    return executeEither<CheckBillModel>(() async {
      final response = await remoteDataSource.checkBill();
      return response.toEntity();
    });
  }
}
