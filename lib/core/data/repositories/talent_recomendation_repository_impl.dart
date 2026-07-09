import 'package:dartz/dartz.dart';
import 'package:komtim_partner/common/failure.dart';
import 'package:komtim_partner/core/data/datasources/remote/talent_recomendation_datasource.dart';
import 'package:komtim_partner/core/data/repositories/base_repository.dart';
import 'package:komtim_partner/core/domain/entities/talent_recomendation_model.dart';
import 'package:komtim_partner/core/domain/repositories/talent_recomendation.dart';

class TalentRecomendationRepositoryImpl extends BaseRepository
    implements TalentRecomendationRepository {
  final TalentRecomendationRemoteDataSource remoteDataSource;

  TalentRecomendationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<TalentRecommendationModel>>>
      getTalentRecommendation(
          {required int offset,
          required int limit,
          required String rating,
          required String businessSector}) {
    return executeEither(() async {
      final result = await remoteDataSource.getTalentRecommendation(
        offset: offset,
        limit: limit,
        rating: rating,
        businessSector: businessSector,
      );
      final talentRecomendation =
          result.map((item) => item.toEntity()).toList();
      return talentRecomendation;
    });
  }
}
