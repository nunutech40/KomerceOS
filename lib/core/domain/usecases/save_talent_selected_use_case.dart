import 'package:dartz/dartz.dart';
import 'package:komtim_partner/core/data/models/talents_response.dart';

import '../../../common/failure.dart';
import '../repositories/talent_repository.dart';

class SaveSelectedTalensUseCase {
  final TalentRepository _repository;
  const SaveSelectedTalensUseCase(this._repository);

  Future<Either<Failure, bool>> execute(List<TalentsSelectedData> talent) {
    return _repository.saveSelectedTalents(talent);
  }
}