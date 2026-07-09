import '../../apiservice/constat_endpoint.dart';
import '../../apiservice/dio_client.dart';
import '../../apiservice/dio_response_parser.dart';
import '../../models/profile_response.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileResponse> getProfile();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final DioClient client;
  final DioResponseParser responseParser;

  ProfileRemoteDataSourceImpl(
      {required this.client, required this.responseParser});

  @override
  Future<ProfileResponse> getProfile() async {
    final response = await client.get(Endpoints.getProfile);

    return responseParser.parseResponse<ProfileResponse>(
        response, (json) => ProfileResponse.fromJson(json));
  }
}
