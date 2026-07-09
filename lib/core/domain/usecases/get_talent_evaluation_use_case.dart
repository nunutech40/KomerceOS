import 'package:dartz/dartz.dart';
import 'package:komtim_partner/core/domain/entities/talents_model.dart';

import '../../../common/failure.dart';
import '../repositories/talent_repository.dart';

class GetTalentEvaluationsUseCase {
  final TalentRepository _repository;

  const GetTalentEvaluationsUseCase(this._repository);

  Future<Either<Failure, TalentsModel>> execute({required int invoiceId}) {
    return _repository.getTalentsEvaluation(invoiceId: invoiceId);
  }
}
