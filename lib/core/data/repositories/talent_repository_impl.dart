import 'package:dartz/dartz.dart';
import 'package:komtim_partner/core/data/datasources/remote/talent_remote_datasource.dart';
import 'package:komtim_partner/core/domain/entities/talents_model.dart';
import 'package:komtim_partner/core/domain/repositories/talent_repository.dart';
import 'package:komtim_partner/features/unhire/view/unhire_page.dart';

import '../../../common/failure.dart';
import '../datasources/preferences/shared_pref.dart';
import '../models/talents_response.dart';
import 'base_repository.dart';

class TalentRepositoryImpl extends BaseRepository implements TalentRepository {
  final TalentRemoteDataSource remoteDataSource;
  final SharedPref sharedPref;

  TalentRepositoryImpl(
      {required this.remoteDataSource, required this.sharedPref});

  @override
  Future<Either<Failure, TalentsModel>> getTalents() async {
    return executeEither(() async {
      final result = await remoteDataSource.getDataTalents();
      final talentModel = result.toEntity();
      return talentModel;
    });
  }

  @override
  Future<Either<Failure, bool>> setRateTalents(
    List<TalentsDataModel> talents,
    List<TalentLeaderModel> leaders,
    int invoiceId,
    int amount,
  ) async {
    return executeEither(() async {
      final result = await remoteDataSource.setRateTalents(
          talents, leaders, invoiceId, amount);
      return result;
    });
  }

  @override
  Future<Either<Failure, List<TalentsSelectedDataModel>>>
      getSelectedTalentsDataModel() async {
    return executeEither(() async {
      final talentsSelected = await sharedPref.getTalents();
      final resultTalent =
          talentsSelected.map((item) => item.toEntity()).toList();
      return resultTalent;
    });
  }

  @override
  Future<Either<Failure, bool>> updateSelectedDataModel(
      TalentsSelectedDataModel talent) async {
    return executeEither(() async {
      final updateTalent = await sharedPref.updateReasonByJobAssigneeId(
          talent.jobAssigneeId, talent.reason, talent.isSelected);
      return updateTalent;
    });
  }

  @override
  Future<Either<Failure, bool>> saveSelectedTalents(
      List<TalentsSelectedData> talents) async {
    return executeEither(() async {
      return await pref.saveTalents(talents);
    });
  }

  @override
  Future<Either<Failure, bool>> sendUnhireTalents(
      List<TalentsUnhireDataModel> talents) async {
    return executeEither(() async {
      final result = await remoteDataSource.unhireTalents(talents);
      return result;
    });
  }

  @override
  Future<Either<Failure, TalentsModel>> getTalentsEvaluation(
      {required int invoiceId}) {
    return executeEither(() async {
      final result =
          await remoteDataSource.getDataEvaluationTalents(invoiceId: invoiceId);
      final talentModel = result.toEntity();
      return talentModel;
    });
  }
}
