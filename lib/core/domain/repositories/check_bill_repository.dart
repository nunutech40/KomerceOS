import 'package:dartz/dartz.dart';
import 'package:komtim_partner/common/failure.dart';
import '../entities/check_bill_model.dart';

abstract class CheckBillRepository {
  Future<Either<Failure, CheckBillModel>> checkBill();
}
