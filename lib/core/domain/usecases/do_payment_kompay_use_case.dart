import 'package:dartz/dartz.dart';
import 'package:komtim_partner/common/failure.dart';
import 'package:komtim_partner/core/domain/entities/basic_meta_data_model.dart';
import 'package:komtim_partner/core/domain/repositories/withdrawal_kompay_repository.dart';

class DoPaymentKompayUseCase {
  final WithdrawalKompayRepository _repository;

  const DoPaymentKompayUseCase(this._repository);

  Future<Either<Failure, BasicMetaDataModels>> execute(String id) {
    return _repository.paymentKompay(id);
  }
}
