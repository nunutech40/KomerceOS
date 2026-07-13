import 'dart:async';
import 'dart:io';

import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:dio/dio.dart';
import 'package:komtim_partner/core/data/apiservice/constat_endpoint.dart';
import 'package:komtim_partner/core/data/apiservice/token_provider.dart';
import 'package:komtim_partner/common/global/bloc/auth/auth_bloc.dart';
import 'package:komtim_partner/common/global/bloc/auth/auth_event.dart';
import 'package:komtim_partner/common/global/bloc/global_alert/global_alert_bloc.dart';
import 'package:komtim_partner/common/global/bloc/global_alert/global_alert_event.dart';

class AuthInterceptor extends QueuedInterceptorsWrapper {
  final TokenProvider tokenProvider;
  final AuthBloc authBloc;
  final GlobalAlertBloc globalAlertBloc;
  Dio? _dio;
  bool _isRefreshing = false;
  Completer<String?>? _refreshCompleter;

  AuthInterceptor({
    required this.tokenProvider,
    required this.authBloc,
    required this.globalAlertBloc,
  });

  static List<String> get _publicEndpoints => [
        Endpoints.login,
        Endpoints.refreshToken,
        Endpoints.forgotPassword,
      ];

  static List<String> get _skipRefreshEndpoints => [
        ..._publicEndpoints,
        Endpoints.changePassword,
      ];

  /// Mengatur instance Dio yang digunakan untuk melakukan request ulang (retry).
  /// [dio] Instance Dio utama aplikasi.
  void setDio(Dio dio) {
    _dio = dio;
  }

  /// Interceptor method yang dipanggil sebelum request dikirim.
  /// Fungsi ini mengecek apakah endpoint bersifat publik atau privat.
  /// Jika private, maka akan menyisipkan token akses ke dalam header 'Authorization'.
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    if (!_isPublicEndpoint(options.path)) {
      if (_isRefreshing) {
        final refreshedToken = await _refreshCompleter?.future;
        if (refreshedToken != null) {
          options.headers['Authorization'] = 'Bearer $refreshedToken';
        }
      } else {
        final token = await tokenProvider.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
      }
    }
    super.onRequest(options, handler);
  }

  /// Interceptor method yang menangani error response.
  /// Fokus utama adalah menangani error 401 (Unauthorized).
  ///
  /// Flow penanganan:
  /// 1. Cek apakah error disebabkan oleh masalah jaringan → forward tanpa logout.
  /// 2. Cek apakah status code 401.
  /// 3. Jika 401 dari endpoint refresh token, maka logout (sesi habis total).
  /// 4. Jika 401 dari endpoint biasa, coba lakukan refresh token.
  /// 5. Gunakan `QueuedInterceptorsWrapper` (ini class parent) untuk mencegah race condition.
  /// 6. Menggunakan instance Dio baru (`refreshDio`) untuk call endpoint refresh token agara tidak terjadi deadlock interceptor.
  /// 7. Jika refresh berhasil => simpan token baru => retry request yang gagal tadi.
  /// 8. Jika refresh gagal karena network error → forward error tanpa logout.
  /// 9. Jika refresh gagal karena token invalid (server menolak) → logout.
  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    // -----------------------------------------------------------------------
    // Guard: Jika error disebabkan oleh masalah jaringan (no internet,
    // timeout, connection refused), JANGAN logout — cukup forward error.
    // Ini mencegah user ter-redirect ke login saat HP sleep / no internet.
    // -----------------------------------------------------------------------
    if (_isNetworkError(err)) {
      return handler.next(err);
    }

    final statusCode = err.response?.statusCode ?? 0;

    // Intercept server errors (5xx) — tampilkan global Server Error bottom sheet
    if (statusCode >= 500) {
      globalAlertBloc.add(ShowServerErrorEvent());
      return handler.next(err);
    }

    if (statusCode != 401) {
      return handler.next(err);
    }

    // Public endpoints and selected auth endpoints should report their own 401
    // instead of starting refresh-token logic.
    if (_shouldSkipRefresh(err.requestOptions.path)) {
      return handler.next(err);
    }

    if (_isRefreshing) {
      final refreshedToken = await _refreshCompleter?.future;
      if (refreshedToken != null) {
        return _retryWithToken(err.requestOptions, handler, refreshedToken);
      }
      return handler.next(err);
    }

    // TEMPORARY: Refresh token logic dinonaktifkan karena endpoint login saat ini
    // tidak me-return refresh_token. Langsung kembalikan error dan logout.
    /*
    _isRefreshing = true;
    _refreshCompleter = Completer<String?>();
    try {
      final refreshToken = await tokenProvider.getRefreshToken();
      if (refreshToken == null) {
        _refreshCompleter?.complete(null);
        _resetRefreshLock();
        return _handleLogout(handler, err);
      }

      // Check if we already have a new token compared to the one in the failed request
      final requestToken = err.requestOptions.headers['Authorization']
          ?.toString()
          .split(' ')
          .last;
      final currentToken = await tokenProvider.getAccessToken();

      if (currentToken != null && requestToken != currentToken) {
        // Token was updated by another request, retry with new token
        _refreshCompleter?.complete(currentToken);
        _resetRefreshLock();
        return _retryWithToken(err.requestOptions, handler, currentToken);
      }

      final refreshDio = Dio();
      // Add Chucker interceptor to monitor refresh token calls
      refreshDio.interceptors.add(ChuckerDioInterceptor());

      // Copy base options if needed, but Endpoints.refreshToken is absolute.
      refreshDio.options.headers['Content-Type'] = 'application/json';

      final response = await refreshDio.put(
        Endpoints.refreshToken,
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final userData = data['data'] ?? data;

        // Baca token langsung dari JSON — endpoint refresh bisa punya format berbeda
        final accessToken = userData['access_token'] as String?;
        final newRefreshToken = userData['refresh_token'] as String?;

        if (accessToken == null || newRefreshToken == null) {
          _refreshCompleter?.complete(null);
          _resetRefreshLock();
          return _handleLogout(handler, err);
        }

        await tokenProvider.saveTokens(
          accessToken: accessToken,
          refreshToken: newRefreshToken,
        );

        _refreshCompleter?.complete(accessToken);
        _resetRefreshLock();
        return _retryWithToken(err.requestOptions, handler, accessToken);
      }

      _refreshCompleter?.complete(null);
      _resetRefreshLock();
      return _handleLogout(handler, err);
    } on DioException catch (refreshErr) {
      // Jika refresh token gagal karena NETWORK error, jangan logout.
      // User masih punya token valid — hanya saja koneksinya putus.
      _refreshCompleter?.complete(null);
      _resetRefreshLock();
      if (_isNetworkError(refreshErr)) {
        return handler.next(err);
      }
      return _handleLogout(handler, err);
    } catch (e) {
      // Error non-Dio (misal SocketException langsung) — kemungkinan besar
      // juga masalah jaringan, jangan logout.
      _refreshCompleter?.complete(null);
      _resetRefreshLock();
      if (e is SocketException) {
        return handler.next(err);
      }
      return _handleLogout(handler, err);
    }
    */
    
    return _handleLogout(handler, err);
  }

  /// Menangani proses logout jika refresh token gagal atau expired.
  /// 1. Menghapus data di SharedPreferences.
  /// 2. Memperbarui status auth global agar GoRouter mengarahkan ke Login.
  /// 3. Me-reject request asli dengan error.
  Future<void> _handleLogout(
      ErrorInterceptorHandler handler, DioException err) async {
    authBloc.add(AuthLogoutRequested());
    return handler.reject(err);
  }

  /// Melakukan retry (request ulang) terhadap request yang gagal sebelumnya
  /// dengan menggunakan token baru yang sudah diperbarui.
  Future<void> _retryWithToken(RequestOptions requestOptions,
      ErrorInterceptorHandler handler, String accessToken) async {
    final opts = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );

    opts.headers?['Authorization'] = 'Bearer $accessToken';

    try {
      final cloneReq = await _dio!.request(
        requestOptions.path,
        options: opts,
        data: requestOptions.data,
        queryParameters: requestOptions.queryParameters,
      );
      return handler.resolve(cloneReq);
    } catch (e) {
      if (e is DioException) {
        return handler.reject(e);
      }
      return handler
          .reject(DioException(requestOptions: requestOptions, error: e));
    }
  }

  /// Helper untuk mengecek apakah URL tertentu adalah public endpoint
  /// (tidak memerlukan token Authorization).
  bool _isPublicEndpoint(String path) {
    return _publicEndpoints.any(path.contains);
  }

  bool _shouldSkipRefresh(String path) {
    return _skipRefreshEndpoints.any(path.contains);
  }

  void _resetRefreshLock() {
    _isRefreshing = false;
    _refreshCompleter = null;
  }

  /// Mengecek apakah [DioException] disebabkan oleh masalah jaringan
  /// (no internet, timeout, connection refused) — BUKAN error dari server.
  /// Digunakan agar app tidak salah logout ketika koneksi terputus.
  bool _isNetworkError(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.connectionError:
        return true;
      case DioExceptionType.unknown:
        // SocketException biasanya dibungkus dalam DioExceptionType.unknown
        return err.error is SocketException;
      default:
        return false;
    }
  }
}
