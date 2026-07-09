import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komtim_partner/common/exception.dart';
import 'package:komtim_partner/common/failure.dart';
import 'package:komtim_partner/core/data/models/login_response.dart';
import 'package:komtim_partner/core/data/repositories/auth_repository_impl.dart';
import 'package:komtim_partner/core/domain/entities/login_model.dart';
import 'package:mockito/mockito.dart';

import '../../../helpers/helpers.dart';

// =============================================================================
// PANDUAN: Repository — Sang Orkestrator 
// =============================================================================
// 1. Orkestrasi (Happy) : Remote OK → Local Save OK → Right(Entity)
// 2. Error Path         : Remote Error → tangkap → ubah jadi Left(Failure), zero interactions local
// 3. Cache Fallback     : (Bila ada skenario fallback app)
// 4. Clean Up Safety    : Remote Error Timeout → Local Clear TETAP JALAN pada saat doLogout()
// =============================================================================

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemote;
  late MockSharedPref mockSharedPref;

  setUp(() {
    mockRemote = MockAuthRemoteDataSource();
    mockSharedPref = MockSharedPref();
    repository = AuthRepositoryImpl(
      remoteDataSource: mockRemote,
      sharedPref: mockSharedPref,
    );
    provideDummy<LoginResponse>(const LoginResponse(
      accessToken: '',
      tokenType: '',
      data: null,
    ));
    when(mockSharedPref.saveUserAndToken(any)).thenAnswer((_) async {});
    when(mockSharedPref.removeDataPref()).thenAnswer((_) async {});
  });

  // ─── Test Fixtures ───────────────────────────────────────────────────────────

  const tUserLoginData = UserLoginData(
    id: 1,
    username: 'john_doe',
    fullName: 'John Doe',
    email: 'john@example.com',
  );

  const tLoginResponse = LoginResponse(
    accessToken: 'access_token_abc',
    tokenType: 'Bearer',
    data: tUserLoginData,
  );

  final tLoginEntity = LoginModel(
    accessToken: 'access_token_abc',
    tokenType: 'Bearer',
    data: UserLoginModel(
      id: 1,
      username: 'john_doe',
      fullName: 'John Doe',
      email: 'john@example.com',
    ),
  );

  const tUsername = 'john_doe';
  const tPassword = 'secret123';
  const tEmail = 'john@example.com';
  const tOldPass = 'oldPass';
  const tNewPass = 'newPass';
  const tConfirmPass = 'newPass';

  // ─── getAuthState ─────────────────────────────────────────────────────────

  group('getAuthState', () {
    // ----- a. HAPPY PATH -----
    test('harus return Right(true) saat membaca local sukses dan user terautentikasi', () async {
      when(mockSharedPref.isLoggedIn()).thenAnswer((_) async => true);

      final result = await repository.getAuthState();

      expect(result, const Right(true));
      verify(mockSharedPref.isLoggedIn()).called(1);
      verifyNoMoreInteractions(mockSharedPref);
    });

    // ----- a. HAPPY PATH (Not logged in) -----
    test('harus return Right(false) saat user belum/tidak terautentikasi', () async {
      when(mockSharedPref.isLoggedIn()).thenAnswer((_) async => false);

      final result = await repository.getAuthState();

      expect(result, const Right(false));
      verify(mockSharedPref.isLoggedIn()).called(1);
    });

    // ----- b. ERROR PATH -----
    test('harus return Left(UnknownFailure) saat isLoggedIn() throw Exception (di tangkap BaseRepository)', () async {
      when(mockSharedPref.isLoggedIn()).thenThrow(Exception('pref error'));

      final result = await repository.getAuthState();

      expect(result.isLeft(), isTrue);
      result.fold((l) => expect(l, isA<UnknownFailure>()), (_) => null);
      verify(mockSharedPref.isLoggedIn()).called(1);
    });
  });

  // ─── doLogin ──────────────────────────────────────────────────────────────

  group('doLogin', () {
    // ----- a. HAPPY PATH (Orkestrasi) -----
    test('harus memanggil Remote dan Local Save (Orkestrasi) lalu return Right(LoginModel) saat sukses', () async {
      when(mockRemote.doLogin(tUsername, tPassword))
          .thenAnswer((_) async => tLoginResponse);
      when(mockSharedPref.saveUserAndToken(any)).thenAnswer((_) async {});

      final result = await repository.doLogin(tUsername, tPassword);

      expect(result, Right(tLoginEntity));
      
      // Orkestrasi terverifikasi : Hit API -> Simpan Respons Lokal
      verify(mockRemote.doLogin(tUsername, tPassword)).called(1);
      // EDGE / EXACT Check: Pastikan data yang disimpan lokal sesuai dengan object dari remote!
      verify(mockSharedPref.saveUserAndToken(tLoginResponse)).called(1);
    });

    // ----- b. ERROR PATH (Data Pelit / Zero Interactions local save) -----
    test('harus return Left(ServerFailure) dan BATAL save ke lokal saat Server Exception', () async {
      when(mockRemote.doLogin(tUsername, tPassword))
          .thenThrow(ServerException('Wrong Password'));

      final result = await repository.doLogin(tUsername, tPassword);

      expect(result, const Left(ServerFailure('Wrong Password')));
      verify(mockRemote.doLogin(tUsername, tPassword)).called(1);
      
      verifyNever(mockSharedPref.saveUserAndToken(any));
    });

    test('harus return Left(ConnectionFailure) dan BATAL save ke lokal saat remote throw DioException Timeout', () async {
      when(mockRemote.doLogin(tUsername, tPassword)).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.connectionTimeout,
        ),
      );

      final result = await repository.doLogin(tUsername, tPassword);

      expect(result.isLeft(), isTrue);
      result.fold((l) => expect(l, isA<ConnectionFailure>().having((e) => e.message, 'message', 'Request timeout')), (_) => null);
      verifyNever(mockSharedPref.saveUserAndToken(any));
    });

    // ----- b. ERROR PATH EXTREME -----
    test('harus return Left(ServerFailure) dan meng-extract message dari badResponse 401 Body', () async {
      when(mockRemote.doLogin(tUsername, tPassword)).thenThrow(
        DioException(
            requestOptions: RequestOptions(path: ''),
            type: DioExceptionType.badResponse,
            response: Response(
                requestOptions: RequestOptions(path: ''),
                statusCode: 401,
                data: {'meta': {'message': 'Unauthorized', 'code': 401}},
            ),
        ),
      );

      final result = await repository.doLogin(tUsername, tPassword);

      expect(result, const Left(ServerFailure('Unauthorized')));
      verifyNever(mockSharedPref.saveUserAndToken(any));
    });
  });

  // ─── doLogout ─────────────────────────────────────────────────────────────

  group('doLogout', () {
    // ----- a. HAPPY PATH -----
    test('harus memanggil remote logout lalu menghapus data local (removeDataPref) saat remote return true', () async {
      when(mockRemote.doLogout()).thenAnswer((_) async => true);
      when(mockSharedPref.removeDataPref()).thenAnswer((_) async {});

      final result = await repository.doLogout();

      expect(result, const Right(true));
      verify(mockRemote.doLogout()).called(1);
      verify(mockSharedPref.removeDataPref()).called(1);
    });

    // ----- EDGE PATH — removeDataPref TIDAK dipanggil saat remote return false -----
    test('TIDAK memanggil removeDataPref saat remote return false (logout ditolak server)', () async {
      when(mockRemote.doLogout()).thenAnswer((_) async => false);

      final result = await repository.doLogout();

      expect(result, const Right(false));
      // Implementasi: if (result) { sharedPref.removeDataPref() } — jika false, tidak dipanggil
      verifyNever(mockSharedPref.removeDataPref());
    });

    // ----- c. EDGE PATH (CLEAN UP SAFETY) -----
    // ⚠️ BUG TERDETEKSI via TEST: Jika implementasi tidak sesuai standard,
    // test ini akan MERAH! Ini adalah laporan bahwa Clean Up Safety absen.
    test('AMANKAN LOGOUT LOKAL (Clean Up Safety): Harus TETAP menghapus data local storage meskipun remote API error atau timeout', () async {
      when(mockRemote.doLogout()).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.connectionTimeout,
        ),
      );

      final result = await repository.doLogout();

      expect(result.isLeft(), isTrue);
      result.fold((l) => expect(l, isA<ConnectionFailure>()), (_) => null);
      // EKSPEKTASI RULE KITA KETAT: Logout gagal di sisi server, aplikasi lokal harus tetap bersih.
      verify(mockSharedPref.removeDataPref()).called(1);
    });
  });

  // ─── sendForgotPass ───────────────────────────────────────────────────────

  group('sendForgotPass', () {
    // ----- a. HAPPY PATH -----
    test('harus return Right(true) saat API sendForgotPass sukses membalas', () async {
      when(mockRemote.sendForgotPassword(tEmail)).thenAnswer((_) async => true);

      final result = await repository.sendForgotPass(tEmail);

      expect(result, const Right(true));
      verify(mockRemote.sendForgotPassword(tEmail)).called(1);
    });

    // ----- b. ERROR PATH -----
    test('harus return Left(ConnectionFailure) saat remote API throw SocketException', () async {
      when(mockRemote.sendForgotPassword(tEmail)).thenThrow(const SocketException('No Internet'));

      final result = await repository.sendForgotPass(tEmail);

      expect(result.isLeft(), isTrue);
      result.fold((l) => expect(l, isA<ConnectionFailure>()), (_) => null);
    });

    // ----- c. EDGE PATH -----
    test('harus mereturn Left(ServerFailure) dengan custom message ketika badResponse error dari backend', () async {
      when(mockRemote.sendForgotPassword(tEmail)).thenThrow(
        DioException(
            requestOptions: RequestOptions(path: ''),
            type: DioExceptionType.badResponse,
            response: Response(
                requestOptions: RequestOptions(path: ''),
                statusCode: 404,
                data: {'meta': {'message': 'Email tidak terdaftar', 'code': 404}},
            ),
        ),
      );

      final result = await repository.sendForgotPass(tEmail);

      expect(result, const Left(ServerFailure('Email tidak terdaftar')));
    });
  });

  // ─── changePassword ───────────────────────────────────────────────────────

  group('changePassword', () {
    // ----- a. HAPPY PATH -----
    test('harus return Right(true) saat API changePassword berhasil di-update tanpa kendala', () async {
      when(mockRemote.changePassword(tOldPass, tNewPass, tConfirmPass))
          .thenAnswer((_) async => true);

      final result = await repository.changePassword(tOldPass, tNewPass, tConfirmPass);

      expect(result, const Right(true));
      verify(mockRemote.changePassword(tOldPass, tNewPass, tConfirmPass)).called(1);
    });

    // ----- b. ERROR PATH -----
    test('harus mereturn Left(ServerFailure) yang mengekstrak message validasi bila password gagal di approve server', () async {
      when(mockRemote.changePassword(tOldPass, tNewPass, tConfirmPass))
          .thenThrow(ServerException('Password baru terlalu lemah'));

      final result = await repository.changePassword(tOldPass, tNewPass, tConfirmPass);

      expect(result, const Left(ServerFailure('Password baru terlalu lemah')));
    });

    // ----- c. EDGE PATH -----
    test('harus mereturn Left(ConnectionFailure) jika timeout koneksi server saat ubah password', () async {
      when(mockRemote.changePassword(tOldPass, tNewPass, tConfirmPass))
          .thenThrow(DioException(
            requestOptions: RequestOptions(path: ''),
            type: DioExceptionType.connectionTimeout,
          ));

      final result = await repository.changePassword(tOldPass, tNewPass, tConfirmPass);

      expect(result.isLeft(), isTrue);
      result.fold((l) => expect(l, isA<ConnectionFailure>()), (_) => null);
    });
  });
}
