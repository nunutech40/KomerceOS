import 'package:dartz/dartz.dart';
import 'package:komtim_partner/common/failure.dart';
import 'package:komtim_partner/core/domain/entities/talent_recomendation_model.dart';
import 'package:komtim_partner/core/domain/repositories/resource_talent_repository.dart';

class GetResourceTalentUseCase {
  final ResourceTalentRepository repository;

  GetResourceTalentUseCase(this.repository);

  Future<Either<Failure, List<TalentRecommendationModel>>> call({
    required List<int> ratings,
    required List<String> experiences,
    required List<int> businessSectorIds,
    required String skillName,
    required int offset,
    required int limit,
  }) {
    return repository.getResourceTalents(
      ratings: ratings,
      experiences: experiences,
      businessSectorIds: businessSectorIds,
      skillName: skillName,
      offset: offset,
      limit: limit,
    );
  }
}
