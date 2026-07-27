import 'dart:io' show Platform;

import '../../apiservice/constat_endpoint.dart';
import '../../apiservice/dio_client.dart';
import '../../apiservice/dio_response_parser.dart';
import '../../models/check_email_response.dart';
import '../../models/login_response.dart';

abstract class AuthRemoteDataSource {
  Future<CheckEmailResponse> checkEmailLogin(String email,
      {String? recaptchaToken});
  Future<LoginResponse> doLogin(String username, String password,
      {String? recaptchaToken});
  Future<bool> doLogout();
  Future<bool> sendForgotPassword(String email, {String? recaptchaToken});
  Future<bool> changePassword(
      String oldPass, String newPass, String confirmPass);
  Future<bool> resetPassword(String code, String password);
  Future<bool> resendVerification(String email, String productName);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient client;
  final DioResponseParser responseParser;

  AuthRemoteDataSourceImpl(
      {required this.client, required this.responseParser});

  @override
  Future<CheckEmailResponse> checkEmailLogin(String email,
      {String? recaptchaToken}) async {
    final response = await client.post(
      Endpoints.checkEmail,
      data: {
        'email': email,
        if (recaptchaToken != null) 'recaptcha_token': recaptchaToken,
        'device': Platform.isAndroid ? 'android' : 'ios'
      },
    );
    return responseParser.parseResponse<CheckEmailResponse>(
      response,
      (json) => CheckEmailResponse.fromJson(json),
    );
  }

  @override
  Future<bool> doLogout() async {
    final response = await client.get(Endpoints.logout);
    // Assuming parseResponse checks meta logic and throws if error
    return responseParser.parseResponse<bool>(response, (_) => true);
  }

  @override
  Future<LoginResponse> doLogin(String username, String password,
      {String? recaptchaToken}) async {
    final data = {
      'username_email': username,
      'password': password,
      if (recaptchaToken != null) 'recaptcha_token': recaptchaToken,
      'device': Platform.isAndroid ? 'android' : 'ios'
    };

    final response = await client.post(Endpoints.login, data: data);

    return responseParser.parseResponse<LoginResponse>(
        response, (json) => LoginResponse.fromJson(json));
  }

  @override
  Future<bool> sendForgotPassword(String email,
      {String? recaptchaToken}) async {
    final data = {
      'email': email,
      if (recaptchaToken != null) 'recaptcha_token': recaptchaToken,
      // 'device': Platform.isAndroid ? 'android' : 'ios'
    };

    final response = await client.post(Endpoints.forgotPassword, data: data);

    return responseParser.parseResponse<bool>(response, (_) => true);
  }

  @override
  Future<bool> changePassword(
      String oldPass, String newPass, String confirmPass) async {
    final data = {
      'old_password': oldPass,
      'new_password': newPass,
      'confirm_password': confirmPass
    };

    final response = await client.put(Endpoints.changePassword, data: data);

    return responseParser.parseResponse<bool>(response, (_) => true);
  }

  @override
  Future<bool> resetPassword(String code, String password) async {
    final data = {
      'code': code,
      'password': password,
    };

    final response = await client.post(Endpoints.resetPassword, data: data);

    return responseParser.parseResponse<bool>(response, (_) => true);
  }

  @override
  Future<bool> resendVerification(String email, String productName) async {
    final data = {
      'email': email,
      'product_name': productName,
    };
    final response =
        await client.post(Endpoints.resendVerification, data: data);
    return responseParser.parseResponse<bool>(response, (_) => true);
  }
}
