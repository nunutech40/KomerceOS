import 'dart:io';

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
  bool _logoutQueued = false;
  String? _invalidatedToken;

  AuthInterceptor({
    required this.tokenProvider,
    required this.authBloc,
    required this.globalAlertBloc,
  });

  static List<String> get _publicEndpoints => [
        Endpoints.login,
        Endpoints.refreshToken,
        Endpoints.forgotPassword,
        Endpoints.checkEmail,
        Endpoints.resendVerification,
        Endpoints.resetPassword,
      ];

  /// Interceptor method yang dipanggil sebelum request dikirim.
  /// Fungsi ini mengecek apakah endpoint bersifat publik atau privat.
  /// Jika private, maka akan menyisipkan token akses ke dalam header 'Authorization'.
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    if (!_isPublicEndpoint(options.path)) {
      final token = await tokenProvider.getAccessToken();
      if (token != null && token.isNotEmpty) {
        if (_logoutQueued && token != _invalidatedToken) {
          _logoutQueued = false;
          _invalidatedToken = null;
        }
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final responseBody = response.data;
    if (responseBody is Map<String, dynamic>) {
      final code = responseBody['code'];
      final meta = responseBody['meta'];
      final metaCode = (meta is Map<String, dynamic>) ? meta['code'] : null;

      if (code == 500 || metaCode == 500) {
        globalAlertBloc.add(ShowServerErrorEvent());
        return handler.reject(
          DioException(
            requestOptions: response.requestOptions,
            response: response,
            type: DioExceptionType.badResponse,
            error: Exception(responseBody['message'] ??
                (meta is Map ? meta['message'] : null) ??
                'Server Error'),
          ),
        );
      }
    }
    super.onResponse(response, handler);
  }

  /// BE menentukan kapan token expired/dicabut. FE mengakhiri sesi pada 401
  /// endpoint terproteksi; error jaringan dan 401 endpoint publik tidak logout.
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

    if (_isPublicEndpoint(err.requestOptions.path)) {
      return handler.next(err);
    }

    final requestAuthorization =
        err.requestOptions.headers['Authorization']?.toString();
    final requestToken = requestAuthorization?.startsWith('Bearer ') == true
        ? requestAuthorization!.substring('Bearer '.length)
        : null;
    String? currentToken;
    try {
      currentToken = await tokenProvider.getAccessToken();
    } catch (_) {
      // A rejected protected request with unreadable local credentials is
      // still an invalid session, not a reason to keep it authenticated.
    }
    // A response from an older request must not log out a new login session.
    if (requestToken != null &&
        currentToken != null &&
        currentToken.isNotEmpty &&
        requestToken != currentToken) {
      return handler.next(err);
    }
    _invalidatedToken = requestToken ?? currentToken;
    return _handleLogout(handler, err);
  }

  /// Menangani sesi tidak sah dari endpoint terproteksi.
  /// 1. Menghapus data di SharedPreferences.
  /// 2. Memperbarui status auth global agar GoRouter mengarahkan ke Login.
  /// 3. Me-reject request asli dengan error.
  Future<void> _handleLogout(
      ErrorInterceptorHandler handler, DioException err) async {
    if (!_logoutQueued) {
      _logoutQueued = true;
      authBloc.add(AuthLogoutRequested());
    }
    return handler.reject(err);
  }

  /// Helper untuk mengecek apakah URL tertentu adalah public endpoint
  /// (tidak memerlukan token Authorization).
  bool _isPublicEndpoint(String path) {
    return _publicEndpoints.contains(path);
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
