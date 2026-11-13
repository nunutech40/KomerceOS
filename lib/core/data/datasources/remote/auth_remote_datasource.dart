import 'dart:io' show Platform;

import '../../../../common/exception.dart';
import '../../apiservice/constat_endpoint.dart';
import '../../apiservice/dio_client.dart';
import '../../apiservice/dio_response_parser.dart';
import '../../models/check_email_response.dart';
import '../../models/login_response.dart';
import '../../models/partner_login_response.dart';
import '../../models/request_login_otp_response.dart';
import '../../models/two_fa_auth_exception.dart';
import '../../models/verify_login_otp_response.dart';

abstract class AuthRemoteDataSource {
  Future<CheckEmailResponse> checkEmailLogin(String email,
      {String? recaptchaToken});

  /// [LEGACY] Endpoint login lama sebelum flow 2FA OTP partner.
  Future<LoginResponse> doLogin(String username, String password,
      {String? recaptchaToken});

  Future<PartnerLoginResponse> partnerLogin(
    String username,
    String password, {
    String? recaptchaToken,
  });

  Future<RequestLoginOtpResponse> requestLoginOtp(
    String loginToken,
    String method, {
    String? recaptchaToken,
  });

  Future<VerifyLoginOtpResponse> verifyLoginOtp(
    String otpToken,
    String otp, {
    String? recaptchaToken,
  });

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
        'app': 'komerceOS',
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

  /// [LEGACY] Endpoint login lama sebelum flow 2FA OTP partner.
  @override
  Future<LoginResponse> doLogin(String username, String password,
      {String? recaptchaToken}) async {
    final data = {
      'username_email': username,
      'password': password,
      'app': 'komerceOS',
      if (recaptchaToken != null) 'recaptcha_token': recaptchaToken,
      'device': Platform.isAndroid ? 'android' : 'ios'
    };

    final response = await client.post(Endpoints.login, data: data);

    return responseParser.parseResponse<LoginResponse>(
        response, (json) => LoginResponse.fromJson(json));
  }

  @override
  Future<PartnerLoginResponse> partnerLogin(
    String username,
    String password, {
    String? recaptchaToken,
  }) async {
    final data = <String, dynamic>{
      'username_email': username,
      'password': password,
      if (recaptchaToken != null) 'recaptcha_token': recaptchaToken,
      'device': Platform.isAndroid ? 'android' : 'ios',
    };

    final response = await client.post(Endpoints.partnerLogin, data: data);
    try {
      return responseParser.parseResponse<PartnerLoginResponse>(
        response,
        (json) => PartnerLoginResponse.fromJson(json),
      );
    } catch (e) {
      if (e is! ServerException && _isNonSuccessResponseData(response.data)) {
        final typedException = tryParsePartnerLoginException(
          response.statusCode,
          response.data,
        );
        if (typedException != null) {
          throw typedException;
        }
      }
      rethrow;
    }
  }

  @override
  Future<RequestLoginOtpResponse> requestLoginOtp(
    String loginToken,
    String method, {
    String? recaptchaToken,
  }) async {
    final data = <String, dynamic>{
      'token': loginToken,
      'type': method,
      if (recaptchaToken != null) 'recaptcha_token': recaptchaToken,
      'device': Platform.isAndroid ? 'android' : 'ios',
    };

    final response = await client.post(Endpoints.requestLoginOtp, data: data);
    return responseParser.parseResponse<RequestLoginOtpResponse>(
      response,
      (json) => RequestLoginOtpResponse.fromJson(json),
    );
  }

  @override
  Future<VerifyLoginOtpResponse> verifyLoginOtp(
    String otpToken,
    String otp, {
    String? recaptchaToken,
  }) async {
    final data = <String, dynamic>{
      'token': otpToken,
      'otp_value': otp,
      if (recaptchaToken != null) 'recaptcha_token': recaptchaToken,
      'device': Platform.isAndroid ? 'android' : 'ios',
    };

    final response = await client.post(Endpoints.verifyLoginOtp, data: data);
    try {
      return responseParser.parseResponse<VerifyLoginOtpResponse>(
        response,
        (json) => VerifyLoginOtpResponse.fromJson(json),
      );
    } catch (e) {
      if (e is! ServerException && _isNonSuccessResponseData(response.data)) {
        final typedException = tryParseVerifyOtpException(
          response.statusCode,
          response.data,
        );
        if (typedException != null) {
          throw typedException;
        }
      }
      rethrow;
    }
  }

  bool _isNonSuccessResponseData(dynamic responseData) {
    if (responseData is! Map) return false;
    final meta = responseData['meta'];
    if (meta is Map) {
      final metaStatus = meta['status']?.toString().toLowerCase();
      return metaStatus != 'success';
    }
    if (responseData.containsKey('status')) {
      final status = responseData['status'];
      if (status is bool) return !status;
      return status?.toString().toLowerCase() != 'success';
    }
    return false;
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
