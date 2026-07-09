import 'package:komtim_partner/core/data/models/balance_analytics_response.dart';
import 'package:komtim_partner/core/data/models/bank_accounts_response.dart';
import 'package:komtim_partner/core/data/models/basic_meta_data_response.dart';
import 'package:komtim_partner/core/data/models/ideal_balance_response.dart';

import '../../apiservice/constat_endpoint.dart';
import '../../apiservice/dio_client.dart';
import '../../apiservice/dio_response_parser.dart';

abstract class KompayRemoteDataSource {
  Future<List<BankAccountsResponeData>> getBankList();
  Future<BasicMetaDataResponse> paymentKompay(String id);
  Future<DashboardBalanceResponse> balanceAnalytics(int id);
  Future<IdealBalanceResponse> getIdealBalance({required int partnerId});
}

class KompayRemoteDataSourceImpl implements KompayRemoteDataSource {
  final DioClient client;
  final DioResponseParser responseParser;

  KompayRemoteDataSourceImpl(
      {required this.client, required this.responseParser});

  @override
  Future<List<BankAccountsResponeData>> getBankList() async {
    final response = await client.get(Endpoints.bankList);

    return responseParser.parseResponse<List<BankAccountsResponeData>>(
        response,
        (json) => ((json as List?) ?? [])
            .map((item) => BankAccountsResponeData.fromJson(item))
            .toList());
  }

  @override
  Future<BasicMetaDataResponse> paymentKompay(String id) async {
    final data = {
      'invoice_code': id,
    };

    final response = await client.post(
      Endpoints.paymentKompay,
      data: data,
    );

    // Using Dio, response.data should already be json decoded if the server returns JSON
    final dynamic jsonData = response.data;
    final meta = jsonData is Map ? jsonData['meta'] : null;

    return BasicMetaDataResponse(
      meta: MetaResponses.fromJson(meta),
      data: null,
    );
  }

  @override
  Future<DashboardBalanceResponse> balanceAnalytics(int id) async {
    final response = await client.get('${Endpoints.transactionBalance}/$id');

    return responseParser.parseResponseMetaData<DashboardBalanceResponse>(
        response, (json) => DashboardBalanceResponse.fromJson(json));
  }

  @override
  Future<IdealBalanceResponse> getIdealBalance({required int partnerId}) async {
    final response = await client.get(
      "${Endpoints.transactionBalance}/${partnerId.toString()}",
    );
    return responseParser.parseResponse<IdealBalanceResponse>(
        response, (json) => IdealBalanceResponse.fromJson(json));
  }
}
