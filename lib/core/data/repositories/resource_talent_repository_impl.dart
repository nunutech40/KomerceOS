import 'package:dartz/dartz.dart';
import 'package:komtim_partner/common/failure.dart';
import 'package:komtim_partner/core/data/datasources/remote/resource_talent_datasource.dart';
import 'package:komtim_partner/core/data/repositories/base_repository.dart';
import 'package:komtim_partner/core/domain/entities/talent_recomendation_model.dart';
import 'package:komtim_partner/core/domain/repositories/resource_talent_repository.dart';

class ResourceTalentRepositoryImpl extends BaseRepository
    implements ResourceTalentRepository {
  final ResourceTalentRemoteDataSource remoteDataSource;

  ResourceTalentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<TalentRecommendationModel>>> getResourceTalents({
    required List<int> ratings,
    required List<String> experiences,
    required List<int> businessSectorIds,
    required String skillName,
    required int offset,
    required int limit,
  }) {
    return executeEither(() async {
      final result = await remoteDataSource.getResourceTalents(
        ratings: ratings,
        experiences: experiences,
        businessSectorIds: businessSectorIds,
        skillName: skillName,
        offset: offset,
        limit: limit,
      );
      return result.map((item) => item.toEntity()).toList();
    });
  }

  @override
  Future<Either<Failure, bool>> putWishlist(int talentId) {
    return executeEither(() => remoteDataSource.putWishlist(talentId));
  }
}
