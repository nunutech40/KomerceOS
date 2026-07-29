import '../../apiservice/constat_endpoint.dart';
import '../../apiservice/dio_client.dart';
import '../../apiservice/dio_response_parser.dart';
import '../../models/superapp_profile_response.dart';

abstract class SuperappProfileRemoteDataSource {
  Future<SuperappProfileResponse> getProfile();
}

class SuperappProfileRemoteDataSourceImpl
    implements SuperappProfileRemoteDataSource {
  final DioClient client;
  final DioResponseParser responseParser;

  SuperappProfileRemoteDataSourceImpl({
    required this.client,
    required this.responseParser,
  });

  @override
  Future<SuperappProfileResponse> getProfile() async {
    final response = await client.get(Endpoints.superappGetProfile);
    return responseParser.parseResponse<SuperappProfileResponse>(
      response,
      (json) => SuperappProfileResponse.fromJson(json),
    );
  }
}
