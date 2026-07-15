import 'package:komtim_partner/core/data/apiservice/constat_endpoint.dart';
import 'package:komtim_partner/core/data/apiservice/dio_client.dart';
import 'package:komtim_partner/core/data/apiservice/dio_response_parser.dart';
import 'package:komtim_partner/core/data/models/meta_response.dart';

abstract class ExpireQrcodeRemoteDataSource {
  Future<MetaResponse> expireQrcode(String id);
}

class ExpireQrcodeRemoteDataSourceImpl implements ExpireQrcodeRemoteDataSource {
  final DioClient client;
  final DioResponseParser responseParser;

  ExpireQrcodeRemoteDataSourceImpl({
    required this.client,
    required this.responseParser,
  });

  @override
  Future<MetaResponse> expireQrcode(String id) async {
    final response = await client.put(Endpoints.expireQrcode(id));
    return responseParser.parseResponse<MetaResponse>(
      response,
      (json) => MetaResponse.fromJson(json),
    );
  }
}
