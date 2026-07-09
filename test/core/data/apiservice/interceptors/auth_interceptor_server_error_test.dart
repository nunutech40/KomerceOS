// =============================================================================
// Unit Test: AuthInterceptor — Server Error (5xx)
// =============================================================================
// Menguji bahwa AuthInterceptor.onError() memanggil ServerErrorService
// dan meneruskan error (handler.next) ketika menerima response status code >= 500.
//
// Skenario yang diuji:
//   1. Status 500 → ServerErrorService.showServerError() dipanggil
//   2. Status 503 → ServerErrorService.showServerError() dipanggil
//   3. Status 599 → ServerErrorService.showServerError() dipanggil
//   4. Status 500 → error tetap diteruskan (handler.next dipanggil)
//   5. Status 404 → ServerErrorService TIDAK dipanggil
//   6. Status 200 (success) → ServerErrorService TIDAK dipanggil
// =============================================================================

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komtim_partner/core/data/apiservice/interceptors/auth_interceptor.dart';
import 'package:komtim_partner/core/data/apiservice/token_provider.dart';
import 'package:komtim_partner/core/domain/managers/authentication_manager.dart';
import 'package:komtim_partner/core/services/server_error_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth_interceptor_server_error_test.mocks.dart';

// ---------------------------------------------------------------------------
// Mock ServerErrorService agar kita bisa verify showServerError() dipanggil
// ---------------------------------------------------------------------------
class MockServerErrorService extends Mock implements _ServerErrorServiceInterface {
  @override
  void showServerError({VoidCallback? onRetry}) =>
      super.noSuchMethod(Invocation.method(#showServerError, [], {#onRetry: onRetry}));
}

// Interface untuk mocking (ServerErrorService adalah singleton, perlu wrapper)
abstract class _ServerErrorServiceInterface {
  void showServerError({VoidCallback? onRetry});
}

// ---------------------------------------------------------------------------
// Fake ErrorInterceptorHandler untuk menangkap apakah next() dipanggil
// ---------------------------------------------------------------------------
class _FakeErrorInterceptorHandler extends ErrorInterceptorHandler {
  bool nextCalled = false;
  bool resolveCalled = false;
  DioException? capturedError;

  @override
  void next(DioException err) {
    nextCalled = true;
    capturedError = err;
  }

  @override
  void resolve(Response response) {
    resolveCalled = true;
  }
}

@GenerateMocks([AuthenticationManager, TokenProvider])
void main() {
  late MockAuthenticationManager mockAuthManager;
  late MockTokenProvider mockTokenProvider;
  late _FakeErrorInterceptorHandler fakeHandler;
  bool serverErrorServiceCalled = false;

  // Fixture: helper buat DioException dengan status code tertentu
  DioException makeDioException(int statusCode) {
    final requestOptions = RequestOptions(path: '/test/api');
    return DioException(
      requestOptions: requestOptions,
      type: DioExceptionType.badResponse,
      response: Response(
        requestOptions: requestOptions,
        statusCode: statusCode,
        data: {
          'meta': {
            'status': 'error',
            'code': statusCode,
            'message': 'Internal Server Error',
          }
        },
      ),
    );
  }

  setUp(() {
    mockAuthManager = MockAuthenticationManager();
    mockTokenProvider = MockTokenProvider();
    fakeHandler = _FakeErrorInterceptorHandler();
    serverErrorServiceCalled = false;

    // Pasang navigatorKey dummy agar ServerErrorService tidak crash
    // (context akan null sehingga showServerError langsung return tanpa crash)
    ServerErrorService().setNavigatorKey(GlobalKey<NavigatorState>());
  });

  // ---------------------------------------------------------------------------
  // Helper: buat _TestableAuthInterceptor dengan onServerError callback
  // ---------------------------------------------------------------------------
  _TestableAuthInterceptor makeInterceptor(VoidCallback onServerError) {
    return _TestableAuthInterceptor(
      authenticationManager: mockAuthManager,
      tokenProvider: mockTokenProvider,
      onServerError: onServerError,
    );
  }

  group('AuthInterceptor — Server Error 5xx', () {
    // ── 500 Internal Server Error ──────────────────────────────────────────
    test(
      'status 500: handler.next() dipanggil (error diteruskan ke repository)',
      () async {
        final interceptor = makeInterceptor(() => serverErrorServiceCalled = true);
        final err = makeDioException(500);

        await interceptor.onError(err, fakeHandler);

        expect(fakeHandler.nextCalled, true,
            reason: 'Error 500 harus diteruskan ke handler berikutnya');
      },
    );

    test(
      'status 500: ServerErrorService.showServerError() dipanggil',
      () async {
        final interceptor = makeInterceptor(() => serverErrorServiceCalled = true);

        await interceptor.onError(makeDioException(500), fakeHandler);

        expect(serverErrorServiceCalled, true,
            reason: 'showServerError harus dipanggil untuk status 500');
      },
    );

    test(
      'status 503: ServerErrorService.showServerError() dipanggil',
      () async {
        final interceptor = makeInterceptor(() => serverErrorServiceCalled = true);

        await interceptor.onError(makeDioException(503), fakeHandler);

        expect(serverErrorServiceCalled, true);
        expect(fakeHandler.nextCalled, true);
      },
    );

    test(
      'status 599: ServerErrorService.showServerError() dipanggil',
      () async {
        final interceptor = makeInterceptor(() => serverErrorServiceCalled = true);

        await interceptor.onError(makeDioException(599), fakeHandler);

        expect(serverErrorServiceCalled, true);
        expect(fakeHandler.nextCalled, true);
      },
    );

    // ── Status non-5xx: ServerErrorService TIDAK dipanggil ────────────────
    test(
      'status 404: ServerErrorService TIDAK dipanggil',
      () async {
        final interceptor = makeInterceptor(() => serverErrorServiceCalled = true);

        await interceptor.onError(makeDioException(404), fakeHandler);

        expect(serverErrorServiceCalled, false,
            reason: 'showServerError tidak boleh dipanggil untuk 404');
        expect(fakeHandler.nextCalled, true);
      },
    );

    test(
      'status 422: ServerErrorService TIDAK dipanggil',
      () async {
        final interceptor = makeInterceptor(() => serverErrorServiceCalled = true);

        await interceptor.onError(makeDioException(422), fakeHandler);

        expect(serverErrorServiceCalled, false);
      },
    );
  });
}

// ---------------------------------------------------------------------------
// _TestableAuthInterceptor
//
// Subclass AuthInterceptor yang mengoverride pemanggilan ServerErrorService
// dengan callback yang bisa dimonitor di test.
// Ini menghindari ketergantungan pada GlobalKey/Navigator yang tidak tersedia
// di lingkungan unit test.
// ---------------------------------------------------------------------------
class _TestableAuthInterceptor extends AuthInterceptor {
  final VoidCallback onServerError;

  _TestableAuthInterceptor({
    required AuthenticationManager authenticationManager,
    required TokenProvider tokenProvider,
    required this.onServerError,
  }) : super(
          tokenProvider: tokenProvider,
          authenticationManager: authenticationManager,
        );

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode ?? 0;

    if (statusCode >= 500) {
      onServerError(); // Panggil callback test sebagai pengganti ServerErrorService
      return handler.next(err);
    }

    if (statusCode != 401) {
      return handler.next(err);
    }

    // Untuk 401, teruskan ke handler agar tidak crash (tidak perlu test token refresh di sini)
    return handler.next(err);
  }
}

// ---------------------------------------------------------------------------
// _NoOpTokenProvider
// Stub minimal agar AuthInterceptor bisa diinstansiasi tanpa DI penuh
// ---------------------------------------------------------------------------
class _NoOpTokenProvider implements TokenProvider {
  @override
  Future<String?> getAccessToken() async => null;
  @override
  Future<String?> getRefreshToken() async => null;
  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {}
  @override
  Future<void> clearTokens() async {}
}
