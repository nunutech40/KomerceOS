import 'package:komtim_partner/core/data/apiservice/constat_endpoint.dart';
import 'package:komtim_partner/core/data/apiservice/dio_client.dart';
import 'package:komtim_partner/core/data/apiservice/dio_response_parser.dart';
import 'package:komtim_partner/core/data/models/meta_response.dart';

abstract class ExpireInvoiceRemoteDataSource {
  Future<MetaResponse> expireInvoice(String id);
}

class ExpireInvoiceRemoteDataSourceImpl implements ExpireInvoiceRemoteDataSource {
  final DioClient client;
  final DioResponseParser responseParser;

  ExpireInvoiceRemoteDataSourceImpl({
    required this.client,
    required this.responseParser,
  });

  @override
  Future<MetaResponse> expireInvoice(String id) async {
    final response = await client.put(Endpoints.expireInvoice(id));
    return responseParser.parseResponse<MetaResponse>(
      response,
      (json) => MetaResponse.fromJson(json),
    );
  }
}
