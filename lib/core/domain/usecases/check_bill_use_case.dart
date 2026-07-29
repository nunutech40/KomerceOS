import 'package:dartz/dartz.dart';
import 'package:komtim_partner/common/failure.dart';
import 'package:komtim_partner/core/domain/entities/check_bill_model.dart';
import 'package:komtim_partner/core/domain/repositories/check_bill_repository.dart';

class CheckBillUseCase {
  final CheckBillRepository repository;

  CheckBillUseCase(this.repository);

  Future<Either<Failure, CheckBillModel>> call() {
    return repository.checkBill();
  }
}
