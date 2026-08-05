import 'package:dartz/dartz.dart';
import 'package:komtim_partner/common/failure.dart';
import 'package:komtim_partner/core/domain/entities/talent_recomendation_model.dart';

abstract class ResourceTalentRepository {
  Future<Either<Failure, List<TalentRecommendationModel>>> getResourceTalents({
    required List<int> ratings,
    required List<String> experiences,
    required List<int> businessSectorIds,
    required String skillName,
    required int offset,
    required int limit,
  });
}
