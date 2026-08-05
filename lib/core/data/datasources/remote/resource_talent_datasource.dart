import 'package:komtim_partner/core/data/apiservice/constat_endpoint.dart';
import 'package:komtim_partner/core/data/apiservice/dio_client.dart';
import 'package:komtim_partner/core/data/apiservice/dio_response_parser.dart';
import 'package:komtim_partner/core/data/models/talent_recomendation_reponse.dart';

/// DataSource untuk endpoint resource/talents (Talent Pool dengan filter lengkap).
/// Endpoint: GET /talent-pool/api/v1/resource/talents
abstract class ResourceTalentRemoteDataSource {
  Future<List<TalentRecommendationResponse>> getResourceTalents({
    required List<int> ratings,
    required List<String> experiences,
    required List<int> businessSectorIds,
    required String skillName,
    required int offset,
    required int limit,
  });
}

class ResourceTalentRemoteDataSourceImpl
    implements ResourceTalentRemoteDataSource {
  final DioClient client;
  final DioResponseParser responseParser;

  ResourceTalentRemoteDataSourceImpl({
    required this.client,
    required this.responseParser,
  });

  @override
  Future<List<TalentRecommendationResponse>> getResourceTalents({
    required List<int> ratings,
    required List<String> experiences,
    required List<int> businessSectorIds,
    required String skillName,
    required int offset,
    required int limit,
  }) async {
    final queryParams = <String, dynamic>{
      'rating': ratings.isEmpty ? '' : ratings.join(','),
      'experience': experiences.isEmpty ? '' : experiences.join(','),
      'business_sector_id':
          businessSectorIds.isEmpty ? '' : businessSectorIds.join(','),
      'skill_name': skillName,
      'offset': offset,
      'limit': limit,
    };

    final response = await client.get(
      Endpoints.resourceTalents,
      queryParameters: queryParams,
    );

    return responseParser.parseResponse<List<TalentRecommendationResponse>>(
      response,
      (json) => ((json as List?) ?? [])
          .map((item) => TalentRecommendationResponse.fromJson(item))
          .toList(),
    );
  }
}
