import 'package:dartz/dartz.dart';
import 'package:komtim_partner/core/domain/entities/topup_kompoin_model.dart';
import '../../../common/failure.dart';

abstract class KompoinRepository {
  Future<Either<Failure, TopupKompoinModel>> topUp(int nominal);
  Future<Either<Failure, bool>> withdraw(int nominal, int bankAccountId);
}
