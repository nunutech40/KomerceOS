import '../../models/create_qrcode_response.dart';
import '../../apiservice/constat_endpoint.dart';
import '../../apiservice/dio_client.dart';
import '../../apiservice/dio_response_parser.dart';

abstract class CreateQrcodeRemoteDataSource {
  Future<CreateQrcodeResponse> createQrcode({
    required String channelPay,
    required String description,
    required int amount,
    required int duration,
  });
}

class CreateQrcodeRemoteDataSourceImpl implements CreateQrcodeRemoteDataSource {
  final DioClient client;
  final DioResponseParser responseParser;

  CreateQrcodeRemoteDataSourceImpl({
    required this.client,
    required this.responseParser,
  });

  @override
  Future<CreateQrcodeResponse> createQrcode({
    required String channelPay,
    required String description,
    required int amount,
    required int duration,
  }) async {
    final data = {
      "channel_pay": channelPay,
      "description": description,
      "amount": amount,
      "duration": duration,
    };

    final response = await client.post(
      Endpoints.createQrcode,
      data: data,
    );

    return responseParser.parseResponse<CreateQrcodeResponse>(
      response,
      (json) => CreateQrcodeResponse.fromJson(json),
    );
  }
}
