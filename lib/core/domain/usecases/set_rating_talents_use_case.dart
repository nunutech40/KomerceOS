import 'package:dartz/dartz.dart';
import 'package:komtim_partner/core/domain/repositories/talent_repository.dart';

import '../../../common/failure.dart';
import '../entities/talents_model.dart';

class SetRatingTalentsUseCase {
  final TalentRepository repository;

  SetRatingTalentsUseCase(this.repository);

  Future<Either<Failure, bool>> execute(List<TalentsDataModel> talents,
      List<TalentLeaderModel> leaders, int invoiceId, int amount) {
    return repository.setRateTalents(talents, leaders, invoiceId, amount);
  }
}
