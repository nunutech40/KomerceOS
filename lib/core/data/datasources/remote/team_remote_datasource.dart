import 'package:komtim_partner/core/data/models/team_response.dart';

import '../../apiservice/constat_endpoint.dart';
import '../../apiservice/dio_client.dart';
import '../../apiservice/dio_response_parser.dart';

abstract class TeamRemoteDataSource {
  Future<List<TeamResponse>> getInternalTeams(String search);
  Future<List<TeamResponse>> getKomtimTeams(String search);
}

class TeamRemoteDataSourceImpl implements TeamRemoteDataSource {
  final DioClient client;
  final DioResponseParser responseParser;

  TeamRemoteDataSourceImpl({
    required this.client,
    required this.responseParser,
  });

  @override
  Future<List<TeamResponse>> getInternalTeams(String search) async {
    final response =
        await client.get('${Endpoints.internalTeams}?search=$search');

    return responseParser.parseResponse<List<TeamResponse>>(
      response,
      (json) {
        if (json == null) return [];
        return (json as List).map((e) => TeamResponse.fromJson(e)).toList();
      },
    );
  }

  @override
  Future<List<TeamResponse>> getKomtimTeams(String search) async {
    final response =
        await client.get('${Endpoints.komtimTeams}?search=$search');

    return responseParser.parseResponse<List<TeamResponse>>(
      response,
      (json) {
        if (json == null) return [];
        return (json as List).map((e) => TeamResponse.fromJson(e)).toList();
      },
    );
  }
}
