import 'package:komtim_partner/core/data/models/check_pin_response.dart';
import 'package:komtim_partner/core/data/models/forget_pin_response.dart';
import 'package:komtim_partner/core/data/models/verify_pin_response.dart';

import '../../apiservice/constat_endpoint.dart';
import '../../apiservice/dio_client.dart';
import '../../apiservice/dio_response_parser.dart';

abstract class PinRemoteDataSource {
  Future<CheckPinResponse> checkPin();
  Future<VerifyPinResponse> verifyPin(String pin);
  Future<bool> savePin(String pin);
  Future<ForgetPinResponse> forgetPin();
  Future<VerifyPinResponse> verifyOtp(String otp);
}

class PinRemoteDataSourceImpl implements PinRemoteDataSource {
  final DioClient client;
  final DioResponseParser responseParser;

  PinRemoteDataSourceImpl({required this.client, required this.responseParser});

  @override
  Future<CheckPinResponse> checkPin() async {
    final response = await client.get(Endpoints.checkPinExisting);
    return responseParser.parseResponse<CheckPinResponse>(
        response, (json) => CheckPinResponse.fromJson(json));
  }

  @override
  Future<VerifyPinResponse> verifyPin(String pin) async {
    final data = {
      'pin': pin,
    };

    final response = await client.post(
      Endpoints.verifyPin,
      data: data,
    );
    return responseParser.parseResponse<VerifyPinResponse>(
        response, (json) => VerifyPinResponse.fromJson(json));
  }

  @override
  Future<bool> savePin(String pin) async {
    final data = {
      'pin': pin,
    };

    final response = await client.post(
      Endpoints.savePin,
      data: data,
    );

    return responseParser.parseResponseMeta<bool>(response, (_) => true);
  }

  @override
  Future<ForgetPinResponse> forgetPin() async {
    final response = await client.get(
      Endpoints.forgetPin,
    );

    return responseParser.parseResponse<ForgetPinResponse>(
        response, (json) => ForgetPinResponse.fromJson(json));
  }

  @override
  Future<VerifyPinResponse> verifyOtp(String otp) async {
    final data = {
      'otp': otp,
    };

    final response = await client.post(
      Endpoints.verifyOtp,
      data: data,
    );

    return responseParser.parseResponse<VerifyPinResponse>(
        response, (json) => VerifyPinResponse.fromJson(json));
  }
}
