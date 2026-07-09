import 'package:komtim_partner/core/data/apiservice/constat_endpoint.dart';
import 'package:komtim_partner/core/data/apiservice/dio_client.dart';
import 'package:komtim_partner/core/data/apiservice/dio_response_parser.dart';
import 'package:komtim_partner/core/data/models/talent_recomendation_reponse.dart';

abstract class TalentRecomendationRemoteDataSource {
  Future<List<TalentRecommendationResponse>> getTalentRecommendation({
    required int offset,
    required int limit,
    required String rating,
    required String businessSector,
  });
}

class TalentRecomendationRemoteDataSourceImpl
    implements TalentRecomendationRemoteDataSource {
  final DioClient client;
  final DioResponseParser responseParser;

  TalentRecomendationRemoteDataSourceImpl(
      {required this.client, required this.responseParser});

  @override
  Future<List<TalentRecommendationResponse>> getTalentRecommendation({
    required int offset,
    required int limit,
    required String rating,
    required String businessSector,
  }) async {
    final queryParams = {
      'offset': offset,
      'limit': limit,
      'rating': rating,
      'business_sector': businessSector,
    };

    final response = await client.get(
      Endpoints.talentRecomendation,
      queryParameters: queryParams,
    );

    return responseParser.parseResponse<List<TalentRecommendationResponse>>(
        response,
        (json) => ((json as List?) ?? [])
            .map((item) => TalentRecommendationResponse.fromJson(item))
            .toList());
  }
}
