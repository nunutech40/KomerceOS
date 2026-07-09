import 'package:dartz/dartz.dart';
import 'package:komtim_partner/common/failure.dart';
import 'package:komtim_partner/core/domain/entities/talent_recomendation_model.dart';

abstract class TalentRecomendationRepository {
  Future<Either<Failure, List<TalentRecommendationModel>>>
      getTalentRecommendation(
          {required int offset,
          required int limit,
          required String rating,
          required String businessSector});
}
