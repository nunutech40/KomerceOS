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
import 'package:komtim_partner/core/data/apiservice/constat_endpoint.dart';
import 'package:komtim_partner/core/data/apiservice/interceptors/auth_interceptor.dart';
import 'package:komtim_partner/core/data/apiservice/token_provider.dart';
import 'package:komtim_partner/common/global/bloc/auth/auth_bloc.dart';
import 'package:komtim_partner/common/global/bloc/global_alert/global_alert_bloc.dart';
import 'package:komtim_partner/common/global/bloc/global_alert/global_alert_event.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../../helpers/helpers.dart';
import 'auth_interceptor_server_error_test.mocks.dart';

// ---------------------------------------------------------------------------
// Mock ServerErrorService agar kita bisa verify showServerError() dipanggil
// ---------------------------------------------------------------------------
// Fake GlobalAlertBloc to intercept events
class FakeGlobalAlertBloc extends GlobalAlertBloc {
  bool serverErrorEventAdded = false;

  @override
  void add(GlobalAlertEvent event) {
    if (event is ShowServerErrorEvent) {
      serverErrorEventAdded = true;
    }
    super.add(event);
  }
}

// Fake AuthBloc
class FakeAuthBloc extends AuthBloc {
  FakeAuthBloc({required super.sharedPref});
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

class _FakeResponseInterceptorHandler extends ResponseInterceptorHandler {
  bool nextCalled = false;
  bool rejectCalled = false;
  DioException? rejectedError;

  @override
  void next(Response response) {
    nextCalled = true;
  }

  @override
  void reject(DioException err, [bool callFollowingErrorInterceptor = false]) {
    rejectCalled = true;
    rejectedError = err;
  }
}

@GenerateMocks([TokenProvider])
void main() {
  late MockTokenProvider mockTokenProvider;
  late FakeGlobalAlertBloc fakeGlobalAlertBloc;
  late _FakeErrorInterceptorHandler fakeHandler;
  late AuthInterceptor interceptor;

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
    mockTokenProvider = MockTokenProvider();
    fakeGlobalAlertBloc = FakeGlobalAlertBloc();
    fakeHandler = _FakeErrorInterceptorHandler();

    // Buat fake SharedPref manual agar FakeAuthBloc tidak error (kalau diperlukan)
    final fakeAuthBloc = AuthBloc(sharedPref: MockSharedPref());

    interceptor = AuthInterceptor(
      authBloc: fakeAuthBloc,
      globalAlertBloc: fakeGlobalAlertBloc,
      tokenProvider: mockTokenProvider,
    );
  });

  group('AuthInterceptor — Server Error 5xx', () {
    // ── 500 Internal Server Error ──────────────────────────────────────────
    test(
      'status 500: handler.next() dipanggil (error diteruskan ke repository)',
      () async {
        final err = makeDioException(500);

        await interceptor.onError(err, fakeHandler);

        expect(fakeHandler.nextCalled, true,
            reason: 'Error 500 harus diteruskan ke handler berikutnya');
      },
    );

    test(
      'status 500: GlobalAlertBloc menerima ShowServerErrorEvent',
      () async {
        await interceptor.onError(makeDioException(500), fakeHandler);

        expect(fakeGlobalAlertBloc.serverErrorEventAdded, true,
            reason: 'ShowServerErrorEvent harus dikirim untuk status 500');
      },
    );

    test(
      'status 503: GlobalAlertBloc menerima ShowServerErrorEvent',
      () async {
        await interceptor.onError(makeDioException(503), fakeHandler);

        expect(fakeGlobalAlertBloc.serverErrorEventAdded, true);
        expect(fakeHandler.nextCalled, true);
      },
    );

    test(
      'status 599: GlobalAlertBloc menerima ShowServerErrorEvent',
      () async {
        await interceptor.onError(makeDioException(599), fakeHandler);

        expect(fakeGlobalAlertBloc.serverErrorEventAdded, true);
        expect(fakeHandler.nextCalled, true);
      },
    );

    // ── Status non-5xx: ServerErrorService TIDAK dipanggil ────────────────
    test(
      'status 404: GlobalAlertBloc TIDAK menerima ShowServerErrorEvent',
      () async {
        await interceptor.onError(makeDioException(404), fakeHandler);

        expect(fakeGlobalAlertBloc.serverErrorEventAdded, false,
            reason: 'Event tidak boleh dikirim untuk 404');
        expect(fakeHandler.nextCalled, true);
      },
    );

    test(
      'status 422: GlobalAlertBloc TIDAK menerima ShowServerErrorEvent',
      () async {
        await interceptor.onError(makeDioException(422), fakeHandler);

        expect(fakeGlobalAlertBloc.serverErrorEventAdded, false);
      },
    );

    test(
      'onError 500 "user not found" di Endpoints.partnerLogin tidak memicu ShowServerErrorEvent',
      () async {
        for (final data in [
          {
            'meta': {'status': 'error', 'code': 500, 'message': 'user not found'}
          },
          {
            'meta': {'status': 'error', 'code': 500, 'message': ' User Not Found '}
          },
          {'message': 'user not found'},
        ]) {
          final alertBloc = FakeGlobalAlertBloc();
          final handler = _FakeErrorInterceptorHandler();
          final localInterceptor = AuthInterceptor(
            authBloc: AuthBloc(sharedPref: MockSharedPref()),
            globalAlertBloc: alertBloc,
            tokenProvider: mockTokenProvider,
          );
          final req = RequestOptions(path: Endpoints.partnerLogin);
          final err = DioException(
            requestOptions: req,
            type: DioExceptionType.badResponse,
            response: Response(
              requestOptions: req,
              statusCode: 500,
              data: data,
            ),
          );

          await localInterceptor.onError(err, handler);

          expect(alertBloc.serverErrorEventAdded, isFalse);
          expect(handler.nextCalled, isTrue);
        }
      },
    );

    test(
      'onError 500 message lain di Endpoints.partnerLogin tetap memicu ShowServerErrorEvent',
      () async {
        final req = RequestOptions(path: Endpoints.partnerLogin);
        final err = DioException(
          requestOptions: req,
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: req,
            statusCode: 500,
            data: {
              'meta': {
                'status': 'error',
                'code': 500,
                'message': 'Internal Server Error'
              }
            },
          ),
        );

        await interceptor.onError(err, fakeHandler);

        expect(fakeGlobalAlertBloc.serverErrorEventAdded, isTrue);
        expect(fakeHandler.nextCalled, isTrue);
      },
    );

    test(
      'onError 500 "user not found" di endpoint lain tetap memicu ShowServerErrorEvent',
      () async {
        final req = RequestOptions(path: Endpoints.checkEmail);
        final err = DioException(
          requestOptions: req,
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: req,
            statusCode: 500,
            data: {
              'meta': {
                'status': 'error',
                'code': 500,
                'message': 'user not found'
              }
            },
          ),
        );

        await interceptor.onError(err, fakeHandler);

        expect(fakeGlobalAlertBloc.serverErrorEventAdded, isTrue);
        expect(fakeHandler.nextCalled, isTrue);
      },
    );

    test(
      'onResponse HTTP 200 dengan meta.code 500 "user not found" di Endpoints.partnerLogin suppress ShowServerErrorEvent tapi tetap reject',
      () async {
        final req = RequestOptions(path: Endpoints.partnerLogin);
        final resHandler = _FakeResponseInterceptorHandler();
        final response = Response(
          requestOptions: req,
          statusCode: 200,
          data: {
            'meta': {
              'status': 'error',
              'code': 500,
              'message': 'user not found'
            },
          },
        );

        interceptor.onResponse(response, resHandler);

        expect(fakeGlobalAlertBloc.serverErrorEventAdded, isFalse);
        expect(resHandler.rejectCalled, isTrue);
      },
    );

    test(
      'onResponse HTTP 200 dengan meta.code 500 message lain di Endpoints.partnerLogin tetap memicu ShowServerErrorEvent dan reject',
      () async {
        final req = RequestOptions(path: Endpoints.partnerLogin);
        final resHandler = _FakeResponseInterceptorHandler();
        final response = Response(
          requestOptions: req,
          statusCode: 200,
          data: {
            'meta': {
              'status': 'error',
              'code': 500,
              'message': 'Database error'
            },
          },
        );

        interceptor.onResponse(response, resHandler);

        expect(fakeGlobalAlertBloc.serverErrorEventAdded, isTrue);
        expect(resHandler.rejectCalled, isTrue);
      },
    );
  });
}

// Removed _TestableAuthInterceptor and mock implementations
