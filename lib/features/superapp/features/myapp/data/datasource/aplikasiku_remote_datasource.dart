import 'package:komtim_partner/core/data/apiservice/dio_client.dart';
import 'package:komtim_partner/core/data/apiservice/dio_response_parser.dart';
import 'package:komtim_partner/core/data/apiservice/constat_endpoint.dart';
import '../models/aplikasiku_response.dart';

abstract class AplikasikuRemoteDataSource {
  Future<AplikasikuResponse> getAplikasiku();
}

class AplikasikuRemoteDataSourceImpl implements AplikasikuRemoteDataSource {
  final DioClient client;
  final DioResponseParser responseParser;

  AplikasikuRemoteDataSourceImpl({
    required this.client,
    required this.responseParser,
  });

  @override
  Future<AplikasikuResponse> getAplikasiku() async {
    final response = await client.get(Endpoints.aplikasiku);
    return responseParser.parseResponse<AplikasikuResponse>(
      response,
      (json) => AplikasikuResponse.fromJson(json),
    );
  }
}
