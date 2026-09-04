import 'dart:convert';

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
  Future<ForgetPinResponse> forgetPin({String? purpose});
  Future<VerifyPinResponse> verifyOtp(String otp, {String? token});
  Future<bool> updatePinSecured(String pin, String token);
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
      Endpoints.securedVerifyPin,
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
  Future<ForgetPinResponse> forgetPin({String? purpose}) async {
    final response = await client.post(
      Endpoints.otpRequestEmail,
      data: {
        'purpose': purpose ?? 'pin',
      },
    );

    return responseParser.parseResponse<ForgetPinResponse>(
        response, (json) => ForgetPinResponse.fromJson(json));
  }

  @override
  Future<VerifyPinResponse> verifyOtp(String otp, {String? token}) async {
    final String? securedToken = (token != null && token.isNotEmpty)
        ? base64Encode(utf8.encode('$token%pin'))
        : token;

    final data = {
      'otp': otp,
      'token': securedToken,
    };

    final response = await client.post(
      Endpoints.otpVerify,
      data: data,
    );

    return responseParser.parseResponse<VerifyPinResponse>(
        response, (json) => VerifyPinResponse.fromOtpJson(json));
  }

  @override
  Future<bool> updatePinSecured(String pin, String token) async {
    final String securedToken =
        token.isNotEmpty ? base64Encode(utf8.encode('$token%pin')) : token;

    final data = {
      'new_pin': pin,
      'token': securedToken,
    };

    final response = await client.post(
      Endpoints.securedUpdatePin,
      data: data,
    );

    return responseParser.parseResponseMeta<bool>(response, (_) => true);
  }
}
