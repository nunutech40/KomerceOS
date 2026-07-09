import 'package:komtim_partner/core/data/models/topup_kompoin_response.dart';

import '../../apiservice/constat_endpoint.dart';
import '../../apiservice/dio_client.dart';
import '../../apiservice/dio_response_parser.dart';

abstract class KompoinRemoteDataSource {
  Future<TopupKompoinResponse> topUp(int nominal);
  Future<bool> withdraw(int nominal, int bankAccountId);
}

class KompoinRemoteDataSourceImpl implements KompoinRemoteDataSource {
  final DioClient client;
  final DioResponseParser responseParser;

  KompoinRemoteDataSourceImpl({
    required this.client,
    required this.responseParser,
  });

  @override
  Future<TopupKompoinResponse> topUp(int nominal) async {
    final data = {
      'topup_nominal': nominal,
    };

    final response = await client.post(
      Endpoints.topUpKompoin,
      data: data,
    );
    // Assuming responseParser handles metadata check inside parseResponse if needed,
    // or if standard structure
    return responseParser.parseResponse<TopupKompoinResponse>(
        response, (json) => TopupKompoinResponse.fromJson(json));
  }

  @override
  Future<bool> withdraw(int nominal, int bankAccountId) async {
    final data = {
      'withdraw_nominal': nominal,
      'withdraw_bank_account_id': bankAccountId
    };

    final response = await client.post(Endpoints.withdrawalKompoin, data: data);

    // parseResponseMeta expects a bool handler
    // Assuming we just want to verify success meta
    return responseParser.parseResponse<bool>(response, (_) => true);
  }
}
