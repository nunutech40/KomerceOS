import 'package:dartz/dartz.dart';
import 'package:komtim_partner/core/domain/entities/talents_model.dart';

import '../../../common/failure.dart';
import '../repositories/talent_repository.dart';

class GetSelectedTalensUseCase {
  final TalentRepository _repository;

  const GetSelectedTalensUseCase(this._repository);

  Future<Either<Failure, List<TalentsSelectedDataModel>>> execute() {
    return _repository.getSelectedTalentsDataModel();
  }
}