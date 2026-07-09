import 'package:komtim_partner/core/data/models/topup_qris_response.dart';
import 'package:komtim_partner/core/data/models/topup_response.dart';

import '../../apiservice/constat_endpoint.dart';
import '../../apiservice/dio_client.dart';
import '../../apiservice/dio_response_parser.dart';

abstract class TopUpRemoteDataSource {
  Future<TopupResponse> topUp(String nominal, int adminFee);
  Future<TopupQRISResponse> topUpQRIS(String nominal);
  Future<TopupDetailResponse> topUpDetail(int id);
  Future<bool> topUpCancel(int id);
  Future<TopupDetailResponse> topUpCeckTransaction(String typeCheckTrasaction);
}

class TopUpRemoteDataSourceImpl implements TopUpRemoteDataSource {
  final DioClient client;
  final DioResponseParser responseParser;

  TopUpRemoteDataSourceImpl(
      {required this.client, required this.responseParser});

  @override
  Future<TopupResponse> topUp(String nominal, int adminFee) async {
    // Define body
    int nominalConvert = int.parse(nominal);
    final data = {'topup_nominal': nominalConvert, "topup_admin_fee": adminFee};

    final response = await client.post(
      Endpoints.topUpBank,
      data: data,
    );

    return responseParser.parseResponse<TopupResponse>(
        response, (json) => TopupResponse.fromJson(json));
  }

  @override
  Future<TopupQRISResponse> topUpQRIS(String nominal) async {
    // Define body
    int nominalConvert = int.parse(nominal);
    final data = {'topup_nominal': nominalConvert};

    final response = await client.post(
      Endpoints.topUpQris,
      data: data,
    );

    return responseParser.parseResponse<TopupQRISResponse>(
        response, (json) => TopupQRISResponse.fromJson(json));
  }

  @override
  Future<bool> topUpCancel(int id) async {
    int trancationId = id;
    final data = {
      'transaction_id': trancationId,
    };

    final response = await client.post(
      Endpoints.cancelTopUp,
      data: data,
    );

    return responseParser.parseResponseMeta<bool>(response, (_) => true);
  }

  @override
  Future<TopupDetailResponse> topUpDetail(int id) async {
    int trancationId = id;
    final response = await client.get(
      '${Endpoints.topupDetail}/$trancationId/detail',
    );

    return responseParser.parseResponse<TopupDetailResponse>(
        response, (json) => TopupDetailResponse.fromJson(json));
  }

  @override
  Future<TopupDetailResponse> topUpCeckTransaction(
      String typeCheckTrasaction) async {
    final queryParams = {
      'type': typeCheckTrasaction,
    };

    final response = await client.get(
      Endpoints.topupCeckTransaction,
      queryParameters: queryParams,
    );

    return responseParser.parseResponse<TopupDetailResponse>(
        response, (json) => TopupDetailResponse.fromJson(json));
  }
}
