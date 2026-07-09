import 'package:dartz/dartz.dart';
import 'package:komtim_partner/core/domain/entities/talents_model.dart';

import '../../../common/failure.dart';
import '../../data/models/talents_response.dart';

abstract class TalentRepository {
  Future<Either<Failure, TalentsModel>> getTalents();
  Future<Either<Failure, bool>> setRateTalents(List<TalentsDataModel> talents,
      List<TalentLeaderModel> leaders, int invoiceId, int amount);
  Future<Either<Failure, List<TalentsSelectedDataModel>>>
      getSelectedTalentsDataModel();
  Future<Either<Failure, bool>> updateSelectedDataModel(
      TalentsSelectedDataModel talent);
  Future<Either<Failure, bool>> saveSelectedTalents(
      List<TalentsSelectedData> talents);
  Future<Either<Failure, bool>> sendUnhireTalents(
      List<TalentsUnhireDataModel> talents);
  Future<Either<Failure, TalentsModel>> getTalentsEvaluation(
      {required int invoiceId});
}
