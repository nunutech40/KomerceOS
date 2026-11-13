import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komtim_partner/common/exception.dart';
import 'package:komtim_partner/core/data/apiservice/constat_endpoint.dart';
import 'package:komtim_partner/core/data/datasources/remote/auth_remote_datasource.dart';
import 'package:komtim_partner/core/data/models/check_email_response.dart';
import 'package:komtim_partner/core/data/models/login_response.dart';
import 'package:komtim_partner/core/data/models/partner_login_response.dart';
import 'package:komtim_partner/core/data/models/request_login_otp_response.dart';
import 'package:komtim_partner/core/data/models/two_fa_auth_exception.dart';
import 'package:komtim_partner/core/data/models/verify_login_otp_response.dart';
import 'package:komtim_partner/core/domain/entities/two_fa_failure.dart';
import 'package:mockito/mockito.dart';

import '../../../../helpers/helpers.dart';

// =============================================================================
// PANDUAN: Remote DataSource — 3 Path per Method
// =============================================================================
// Happy Path : DioClient + parseResponse sukses → return Model + cek field
// Error Path : parseResponse / DioClient throw → exception naik (re-throw)
// Edge Path  : Data null / parsing mismatch → throw error tepat
//
// WAJIB: Verifikasi EXACT endpoint + EXACT body request (bukan anyNamed)
// JANGAN: Test kode HTTP (404, 500) — itu urusan DioClient & Repository
// =============================================================================

void main() {
  late AuthRemoteDataSourceImpl dataSource;
  late MockDioClient mockClient;
  late MockDioResponseParser mockParser;

  setUp(() {
    mockClient = MockDioClient();
    mockParser = MockDioResponseParser();
    dataSource = AuthRemoteDataSourceImpl(
      client: mockClient,
      responseParser: mockParser,
    );
    provideDummy<LoginResponse>(const LoginResponse(
      accessToken: 'dummy',
      tokenType: 'dummy',
      data: null,
    ));
    provideDummy<CheckEmailResponse>(
      const CheckEmailResponse(allowedLogin: true),
    );
    provideDummy<PartnerLoginResponse>(
      const PartnerLoginResponse(),
    );
    provideDummy<RequestLoginOtpResponse>(
      const RequestLoginOtpResponse(),
    );
    provideDummy<VerifyLoginOtpResponse>(
      const VerifyLoginOtpResponse(),
    );
  });

  final tDioResponse = Response(
    requestOptions: RequestOptions(
        path: 'https://test.com', baseUrl: 'https://test.com'),
    data: {
      'meta': {'status': 'success', 'code': 200, 'message': 'OK'},
      'data': {}
    },
    statusCode: 200,
  );

  group('checkEmailLogin', () {
    const email = 'john@example.com';
    const recaptchaToken = 'recaptcha-test';

    test('mengirim identitas app dan token reCAPTCHA ke check-login', () async {
      when(mockClient.post(Endpoints.checkEmail, data: anyNamed('data')))
          .thenAnswer((_) async => tDioResponse);
      when(mockParser.parseResponse<CheckEmailResponse>(any, any))
          .thenReturn(const CheckEmailResponse(allowedLogin: true));

      final result = await dataSource.checkEmailLogin(
        email,
        recaptchaToken: recaptchaToken,
      );

      expect(result.allowedLogin, true);
      verify(mockClient.post(Endpoints.checkEmail, data: {
        'email': email,
        'app': 'komerceOS',
        'recaptcha_token': recaptchaToken,
        'device': Platform.isAndroid ? 'android' : 'ios',
      })).called(1);
    });
  });

  // ── doLogout ──────────────────────────────────────────────────────────────
  group('doLogout', () {
    // ----- HAPPY PATH -----
    test('return true saat API sukses', () async {
      when(mockClient.get(Endpoints.logout))
          .thenAnswer((_) async => tDioResponse);
      when(mockParser.parseResponse<bool>(any, any)).thenReturn(true);

      final result = await dataSource.doLogout();

      expect(result, true);
      verify(mockClient.get(Endpoints.logout)).called(1);
    });

    // ----- ERROR PATH -----
    test('throw Exception saat parseResponse gagal (meta error)', () async {
      when(mockClient.get(Endpoints.logout))
          .thenAnswer((_) async => tDioResponse);
      when(mockParser.parseResponse<bool>(any, any))
          .thenThrow(Exception('meta error'));

      expect(() => dataSource.doLogout(), throwsException);
    });

    test('throw DioException saat network error', () async {
      when(mockClient.get(Endpoints.logout)).thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.connectionTimeout,
      ));

      expect(() => dataSource.doLogout(), throwsA(isA<DioException>()));
    });

    // ----- EDGE PATH -----
    test('throw TypeError saat parseResponse gagal parsing (null response)',
        () async {
      when(mockClient.get(Endpoints.logout))
          .thenAnswer((_) async => tDioResponse);
      when(mockParser.parseResponse<bool>(any, any)).thenThrow(TypeError());

      expect(() => dataSource.doLogout(), throwsA(isA<TypeError>()));
    });
  });

  // ── doLogin ───────────────────────────────────────────────────────────────
  group('doLogin', () {
    const tUser = 'john_doe';
    const tPass = 'secret123';

    // Body login Superapp, termasuk identitas aplikasi untuk auth backend.
    final tBody = {
      'username_email': tUser,
      'password': tPass,
      'app': 'komerceOS',
      'device': Platform.isAndroid ? 'android' : 'ios',
    };

    const tLoginResponse = LoginResponse(
      accessToken: 'access_token_xyz',
      tokenType: 'Bearer',
      data: UserLoginData(
        id: 1,
        username: tUser,
        fullName: 'John Doe',
        email: 'john@example.com',
      ),
    );

    // ----- HAPPY PATH -----
    test('return LoginResponse dengan field benar dan body terkirim tepat',
        () async {
      when(mockClient.post(Endpoints.login, data: anyNamed('data')))
          .thenAnswer((_) async => tDioResponse);
      when(mockParser.parseResponse<LoginResponse>(any, any))
          .thenReturn(tLoginResponse);

      final result = await dataSource.doLogin(tUser, tPass);

      // Cek field spesifik — tidak hanya eq via Equatable
      expect(result.accessToken, 'access_token_xyz');
      expect(result.tokenType, 'Bearer');
      expect(result.data?.username, tUser);
      expect(result.data?.id, 1);
      // Verifikasi EXACT body yang dikirim ke server
      verify(mockClient.post(Endpoints.login, data: tBody)).called(1);
    });

    // ----- ERROR PATH -----
    test('throw Exception saat parseResponse gagal (credentials salah)',
        () async {
      when(mockClient.post(Endpoints.login, data: anyNamed('data')))
          .thenAnswer((_) async => tDioResponse);
      when(mockParser.parseResponse<LoginResponse>(any, any))
          .thenThrow(Exception('Invalid credentials'));

      expect(
        () => dataSource.doLogin(tUser, tPass),
        throwsException,
      );
    });

    test('throw DioException saat network error', () async {
      when(mockClient.post(Endpoints.login, data: anyNamed('data')))
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.connectionTimeout,
      ));

      expect(
        () => dataSource.doLogin(tUser, tPass),
        throwsA(isA<DioException>()),
      );
    });

    // ----- EDGE PATH -----
    test('throw TypeError saat data response null (parsing mismatch)', () async {
      when(mockClient.post(Endpoints.login, data: anyNamed('data')))
          .thenAnswer((_) async => tDioResponse);
      when(mockParser.parseResponse<LoginResponse>(any, any))
          .thenThrow(TypeError());

      expect(
        () => dataSource.doLogin(tUser, tPass),
        throwsA(isA<TypeError>()),
      );
    });
  });

  // ── sendForgotPassword ────────────────────────────────────────────────────
  group('sendForgotPassword', () {
    const tEmail = 'john@example.com';

    final tBody = {'email': tEmail};

    // ----- HAPPY PATH -----
    test('return true dan body terkirim tepat saat API sukses', () async {
      when(mockClient.post(Endpoints.forgotPassword, data: anyNamed('data')))
          .thenAnswer((_) async => tDioResponse);
      when(mockParser.parseResponse<bool>(any, any)).thenReturn(true);

      final result = await dataSource.sendForgotPassword(tEmail);

      expect(result, true);
      // Verifikasi EXACT endpoint + EXACT body
      verify(mockClient.post(Endpoints.forgotPassword, data: tBody)).called(1);
    });

    // ----- ERROR PATH -----
    test('throw Exception saat parseResponse gagal (email tidak terdaftar)',
        () async {
      when(mockClient.post(Endpoints.forgotPassword, data: anyNamed('data')))
          .thenAnswer((_) async => tDioResponse);
      when(mockParser.parseResponse<bool>(any, any))
          .thenThrow(Exception('Email not found'));

      expect(
        () => dataSource.sendForgotPassword(tEmail),
        throwsException,
      );
    });

    test('throw DioException saat network error', () async {
      when(mockClient.post(Endpoints.forgotPassword, data: anyNamed('data')))
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.connectionTimeout,
      ));

      expect(
        () => dataSource.sendForgotPassword(tEmail),
        throwsA(isA<DioException>()),
      );
    });

    // ----- EDGE PATH -----
    test('throw TypeError saat response tidak terduga (parsing mismatch)',
        () async {
      when(mockClient.post(Endpoints.forgotPassword, data: anyNamed('data')))
          .thenAnswer((_) async => tDioResponse);
      when(mockParser.parseResponse<bool>(any, any)).thenThrow(TypeError());

      expect(
        () => dataSource.sendForgotPassword(tEmail),
        throwsA(isA<TypeError>()),
      );
    });
  });

  // ── changePassword ────────────────────────────────────────────────────────
  group('changePassword', () {
    const tOld = 'oldPassword123';
    const tNew = 'newPassword456';
    const tConfirm = 'newPassword456';

    final tBody = {
      'old_password': tOld,
      'new_password': tNew,
      'confirm_password': tConfirm,
    };

    // ----- HAPPY PATH -----
    test('return true dan body terkirim tepat saat API sukses', () async {
      when(mockClient.put(Endpoints.changePassword, data: anyNamed('data')))
          .thenAnswer((_) async => tDioResponse);
      when(mockParser.parseResponse<bool>(any, any)).thenReturn(true);

      final result = await dataSource.changePassword(tOld, tNew, tConfirm);

      expect(result, true);
      verify(mockClient.put(Endpoints.changePassword, data: tBody)).called(1);
    });

    // ----- ERROR PATH -----
    test('throw Exception saat parseResponse gagal (validasi password gagal)',
        () async {
      when(mockClient.put(Endpoints.changePassword, data: anyNamed('data')))
          .thenAnswer((_) async => tDioResponse);
      when(mockParser.parseResponse<bool>(any, any))
          .thenThrow(Exception('Old password mismatch'));

      expect(
        () => dataSource.changePassword(tOld, tNew, tConfirm),
        throwsException,
      );
    });

    test('throw DioException saat network error', () async {
      when(mockClient.put(Endpoints.changePassword, data: anyNamed('data')))
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.connectionTimeout,
      ));

      expect(
        () => dataSource.changePassword(tOld, tNew, tConfirm),
        throwsA(isA<DioException>()),
      );
    });

    // ----- EDGE PATH -----
    test('throw TypeError saat response tidak terduga (parsing mismatch)',
        () async {
      when(mockClient.put(Endpoints.changePassword, data: anyNamed('data')))
          .thenAnswer((_) async => tDioResponse);
      when(mockParser.parseResponse<bool>(any, any)).thenThrow(TypeError());

      expect(
        () => dataSource.changePassword(tOld, tNew, tConfirm),
        throwsA(isA<TypeError>()),
      );
    });
  });

  // ── partnerLogin ──────────────────────────────────────────────────────────
  group('partnerLogin', () {
    const tUser = 'partner@example.com';
    const tPass = 'secret123';
    const tRecaptcha = 'recaptcha-login-token';

    final tExpectedBodyWithRecaptcha = {
      'username_email': tUser,
      'password': tPass,
      'recaptcha_token': tRecaptcha,
      'device': Platform.isAndroid ? 'android' : 'ios',
    };

    final tExpectedBodyWithoutRecaptcha = {
      'username_email': tUser,
      'password': tPass,
      'device': Platform.isAndroid ? 'android' : 'ios',
    };

    const tResponse = PartnerLoginResponse(
      token: 'login-token-abc',
      email: 'par***@example.com',
      phone: '*******0034',
      pendingOtp: PendingOtpResponse(
        token: 'otp-token-123',
        expiredAt: '2026-11-12T12:00:00Z',
        expiresIn: 60,
        typeToken: 'wa',
      ),
      otpLimitExceeded: false,
    );

    test(
        'return PartnerLoginResponse dan mengirim exact payload komship tanpa field app',
        () async {
      when(mockClient.post(Endpoints.partnerLogin, data: anyNamed('data')))
          .thenAnswer((_) async => tDioResponse);
      when(mockParser.parseResponse<PartnerLoginResponse>(any, any))
          .thenReturn(tResponse);

      final result = await dataSource.partnerLogin(
        tUser,
        tPass,
        recaptchaToken: tRecaptcha,
      );

      expect(result.token, 'login-token-abc');
      expect(result.email, 'par***@example.com');
      expect(result.phone, '*******0034');
      expect(result.pendingOtp?.token, 'otp-token-123');
      expect(result.pendingOtp?.typeToken, 'wa');
      expect(result.otpLimitExceeded, isFalse);

      final verification = verify(mockClient.post(
        Endpoints.partnerLogin,
        data: captureAnyNamed('data'),
      ));
      verification.called(1);
      final sentBody = verification.captured.single as Map<String, dynamic>;
      expect(sentBody, tExpectedBodyWithRecaptcha);
      expect(sentBody.containsKey('app'), isFalse);
    });

    test('tidak menyertakan recaptcha_token jika recaptchaToken null', () async {
      when(mockClient.post(Endpoints.partnerLogin, data: anyNamed('data')))
          .thenAnswer((_) async => tDioResponse);
      when(mockParser.parseResponse<PartnerLoginResponse>(any, any))
          .thenReturn(tResponse);

      await dataSource.partnerLogin(tUser, tPass);

      verify(mockClient.post(
        Endpoints.partnerLogin,
        data: tExpectedBodyWithoutRecaptcha,
      )).called(1);
    });

    test('throw PartnerLoginException saat HTTP 200 memuat meta error terstruktur',
        () async {
      final errorDioResponse = Response(
        requestOptions: RequestOptions(path: Endpoints.partnerLogin),
        statusCode: 200,
        data: {
          'meta': {
            'status': 'error',
            'code': 400,
            'message': 'Incorrect Password',
          },
          'data': {'login_attempt': 1, 'lock': 0},
        },
      );
      when(mockClient.post(Endpoints.partnerLogin, data: anyNamed('data')))
          .thenAnswer((_) async => errorDioResponse);
      when(mockParser.parseResponse<PartnerLoginResponse>(any, any))
          .thenThrow(Exception('Incorrect Password'));

      await expectLater(
        () => dataSource.partnerLogin(tUser, tPass),
        throwsA(
          isA<PartnerLoginException>()
              .having((e) => e.errorType, 'errorType',
                  PartnerLoginErrorType.incorrectPassword)
              .having((e) => e.loginAttempt, 'loginAttempt', 1)
              .having((e) => e.lock, 'lock', 0),
        ),
      );
    });

    test('tetap preserve ServerException (Team Internal) tanpa menimpanya',
        () async {
      final blockedResponse = Response(
        requestOptions: RequestOptions(path: Endpoints.partnerLogin),
        statusCode: 200,
        data: {
          'meta': {
            'status': 'error',
            'code': 'ERR_ROLE_TEAM_INTERNAL_BLOCKED',
            'message': 'Team internal diblokir',
          },
          'data': null,
        },
      );
      when(mockClient.post(Endpoints.partnerLogin, data: anyNamed('data')))
          .thenAnswer((_) async => blockedResponse);
      when(mockParser.parseResponse<PartnerLoginResponse>(any, any))
          .thenThrow(
        ServerException('ERR_ROLE_TEAM_INTERNAL_BLOCKED: Team internal diblokir'),
      );

      await expectLater(
        () => dataSource.partnerLogin(tUser, tPass),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            contains('ERR_ROLE_TEAM_INTERNAL_BLOCKED'),
          ),
        ),
      );
    });

    test('throw Exception asli saat parseResponse gagal pada response sukses',
        () async {
      when(mockClient.post(Endpoints.partnerLogin, data: anyNamed('data')))
          .thenAnswer((_) async => tDioResponse);
      when(mockParser.parseResponse<PartnerLoginResponse>(any, any))
          .thenThrow(Exception('meta error'));

      expect(
        () => dataSource.partnerLogin(tUser, tPass),
        throwsException,
      );
    });

    test('throw DioException saat network error', () async {
      when(mockClient.post(Endpoints.partnerLogin, data: anyNamed('data')))
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.connectionTimeout,
      ));

      expect(
        () => dataSource.partnerLogin(tUser, tPass),
        throwsA(isA<DioException>()),
      );
    });

    test('throw TypeError saat parsing mismatch pada data null', () async {
      when(mockClient.post(Endpoints.partnerLogin, data: anyNamed('data')))
          .thenAnswer((_) async => tDioResponse);
      when(mockParser.parseResponse<PartnerLoginResponse>(any, any))
          .thenThrow(TypeError());

      expect(
        () => dataSource.partnerLogin(tUser, tPass),
        throwsA(isA<TypeError>()),
      );
    });
  });

  // ── requestLoginOtp ───────────────────────────────────────────────────────
  group('requestLoginOtp', () {
    const tLoginToken = 'login-token-abc';
    const tMethod = 'sms';
    const tRecaptcha = 'recaptcha-otp-req';

    final tExpectedBody = {
      'token': tLoginToken,
      'type': tMethod,
      'recaptcha_token': tRecaptcha,
      'device': Platform.isAndroid ? 'android' : 'ios',
    };

    const tResponse = RequestLoginOtpResponse(
      token: 'otp-token-new',
      expiredAt: '2026-11-12T12:10:00Z',
      expiresIn: 60,
      email: 'par***@example.com',
      phone: '*******0034',
      otpLimitExceeded: false,
    );

    test(
        'return RequestLoginOtpResponse dan mengirim exact payload komship tanpa field app',
        () async {
      when(mockClient.post(Endpoints.requestLoginOtp, data: anyNamed('data')))
          .thenAnswer((_) async => tDioResponse);
      when(mockParser.parseResponse<RequestLoginOtpResponse>(any, any))
          .thenReturn(tResponse);

      final result = await dataSource.requestLoginOtp(
        tLoginToken,
        tMethod,
        recaptchaToken: tRecaptcha,
      );

      expect(result.token, 'otp-token-new');
      expect(result.expiresIn, 60);
      expect(result.phone, '*******0034');
      expect(result.otpLimitExceeded, isFalse);

      final verification = verify(mockClient.post(
        Endpoints.requestLoginOtp,
        data: captureAnyNamed('data'),
      ));
      verification.called(1);
      final sentBody = verification.captured.single as Map<String, dynamic>;
      expect(sentBody, tExpectedBody);
      expect(sentBody.containsKey('app'), isFalse);
    });

    test('throw Exception saat parseResponse gagal', () async {
      when(mockClient.post(Endpoints.requestLoginOtp, data: anyNamed('data')))
          .thenAnswer((_) async => tDioResponse);
      when(mockParser.parseResponse<RequestLoginOtpResponse>(any, any))
          .thenThrow(Exception('OTP limit exceeded'));

      expect(
        () => dataSource.requestLoginOtp(tLoginToken, tMethod),
        throwsException,
      );
    });

    test('throw DioException saat network error', () async {
      when(mockClient.post(Endpoints.requestLoginOtp, data: anyNamed('data')))
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.connectionTimeout,
      ));

      expect(
        () => dataSource.requestLoginOtp(tLoginToken, tMethod),
        throwsA(isA<DioException>()),
      );
    });

    test('throw TypeError saat parsing mismatch', () async {
      when(mockClient.post(Endpoints.requestLoginOtp, data: anyNamed('data')))
          .thenAnswer((_) async => tDioResponse);
      when(mockParser.parseResponse<RequestLoginOtpResponse>(any, any))
          .thenThrow(TypeError());

      expect(
        () => dataSource.requestLoginOtp(tLoginToken, tMethod),
        throwsA(isA<TypeError>()),
      );
    });
  });

  // ── verifyLoginOtp ────────────────────────────────────────────────────────
  group('verifyLoginOtp', () {
    const tOtpToken = 'otp-token-123';
    const tOtp = '123456';
    const tRecaptcha = 'recaptcha-otp-verify';

    final tExpectedBody = {
      'token': tOtpToken,
      'otp_value': tOtp,
      'recaptcha_token': tRecaptcha,
      'device': Platform.isAndroid ? 'android' : 'ios',
    };

    const tResponse = VerifyLoginOtpResponse(
      jwtToken: 'jwt-final-xyz',
      attemptLeft: null,
    );

    test(
        'return VerifyLoginOtpResponse dan mengirim exact payload komship tanpa field app',
        () async {
      when(mockClient.post(Endpoints.verifyLoginOtp, data: anyNamed('data')))
          .thenAnswer((_) async => tDioResponse);
      when(mockParser.parseResponse<VerifyLoginOtpResponse>(any, any))
          .thenReturn(tResponse);

      final result = await dataSource.verifyLoginOtp(
        tOtpToken,
        tOtp,
        recaptchaToken: tRecaptcha,
      );

      expect(result.jwtToken, 'jwt-final-xyz');
      expect(result.attemptLeft, isNull);

      final verification = verify(mockClient.post(
        Endpoints.verifyLoginOtp,
        data: captureAnyNamed('data'),
      ));
      verification.called(1);
      final sentBody = verification.captured.single as Map<String, dynamic>;
      expect(sentBody, tExpectedBody);
      expect(sentBody.containsKey('app'), isFalse);
    });

    test('throw VerifyOtpException saat HTTP 200 memuat meta error 422',
        () async {
      final errorDioResponse = Response(
        requestOptions: RequestOptions(path: Endpoints.verifyLoginOtp),
        statusCode: 200,
        data: {
          'meta': {
            'status': 'error',
            'code': 422,
            'message': 'OTP not valid',
          },
          'data': {'attempt_left': 2, 'lock': 0},
        },
      );
      when(mockClient.post(Endpoints.verifyLoginOtp, data: anyNamed('data')))
          .thenAnswer((_) async => errorDioResponse);
      when(mockParser.parseResponse<VerifyLoginOtpResponse>(any, any))
          .thenThrow(Exception('OTP not valid'));

      await expectLater(
        () => dataSource.verifyLoginOtp(tOtpToken, tOtp),
        throwsA(
          isA<VerifyOtpException>()
              .having((e) => e.errorType, 'errorType',
                  VerifyOtpErrorType.otpInvalid)
              .having((e) => e.attemptLeft, 'attemptLeft', 2)
              .having((e) => e.lock, 'lock', 0),
        ),
      );
    });

    test('throw Exception asli saat parseResponse gagal pada response sukses',
        () async {
      when(mockClient.post(Endpoints.verifyLoginOtp, data: anyNamed('data')))
          .thenAnswer((_) async => tDioResponse);
      when(mockParser.parseResponse<VerifyLoginOtpResponse>(any, any))
          .thenThrow(Exception('meta error'));

      expect(
        () => dataSource.verifyLoginOtp(tOtpToken, tOtp),
        throwsException,
      );
    });

    test('throw DioException saat network error', () async {
      when(mockClient.post(Endpoints.verifyLoginOtp, data: anyNamed('data')))
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.connectionTimeout,
      ));

      expect(
        () => dataSource.verifyLoginOtp(tOtpToken, tOtp),
        throwsA(isA<DioException>()),
      );
    });

    test('throw TypeError saat parsing mismatch', () async {
      when(mockClient.post(Endpoints.verifyLoginOtp, data: anyNamed('data')))
          .thenAnswer((_) async => tDioResponse);
      when(mockParser.parseResponse<VerifyLoginOtpResponse>(any, any))
          .thenThrow(TypeError());

      expect(
        () => dataSource.verifyLoginOtp(tOtpToken, tOtp),
        throwsA(isA<TypeError>()),
      );
    });
  });
}
