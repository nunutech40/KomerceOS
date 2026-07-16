import '../../models/check_qrcode_response.dart';
import '../../apiservice/constat_endpoint.dart';
import '../../apiservice/dio_client.dart';
import '../../apiservice/dio_response_parser.dart';

abstract class CheckQrcodeRemoteDataSource {
  Future<CheckQrcodeResponse> checkQrcode(String id);
}

class CheckQrcodeRemoteDataSourceImpl implements CheckQrcodeRemoteDataSource {
  final DioClient client;
  final DioResponseParser responseParser;

  CheckQrcodeRemoteDataSourceImpl({
    required this.client,
    required this.responseParser,
  });

  @override
  Future<CheckQrcodeResponse> checkQrcode(String id) async {
    final response = await client.get(
      Endpoints.checkQrcode,
      queryParameters: {
        'id': id,
      },
    );

    return responseParser.parseResponse<CheckQrcodeResponse>(
      response,
      (json) => CheckQrcodeResponse.fromJson(json),
    );
  }
}
