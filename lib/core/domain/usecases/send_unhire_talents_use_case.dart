
import 'package:dartz/dartz.dart';
import 'package:komtim_partner/core/domain/entities/talents_model.dart';
import 'package:komtim_partner/core/domain/repositories/talent_repository.dart';

import '../../../common/failure.dart';

class SendUnhireTalentsUseCase {
  final TalentRepository repository;

  SendUnhireTalentsUseCase(this.repository);

  Future<Either<Failure, bool>> execute(List<TalentsUnhireDataModel> talents) {
    return repository.sendUnhireTalents(talents);
  }
}