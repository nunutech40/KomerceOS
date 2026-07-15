import 'package:komtim_partner/core/data/apiservice/constat_endpoint.dart';
import 'package:komtim_partner/core/data/apiservice/dio_client.dart';
import 'package:komtim_partner/core/data/apiservice/dio_response_parser.dart';
import 'package:komtim_partner/core/data/models/check_bill_response.dart';

abstract class CheckBillRemoteDataSource {
  Future<CheckBillResponse> checkBill();
}

class CheckBillRemoteDataSourceImpl implements CheckBillRemoteDataSource {
  final DioClient client;
  final DioResponseParser responseParser;

  CheckBillRemoteDataSourceImpl({
    required this.client,
    required this.responseParser,
  });

  @override
  Future<CheckBillResponse> checkBill() async {
    final response = await client.get(Endpoints.checkBill);
    return responseParser.parseResponse<CheckBillResponse>(
      response,
      (json) => CheckBillResponse.fromJson(json),
    );
  }
}
