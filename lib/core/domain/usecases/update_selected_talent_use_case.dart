import 'package:dartz/dartz.dart';
import 'package:komtim_partner/core/domain/entities/talents_model.dart';

import '../../../common/failure.dart';
import '../repositories/talent_repository.dart';

class UpdateSelectedTalensUseCase {
  final TalentRepository _repository;
  const UpdateSelectedTalensUseCase(this._repository);

  Future<Either<Failure, bool>> execute(TalentsSelectedDataModel talent) {
    return _repository.updateSelectedDataModel(talent);
  }
}