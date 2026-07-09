import 'package:dartz/dartz.dart';
import 'package:komtim_partner/common/failure.dart';
import 'package:komtim_partner/core/domain/entities/talent_recomendation_model.dart';
import 'package:komtim_partner/core/domain/repositories/talent_recomendation.dart';

class GetTalentRecommendationUseCase {
  final TalentRecomendationRepository repository;

  GetTalentRecommendationUseCase(this.repository);

  Future<Either<Failure, List<TalentRecommendationModel>>> call({
    required int offset,
    required int limit,
    required String rating,
    required String businessSector,
  }) async {
    return await repository.getTalentRecommendation(
      offset: offset,
      limit: limit,
      rating: rating,
      businessSector: businessSector,
    );
  }
}
