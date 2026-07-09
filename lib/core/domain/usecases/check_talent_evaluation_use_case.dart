import 'package:dartz/dartz.dart';
import 'package:komtim_partner/core/data/models/invoice_detail_response.dart';
import 'package:komtim_partner/core/domain/repositories/invoice_repository.dart';

import '../../../common/failure.dart';

class CheckTalentEvaluationUseCase {
  final InvoiceRepository _repository;

  const CheckTalentEvaluationUseCase(this._repository);

  Future<Either<Failure, CheckEvaluationResponse>> execute(
      String transactionId) {
    return _repository.checkTalentsEvaluation(transactionId);
  }
}
