import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komtim_partner/common/global/bloc/auth/auth_bloc.dart';
import 'package:komtim_partner/common/global/bloc/global_alert/global_alert_bloc.dart';
import 'package:komtim_partner/core/data/apiservice/constat_endpoint.dart';
import 'package:komtim_partner/core/data/apiservice/interceptors/auth_interceptor.dart';
import 'package:mockito/mockito.dart';

import '../../../../helpers/helpers.dart';
import 'auth_interceptor_server_error_test.mocks.dart';

class _ErrorHandler extends ErrorInterceptorHandler {
  bool rejected = false;
  bool forwarded = false;

  @override
  void reject(DioException err, [bool callFollowingErrorInterceptor = false]) {
    rejected = true;
  }

  @override
  void next(DioException err) {
    forwarded = true;
  }
}

DioException _error(String path, int status,
    {String? requestToken,
    DioExceptionType type = DioExceptionType.badResponse}) {
  final request = RequestOptions(path: path, headers: {
    if (requestToken != null) 'Authorization': 'Bearer $requestToken',
  });
  return DioException(
    requestOptions: request,
    response: Response(requestOptions: request, statusCode: status),
    type: type,
  );
}

void main() {
  late MockTokenProvider tokens;
  late MockSharedPref prefs;
  late AuthBloc auth;
  late GlobalAlertBloc alerts;
  late AuthInterceptor interceptor;

  setUp(() {
    tokens = MockTokenProvider();
    prefs = MockSharedPref();
    when(tokens.getAccessToken()).thenAnswer((_) async => 'active');
    when(prefs.removeDataPref()).thenAnswer((_) async {});
    auth = AuthBloc(sharedPref: prefs);
    alerts = GlobalAlertBloc();
    interceptor = AuthInterceptor(
        tokenProvider: tokens, authBloc: auth, globalAlertBloc: alerts);
  });

  tearDown(() async {
    await auth.close();
    await alerts.close();
  });

  test('401 API terproteksi menghapus sesi lokal dan masuk status logout',
      () async {
    final handler = _ErrorHandler();
    final unauthenticated = auth.stream
        .firstWhere((state) => state.status.name == 'unauthenticated');
    await interceptor.onError(
        _error(Endpoints.securedVerifyPin, 401, requestToken: 'active'),
        handler);
    await unauthenticated;
    expect(handler.rejected, isTrue);
    verify(prefs.removeDataPref()).called(1);
  });

  test('401 tanpa header token tetap mengakhiri sesi yang tersimpan', () async {
    final handler = _ErrorHandler();
    final unauthenticated = auth.stream
        .firstWhere((state) => state.status.name == 'unauthenticated');
    await interceptor.onError(_error(Endpoints.securedVerifyPin, 401), handler);
    await unauthenticated;
    expect(handler.rejected, isTrue);
    verify(prefs.removeDataPref()).called(1);
  });

  test('dua respons 401 serentak hanya memicu satu logout', () async {
    final first = _ErrorHandler();
    final second = _ErrorHandler();
    await Future.wait([
      interceptor.onError(
          _error(Endpoints.securedVerifyPin, 401, requestToken: 'active'),
          first),
      interceptor.onError(
          _error(Endpoints.pinAttemptLeft, 401, requestToken: 'active'),
          second),
    ]);
    await auth.stream
        .firstWhere((state) => state.status.name == 'unauthenticated');
    expect(first.rejected && second.rejected, isTrue);
    verify(prefs.removeDataPref()).called(1);
  });

  test('401 pada endpoint publik tidak mengeluarkan pengguna', () async {
    for (final path in [
      Endpoints.login,
      Endpoints.checkEmail,
      Endpoints.forgotPassword,
      Endpoints.resetPassword,
      Endpoints.resendVerification,
    ]) {
      final handler = _ErrorHandler();
      await interceptor.onError(_error(path, 401), handler);
      expect(handler.forwarded, isTrue);
    }
    verifyNever(prefs.removeDataPref());
  });

  test('401 ubah password bukan endpoint publik', () async {
    final handler = _ErrorHandler();
    await interceptor.onError(
        _error(Endpoints.changePassword, 401, requestToken: 'active'), handler);
    await auth.stream
        .firstWhere((state) => state.status.name == 'unauthenticated');
    expect(handler.rejected, isTrue);
    verify(prefs.removeDataPref()).called(1);
  });

  test('error jaringan dan 403 tidak menghapus sesi', () async {
    final network = _ErrorHandler();
    await interceptor.onError(
        _error(Endpoints.securedVerifyPin, 0,
            requestToken: 'active', type: DioExceptionType.connectionError),
        network);
    final forbidden = _ErrorHandler();
    await interceptor.onError(
        _error(Endpoints.securedVerifyPin, 403, requestToken: 'active'),
        forbidden);
    expect(network.forwarded && forbidden.forwarded, isTrue);
    verifyNever(prefs.removeDataPref());
  });

  test('401 request dengan token lama tidak menghapus sesi baru', () async {
    final handler = _ErrorHandler();
    await interceptor.onError(
        _error(Endpoints.securedVerifyPin, 401, requestToken: 'previous'),
        handler);
    expect(handler.forwarded, isTrue);
    verifyNever(prefs.removeDataPref());
  });
}
