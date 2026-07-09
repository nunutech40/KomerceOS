import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komtim_partner/core/data/apiservice/constat_endpoint.dart';
import 'package:komtim_partner/core/data/datasources/remote/auth_remote_datasource.dart';
import 'package:komtim_partner/core/data/models/login_response.dart';
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

    // Body sesuai API baru: username_email + password + device
    final tBody = {
      'username_email': tUser,
      'password': tPass,
      'device': 'android',
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
}
