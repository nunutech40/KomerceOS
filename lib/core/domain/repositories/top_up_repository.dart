import 'package:dartz/dartz.dart';
import 'package:komtim_partner/core/data/models/topup_qris_response.dart';
import 'package:komtim_partner/core/data/models/topup_response.dart';
import '../../../common/failure.dart';

abstract class TopUpRepository {
  Future<Either<Failure, TopupResponse>> topUpBank(
      String nominal, int adminFee);
  Future<Either<Failure, TopupQRISResponse>> topUpQris(String nominal);
  Future<Either<Failure, TopupDetailResponse>> topUpdetail(int transactionId);
  Future<Either<Failure, bool>> topUpCancel(int transactionId);
  Future<Either<Failure, TopupDetailResponse>> topUpCeckTransaction(
      String typeCheckTrasaction);
}
