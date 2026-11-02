import 'dart:io';

import 'package:dio/dio.dart';

import 'package:komtim_partner/config/chucker_config.dart';
import '../datasources/preferences/shared_pref.dart';
import 'constat_endpoint.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/safe_chucker_interceptor.dart';

class DioClient {
  final SharedPref sharedPref;
  final AuthInterceptor authInterceptor;
  late final Dio _dio;

  DioClient({
    required this.sharedPref,
    required this.authInterceptor,
  }) {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(authInterceptor);
    if (ChuckerConfig.enabled) {
      _dio.interceptors.add(SafeChuckerInterceptor());
    }
  }

  Dio get dio => _dio;

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    Future<Response> request() => _dio.get(
          path,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
          onReceiveProgress: onReceiveProgress,
        );
    try {
      return await request();
    } on DioException catch (error) {
      if (!_canRetryRead(path, error) || cancelToken?.isCancelled == true) {
        rethrow;
      }
      final authorization = error.requestOptions.headers['Authorization'];
      if (!await _sameSession(authorization)) rethrow;
      await Future<void>.delayed(const Duration(milliseconds: 300));
      if (cancelToken?.isCancelled == true) throw cancelToken!.cancelError!;
      if (!await _sameSession(authorization)) rethrow;
      // A single retry covers transient socket failures while online. Never
      // replay mutations such as logout, OTP requests, PIN verification or add.
      return request();
    }
  }

  bool _canRetryRead(String path, DioException error) {
    if (error.response != null) return false;
    final transient = error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        (error.type == DioExceptionType.unknown &&
            (error.error is SocketException || error.error is HttpException));
    if (!transient) return false;
    return path == Endpoints.superappGetProfile ||
        path == Endpoints.checkPinExisting ||
        path == Endpoints.checkPinSetting ||
        path == Endpoints.pinAttemptLeft ||
        path == Endpoints.komshipBankAccounts ||
        path == Endpoints.komshipAvailableBanks ||
        Uri.tryParse(path)?.path == '/api/v1/dashboard/partner/balanceSummary';
  }

  Future<bool> _sameSession(dynamic authorization) async {
    if (authorization is! String || !authorization.startsWith('Bearer ')) {
      return false;
    }
    try {
      final token = await authInterceptor.tokenProvider.getAccessToken();
      return token != null &&
          token.isNotEmpty &&
          authorization == 'Bearer $token';
    } catch (_) {
      return false;
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return _dio.patch(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }
}
