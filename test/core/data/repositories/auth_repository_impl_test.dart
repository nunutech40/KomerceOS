import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komtim_partner/common/exception.dart';
import 'package:komtim_partner/common/failure.dart';
import 'package:komtim_partner/core/data/models/login_response.dart';
import 'package:komtim_partner/core/data/models/partner_login_response.dart';
import 'package:komtim_partner/core/data/models/profile_response.dart';
import 'package:komtim_partner/core/data/models/request_login_otp_response.dart';
import 'package:komtim_partner/core/data/models/two_fa_auth_exception.dart';
import 'package:komtim_partner/core/data/models/verify_login_otp_response.dart';
import 'package:komtim_partner/core/data/repositories/auth_repository_impl.dart';
import 'package:komtim_partner/core/domain/entities/login_model.dart';
import 'package:komtim_partner/core/domain/entities/partner_login_model.dart';
import 'package:komtim_partner/core/domain/entities/request_login_otp_model.dart';
import 'package:komtim_partner/core/domain/entities/superapp_profile_model.dart';
import 'package:komtim_partner/core/domain/entities/two_fa_failure.dart';
import 'package:komtim_partner/core/domain/entities/verify_login_otp_model.dart';
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
  late MockSecureStorageService mockSecureStorage;
  late MockSuperappProfileRepository mockProfileRepo;

  setUp(() {
    mockRemote = MockAuthRemoteDataSource();
    mockSharedPref = MockSharedPref();
    mockSecureStorage = MockSecureStorageService();
    mockProfileRepo = MockSuperappProfileRepository();
    repository = AuthRepositoryImpl(
      remoteDataSource: mockRemote,
      sharedPref: mockSharedPref,
      superappProfileRepository: mockProfileRepo,
    );
    provideDummy<LoginResponse>(const LoginResponse(
      accessToken: '',
      tokenType: '',
      data: null,
    ));
    provideDummy<PartnerLoginResponse>(const PartnerLoginResponse());
    provideDummy<RequestLoginOtpResponse>(const RequestLoginOtpResponse());
    provideDummy<VerifyLoginOtpResponse>(const VerifyLoginOtpResponse());
    provideDummy<Either<Failure, SuperappProfileModel>>(
      const Right(SuperappProfileModel()),
    );
    when(mockSharedPref.secureStorage).thenReturn(mockSecureStorage);
    when(mockSecureStorage.saveAccessToken(any)).thenAnswer((_) async {});
    when(mockSecureStorage.deleteTokens()).thenAnswer((_) async {});
    when(mockSharedPref.saveUserAndToken(any)).thenAnswer((_) async {});
    when(mockSharedPref.saveProfileData(any)).thenAnswer((_) async {});
    when(mockSharedPref.removeDataPref()).thenAnswer((_) async {});
    when(mockProfileRepo.clearCache()).thenAnswer((_) async {});
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

  const tLoginEntity = LoginModel(
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
    test(
        'harus return Right(true) saat membaca local sukses dan user terautentikasi',
        () async {
      when(mockSharedPref.isLoggedIn()).thenAnswer((_) async => true);

      final result = await repository.getAuthState();

      expect(result, const Right(true));
      verify(mockSharedPref.isLoggedIn()).called(1);
      verifyNoMoreInteractions(mockSharedPref);
    });

    // ----- a. HAPPY PATH (Not logged in) -----
    test('harus return Right(false) saat user belum/tidak terautentikasi',
        () async {
      when(mockSharedPref.isLoggedIn()).thenAnswer((_) async => false);

      final result = await repository.getAuthState();

      expect(result, const Right(false));
      verify(mockSharedPref.isLoggedIn()).called(1);
    });

    // ----- b. ERROR PATH -----
    test(
        'harus return Left(UnknownFailure) saat isLoggedIn() throw Exception (di tangkap BaseRepository)',
        () async {
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
    test(
        'harus memanggil Remote dan Local Save (Orkestrasi) lalu return Right(LoginModel) saat sukses',
        () async {
      when(mockRemote.doLogin(tUsername, tPassword))
          .thenAnswer((_) async => tLoginResponse);
      when(mockSharedPref.saveUserAndToken(any)).thenAnswer((_) async {});

      final result = await repository.doLogin(tUsername, tPassword);

      expect(result, const Right(tLoginEntity));

      // Orkestrasi terverifikasi : Hit API -> Simpan Respons Lokal
      verify(mockRemote.doLogin(tUsername, tPassword)).called(1);
      // EDGE / EXACT Check: Pastikan data yang disimpan lokal sesuai dengan object dari remote!
      verify(mockSharedPref.saveUserAndToken(tLoginResponse)).called(1);
    });

    // ----- b. ERROR PATH (Data Pelit / Zero Interactions local save) -----
    test(
        'harus return Left(ServerFailure) dan BATAL save ke lokal saat Server Exception',
        () async {
      when(mockRemote.doLogin(tUsername, tPassword))
          .thenThrow(ServerException('Wrong Password'));

      final result = await repository.doLogin(tUsername, tPassword);

      expect(result, const Left(ServerFailure('Wrong Password')));
      verify(mockRemote.doLogin(tUsername, tPassword)).called(1);

      verifyNever(mockSharedPref.saveUserAndToken(any));
    });

    test('respons login tanpa access token tidak menyimpan sesi', () async {
      when(mockRemote.doLogin(tUsername, tPassword)).thenAnswer((_) async =>
          const LoginResponse(
              accessToken: '', tokenType: 'Bearer', data: tUserLoginData));

      final result = await repository.doLogin(tUsername, tPassword);

      expect(
          result,
          const Left(
              ServerFailure('Respons login tidak memuat sesi yang valid')));
      verifyNever(mockSharedPref.saveUserAndToken(any));
    });

    test(
        'harus return Left(ConnectionFailure) dan BATAL save ke lokal saat remote throw DioException Timeout',
        () async {
      when(mockRemote.doLogin(tUsername, tPassword)).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.connectionTimeout,
        ),
      );

      final result = await repository.doLogin(tUsername, tPassword);

      expect(result.isLeft(), isTrue);
      result.fold(
          (l) => expect(
              l,
              isA<ConnectionFailure>()
                  .having((e) => e.message, 'message', 'Request timeout')),
          (_) => null);
      verifyNever(mockSharedPref.saveUserAndToken(any));
    });

    // ----- b. ERROR PATH EXTREME -----
    test(
        'harus return Left(ServerFailure) dan meng-extract message dari badResponse 401 Body',
        () async {
      when(mockRemote.doLogin(tUsername, tPassword)).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 401,
            data: {
              'meta': {'message': 'Unauthorized', 'code': 401}
            },
          ),
        ),
      );

      final result = await repository.doLogin(tUsername, tPassword);

      expect(result, const Left(ServerFailure('Unauthorized')));
      verifyNever(mockSharedPref.saveUserAndToken(any));
    });

    test('meneruskan error code Team Internal dan tidak menyimpan sesi',
        () async {
      when(mockRemote.doLogin(tUsername, tPassword)).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 403,
            data: {
              'meta': {
                'code': 'ERR_ROLE_TEAM_INTERNAL_BLOCKED',
                'message':
                    'Akun Anda tidak memiliki akses untuk masuk ke aplikasi.',
              },
            },
          ),
        ),
      );

      final result = await repository.doLogin(tUsername, tPassword);

      expect(
        result,
        const Left(ServerFailure(
          'ERR_ROLE_TEAM_INTERNAL_BLOCKED: '
          'Akun Anda tidak memiliki akses untuk masuk ke aplikasi.',
        )),
      );
      verifyNever(mockSharedPref.saveUserAndToken(any));
    });

    test('meneruskan error_code Team Internal dari body flat HTTP 403',
        () async {
      when(mockRemote.doLogin(tUsername, tPassword)).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 403,
            data: {
              'status': false,
              'error_code': 'ERR_ROLE_TEAM_INTERNAL_BLOCKED',
              'message':
                  'Akun Anda tidak memiliki akses untuk masuk ke aplikasi.',
              'data': null,
            },
          ),
        ),
      );

      final result = await repository.doLogin(tUsername, tPassword);

      expect(
        result,
        const Left(ServerFailure(
          'ERR_ROLE_TEAM_INTERNAL_BLOCKED: '
          'Akun Anda tidak memiliki akses untuk masuk ke aplikasi.',
        )),
      );
      verifyNever(mockSharedPref.saveUserAndToken(any));
    });
  });

  // ─── doLogout ─────────────────────────────────────────────────────────────

  group('doLogout', () {
    // ----- a. HAPPY PATH -----
    test(
        'harus memanggil remote logout lalu menghapus data local (removeDataPref) saat remote return true',
        () async {
      when(mockRemote.doLogout()).thenAnswer((_) async => true);
      when(mockSharedPref.removeDataPref()).thenAnswer((_) async {});

      final result = await repository.doLogout();

      expect(result, const Right(true));
      verify(mockRemote.doLogout()).called(1);
      verify(mockSharedPref.removeDataPref()).called(1);
    });

    // ----- EDGE PATH — removeDataPref TIDAK dipanggil saat remote return false -----
    test(
        'TIDAK memanggil removeDataPref saat remote return false (logout ditolak server)',
        () async {
      when(mockRemote.doLogout()).thenAnswer((_) async => false);

      final result = await repository.doLogout();

      expect(result, const Right(false));
      // Implementasi: if (result) { sharedPref.removeDataPref() } — jika false, tidak dipanggil
      verifyNever(mockSharedPref.removeDataPref());
    });

    // ----- c. EDGE PATH (CLEAN UP SAFETY) -----
    // ⚠️ BUG TERDETEKSI via TEST: Jika implementasi tidak sesuai standard,
    // test ini akan MERAH! Ini adalah laporan bahwa Clean Up Safety absen.
    test(
        'AMANKAN LOGOUT LOKAL (Clean Up Safety): Harus TETAP menghapus data local storage meskipun remote API error atau timeout',
        () async {
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
    test('harus return Right(true) saat API sendForgotPass sukses membalas',
        () async {
      when(mockRemote.sendForgotPassword(tEmail)).thenAnswer((_) async => true);

      final result = await repository.sendForgotPass(tEmail);

      expect(result, const Right(true));
      verify(mockRemote.sendForgotPassword(tEmail)).called(1);
    });

    // ----- b. ERROR PATH -----
    test(
        'harus return Left(ConnectionFailure) saat remote API throw SocketException',
        () async {
      when(mockRemote.sendForgotPassword(tEmail))
          .thenThrow(const SocketException('No Internet'));

      final result = await repository.sendForgotPass(tEmail);

      expect(result.isLeft(), isTrue);
      result.fold((l) => expect(l, isA<ConnectionFailure>()), (_) => null);
    });

    // ----- c. EDGE PATH -----
    test(
        'harus mereturn Left(ServerFailure) dengan custom message ketika badResponse error dari backend',
        () async {
      when(mockRemote.sendForgotPassword(tEmail)).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 404,
            data: {
              'meta': {'message': 'Email tidak terdaftar', 'code': 404}
            },
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
    test(
        'harus return Right(true) saat API changePassword berhasil di-update tanpa kendala',
        () async {
      when(mockRemote.changePassword(tOldPass, tNewPass, tConfirmPass))
          .thenAnswer((_) async => true);

      final result =
          await repository.changePassword(tOldPass, tNewPass, tConfirmPass);

      expect(result, const Right(true));
      verify(mockRemote.changePassword(tOldPass, tNewPass, tConfirmPass))
          .called(1);
    });

    // ----- b. ERROR PATH -----
    test(
        'harus mereturn Left(ServerFailure) yang mengekstrak message validasi bila password gagal di approve server',
        () async {
      when(mockRemote.changePassword(tOldPass, tNewPass, tConfirmPass))
          .thenThrow(ServerException('Password baru terlalu lemah'));

      final result =
          await repository.changePassword(tOldPass, tNewPass, tConfirmPass);

      expect(result, const Left(ServerFailure('Password baru terlalu lemah')));
    });

    // ----- c. EDGE PATH -----
    test(
        'harus mereturn Left(ConnectionFailure) jika timeout koneksi server saat ubah password',
        () async {
      when(mockRemote.changePassword(tOldPass, tNewPass, tConfirmPass))
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.connectionTimeout,
      ));

      final result =
          await repository.changePassword(tOldPass, tNewPass, tConfirmPass);

      expect(result.isLeft(), isTrue);
      result.fold((l) => expect(l, isA<ConnectionFailure>()), (_) => null);
    });
  });

  // ─── partnerLogin (2FA Step 1) ────────────────────────────────────────────

  group('partnerLogin', () {
    const tRecaptcha = 'recaptcha-login';
    const tPartnerLoginResp = PartnerLoginResponse(
      token: 'login-token-abc',
      email: 'joh***@example.com',
      phone: '*******0034',
      pendingOtp: PendingOtpResponse(
        token: 'otp-token-pending',
        expiredAt: '2026-11-12T12:00:00Z',
        expiresIn: 60,
        typeToken: 'wa',
      ),
      otpLimitExceeded: false,
    );

    const tPartnerLoginEntity = PartnerLoginModel(
      token: 'login-token-abc',
      email: 'joh***@example.com',
      phone: '*******0034',
      pendingOtp: PendingOtpModel(
        token: 'otp-token-pending',
        expiredAt: '2026-11-12T12:00:00Z',
        expiresIn: 60,
        typeToken: 'wa',
      ),
      otpLimitExceeded: false,
    );

    test(
        'harus return Right(PartnerLoginModel) dan TIDAK menyentuh SharedPref/ProfileRepo',
        () async {
      when(mockRemote.partnerLogin(
        tUsername,
        tPassword,
        recaptchaToken: tRecaptcha,
      )).thenAnswer((_) async => tPartnerLoginResp);

      final result = await repository.partnerLogin(
        tUsername,
        tPassword,
        recaptchaToken: tRecaptcha,
      );

      expect(result, const Right(tPartnerLoginEntity));
      verifyZeroInteractions(mockSharedPref);
      verifyZeroInteractions(mockProfileRepo);
    });

    test('memetakan PartnerLoginException dari DataSource menjadi PartnerLoginFailure',
        () async {
      when(mockRemote.partnerLogin(tUsername, tPassword, recaptchaToken: null))
          .thenThrow(PartnerLoginException(
        'user not found',
        errorType: PartnerLoginErrorType.userNotFound,
      ));

      final result = await repository.partnerLogin(tUsername, tPassword);

      result.fold(
        (l) {
          expect(l, isA<PartnerLoginFailure>());
          expect(
            (l as PartnerLoginFailure).errorType,
            PartnerLoginErrorType.userNotFound,
          );
        },
        (_) => fail('Harusnya Left'),
      );
      verifyZeroInteractions(mockSharedPref);
    });

    test('memetakan HTTP 500 "user not found" menjadi PartnerLoginFailure.userNotFound',
        () async {
      when(mockRemote.partnerLogin(tUsername, tPassword, recaptchaToken: null))
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 500,
          data: {
            'meta': {'status': 'error', 'code': 500, 'message': 'user not found'}
          },
        ),
      ));

      final result = await repository.partnerLogin(tUsername, tPassword);

      result.fold(
        (l) {
          final failure = l as PartnerLoginFailure;
          expect(failure.errorType, PartnerLoginErrorType.userNotFound);
          expect(failure.message, 'user not found');
        },
        (_) => fail('Harusnya Left'),
      );
    });

    test(
        'memetakan HTTP 400 "Incorrect Password" dengan login_attempt menjadi incorrectPassword',
        () async {
      when(mockRemote.partnerLogin(tUsername, tPassword, recaptchaToken: null))
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 400,
          data: {
            'meta': {
              'status': 'error',
              'code': 400,
              'message': 'Incorrect Password',
            },
            'data': {'login_attempt': 2, 'lock': 0},
          },
        ),
      ));

      final result = await repository.partnerLogin(tUsername, tPassword);

      result.fold(
        (l) {
          final failure = l as PartnerLoginFailure;
          expect(failure.errorType, PartnerLoginErrorType.incorrectPassword);
          expect(failure.loginAttempt, 2);
          expect(failure.lock, 0);
        },
        (_) => fail('Harusnya Left'),
      );
    });

    test(
        'memetakan lock=1 lock_source="otp" menjadi PartnerLoginFailure.otpLocked24Hours',
        () async {
      when(mockRemote.partnerLogin(tUsername, tPassword, recaptchaToken: null))
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 400,
          data: {
            'meta': {
              'status': 'error',
              'code': 400,
              'message': 'Please wait 24 hours to login!',
            },
            'data': {'lock': 1, 'lock_source': 'otp'},
          },
        ),
      ));

      final result = await repository.partnerLogin(tUsername, tPassword);

      result.fold(
        (l) {
          final failure = l as PartnerLoginFailure;
          expect(failure.errorType, PartnerLoginErrorType.otpLocked24Hours);
          expect(failure.lock, 1);
          expect(failure.lockSource, 'otp');
        },
        (_) => fail('Harusnya Left'),
      );
    });

    test(
        'memetakan lock=1 non-otp menjadi PartnerLoginFailure.passwordLocked24Hours',
        () async {
      when(mockRemote.partnerLogin(tUsername, tPassword, recaptchaToken: null))
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 400,
          data: {
            'meta': {
              'status': 'error',
              'code': 400,
              'message': 'Please wait 24 hours to login!',
            },
            'data': {'lock': 1},
          },
        ),
      ));

      final result = await repository.partnerLogin(tUsername, tPassword);

      result.fold(
        (l) {
          final failure = l as PartnerLoginFailure;
          expect(
            failure.errorType,
            PartnerLoginErrorType.passwordLocked24Hours,
          );
          expect(failure.lock, 1);
        },
        (_) => fail('Harusnya Left'),
      );
    });

    test(
        'membiarkan Team Internal dan Non-Partner jatuh ke ServerFailure standar',
        () async {
      when(mockRemote.partnerLogin(tUsername, tPassword, recaptchaToken: null))
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 403,
          data: {
            'status': false,
            'error_code': 'ERR_ROLE_TEAM_INTERNAL_BLOCKED',
            'message': 'Akun Team Internal tidak dapat masuk.',
          },
        ),
      ));

      final teamResult = await repository.partnerLogin(tUsername, tPassword);
      expect(
        teamResult,
        const Left(ServerFailure(
          'ERR_ROLE_TEAM_INTERNAL_BLOCKED: Akun Team Internal tidak dapat masuk.',
        )),
      );

      when(mockRemote.partnerLogin(tUsername, tPassword, recaptchaToken: null))
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 403,
          data: {
            'meta': {'code': 403, 'message': 'user is non partner'}
          },
        ),
      ));

      final nonPartnerResult =
          await repository.partnerLogin(tUsername, tPassword);
      expect(
        nonPartnerResult,
        const Left(ServerFailure('user is non partner')),
      );
    });

    test('timeout pada partnerLogin menghasilkan Left(ConnectionFailure)',
        () async {
      when(mockRemote.partnerLogin(tUsername, tPassword, recaptchaToken: null))
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.connectionTimeout,
      ));

      final result = await repository.partnerLogin(tUsername, tPassword);

      result.fold(
        (l) => expect(l, isA<ConnectionFailure>()),
        (_) => fail('Harusnya Left'),
      );
    });
  });

  // ─── requestLoginOtp (2FA Step 2) ─────────────────────────────────────────

  group('requestLoginOtp', () {
    const tLoginToken = 'login-token-abc';
    const tMethod = 'wa';

    test('return Right(RequestLoginOtpModel) termasuk saat otpLimitExceeded true',
        () async {
      when(mockRemote.requestLoginOtp(
        tLoginToken,
        tMethod,
        recaptchaToken: 'rc-otp',
      )).thenAnswer(
        (_) async => const RequestLoginOtpResponse(
          token: 'otp-token-2',
          expiredAt: '2026-11-12T12:15:00Z',
          expiresIn: 59,
          email: 'joh***@example.com',
          phone: '*******0034',
          otpLimitExceeded: true,
        ),
      );

      final result = await repository.requestLoginOtp(
        tLoginToken,
        tMethod,
        recaptchaToken: 'rc-otp',
      );

      expect(
        result,
        const Right(
          RequestLoginOtpModel(
            token: 'otp-token-2',
            expiredAt: '2026-11-12T12:15:00Z',
            expiresIn: 59,
            email: 'joh***@example.com',
            phone: '*******0034',
            otpLimitExceeded: true,
          ),
        ),
      );
      verifyZeroInteractions(mockSharedPref);
    });

    test('error badResponse pada requestLoginOtp menghasilkan Left(ServerFailure)',
        () async {
      when(mockRemote.requestLoginOtp(tLoginToken, tMethod, recaptchaToken: null))
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 400,
          data: {
            'meta': {'code': 400, 'message': 'Request OTP sudah mencapai batas.'}
          },
        ),
      ));

      final result = await repository.requestLoginOtp(tLoginToken, tMethod);

      expect(
        result,
        const Left(ServerFailure('Request OTP sudah mencapai batas.')),
      );
    });
  });

  // ─── verifyLoginOtp (2FA Step 3) ──────────────────────────────────────────

  group('verifyLoginOtp', () {
    const tOtpToken = 'otp-token-pending';
    const tOtp = '123456';

    test('return Right(VerifyLoginOtpModel) dan belum menyimpan sesi final',
        () async {
      when(mockRemote.verifyLoginOtp(
        tOtpToken,
        tOtp,
        recaptchaToken: 'rc-verify',
      )).thenAnswer(
        (_) async => const VerifyLoginOtpResponse(
          jwtToken: 'jwt-valid-token',
          attemptLeft: null,
        ),
      );

      final result = await repository.verifyLoginOtp(
        tOtpToken,
        tOtp,
        recaptchaToken: 'rc-verify',
      );

      expect(
        result,
        const Right(
          VerifyLoginOtpModel(jwtToken: 'jwt-valid-token', attemptLeft: null),
        ),
      );
      verifyZeroInteractions(mockSharedPref);
      verifyZeroInteractions(mockProfileRepo);
    });

    test('memetakan VerifyOtpException menjadi Left(VerifyOtpFailure)',
        () async {
      when(mockRemote.verifyLoginOtp(tOtpToken, tOtp, recaptchaToken: null))
          .thenThrow(VerifyOtpException(
        'OTP not valid',
        errorType: VerifyOtpErrorType.otpInvalid,
        attemptLeft: 2,
        lock: 0,
      ));

      final result = await repository.verifyLoginOtp(tOtpToken, tOtp);

      result.fold(
        (l) {
          final failure = l as VerifyOtpFailure;
          expect(failure.errorType, VerifyOtpErrorType.otpInvalid);
          expect(failure.attemptLeft, 2);
          expect(failure.lock, 0);
        },
        (_) => fail('Harusnya Left'),
      );
    });

    test(
        'memetakan HTTP 422 "Expired token" menjadi VerifyOtpFailure.expiredToken',
        () async {
      when(mockRemote.verifyLoginOtp(tOtpToken, tOtp, recaptchaToken: null))
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 422,
          data: {
            'meta': {'status': 'error', 'code': 422, 'message': 'Expired token'}
          },
        ),
      ));

      final result = await repository.verifyLoginOtp(tOtpToken, tOtp);

      result.fold(
        (l) => expect((l as VerifyOtpFailure).errorType,
            VerifyOtpErrorType.expiredToken),
        (_) => fail('Harusnya Left'),
      );
    });

    test(
        'memetakan HTTP 422 "OTP not valid" lock=0 -> otpInvalid dan lock=1 -> otpInvalidLocked',
        () async {
      when(mockRemote.verifyLoginOtp(tOtpToken, tOtp, recaptchaToken: null))
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 422,
          data: {
            'meta': {'status': 'error', 'code': 422, 'message': 'OTP not valid'},
            'data': {'attempt_left': 1, 'lock': 0},
          },
        ),
      ));

      final invalidResult = await repository.verifyLoginOtp(tOtpToken, tOtp);
      invalidResult.fold(
        (l) {
          final f = l as VerifyOtpFailure;
          expect(f.errorType, VerifyOtpErrorType.otpInvalid);
          expect(f.attemptLeft, 1);
          expect(f.lock, 0);
        },
        (_) => fail('Harusnya Left'),
      );

      when(mockRemote.verifyLoginOtp(tOtpToken, tOtp, recaptchaToken: null))
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 422,
          data: {
            'meta': {'status': 'error', 'code': 422, 'message': 'OTP not valid'},
            'data': {'attempt_left': 0, 'lock': 1},
          },
        ),
      ));

      final lockedResult = await repository.verifyLoginOtp(tOtpToken, tOtp);
      lockedResult.fold(
        (l) {
          final f = l as VerifyOtpFailure;
          expect(f.errorType, VerifyOtpErrorType.otpInvalidLocked);
          expect(f.attemptLeft, 0);
          expect(f.lock, 1);
        },
        (_) => fail('Harusnya Left'),
      );
    });

    test('timeout pada verifyLoginOtp menghasilkan Left(ConnectionFailure)',
        () async {
      when(mockRemote.verifyLoginOtp(tOtpToken, tOtp, recaptchaToken: null))
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.connectionTimeout,
      ));

      final result = await repository.verifyLoginOtp(tOtpToken, tOtp);
      result.fold(
        (l) => expect(l, isA<ConnectionFailure>()),
        (_) => fail('Harusnya Left'),
      );
    });
  });

  // ─── completeTwoFaSession (Post-Verify Profile + SharedPref Sync) ──────────

  group('completeTwoFaSession', () {
    const tJwtToken = 'jwt-superapp-token-999';
    const tProfileModel = SuperappProfileModel(
      id: 42,
      username: 'partner_kom',
      fullName: 'Partner Komerce',
      email: 'partner@komerce.id',
      noHp: '081234560034',
      address: 'Purbalingga',
      photoProfileUrl: 'https://cdn.komerce.id/avatar.png',
      saldo: 150000,
      kompoints: 2500,
      accountStatus: 'active',
    );

    test(
        'Happy Path: simpan JWT -> getProfile -> simpan USERANDTOKEN & PROFILEDATA -> return Right(UserLoginModel)',
        () async {
      when(mockProfileRepo.getProfile())
          .thenAnswer((_) async => const Right(tProfileModel));

      final result = await repository.completeTwoFaSession('  $tJwtToken  ');

      expect(
        result,
        const Right(
          UserLoginModel(
            id: 42,
            username: 'partner_kom',
            fullName: 'Partner Komerce',
            email: 'partner@komerce.id',
          ),
        ),
      );

      verifyInOrder([
        mockSecureStorage.saveAccessToken(tJwtToken),
        mockProfileRepo.getProfile(),
        mockSharedPref.saveUserAndToken(
          const LoginResponse(
            accessToken: tJwtToken,
            tokenType: 'Bearer',
            data: UserLoginData(
              id: 42,
              username: 'partner_kom',
              fullName: 'Partner Komerce',
              email: 'partner@komerce.id',
            ),
          ),
        ),
        mockSharedPref.saveProfileData(
          const ProfileResponse(
            id: 42,
            partnerId: 42,
            partnerNo: null,
            fullname: 'Partner Komerce',
            username: 'partner_kom',
            email: 'partner@komerce.id',
            noTelp: '081234560034',
            address: 'Purbalingga',
            joinDate: null,
            bankName: null,
            bankAccountNumber: null,
            bankOwnername: '',
            photoProfileUrl: 'https://cdn.komerce.id/avatar.png',
            kmPoin: 150000,
            accountStatus: 'active',
            createdAt: null,
            updatedAt: null,
            kompoin: 2500,
            businessSectoreId: null,
          ),
        ),
        mockProfileRepo.seedPendingProfile(tProfileModel),
      ]);

      verifyNever(mockSecureStorage.deleteTokens());
      verifyNever(mockSharedPref.removeDataPref());
      verifyNever(mockProfileRepo.clearCache());
    });

    test('Edge Path: jwtToken kosong menolak tanpa menyentuh storage atau API',
        () async {
      final result = await repository.completeTwoFaSession('   ');

      expect(
        result,
        const Left(ServerFailure('Respons login tidak memuat sesi yang valid')),
      );
      verifyZeroInteractions(mockSecureStorage);
      verifyZeroInteractions(mockProfileRepo);
      verifyNever(mockSharedPref.saveUserAndToken(any));
      verifyNever(mockSharedPref.saveProfileData(any));
    });

    test('Edge Path: superappProfileRepository null gagal aman tanpa menyentuh storage',
        () async {
      final repoWithoutProfile = AuthRepositoryImpl(
        remoteDataSource: mockRemote,
        sharedPref: mockSharedPref,
      );

      final result = await repoWithoutProfile.completeTwoFaSession(tJwtToken);

      expect(
        result,
        const Left(ServerFailure('Layanan profil tidak tersedia')),
      );
      verifyZeroInteractions(mockSecureStorage);
      verifyNever(mockSharedPref.saveUserAndToken(any));
    });

    test(
        'Error Path: getProfile() return Left -> rollback token + cache + pref sesi dan batal simpan USERANDTOKEN/PROFILEDATA',
        () async {
      when(mockProfileRepo.getProfile())
          .thenAnswer((_) async => const Left(ServerFailure('Gagal get profile')));

      final result = await repository.completeTwoFaSession(tJwtToken);

      expect(result, const Left(ServerFailure('Gagal get profile')));
      verify(mockSecureStorage.saveAccessToken(tJwtToken)).called(1);
      verify(mockProfileRepo.getProfile()).called(1);
      verify(mockSecureStorage.deleteTokens()).called(1);
      verify(mockSharedPref.removeDataPref()).called(1);
      verify(mockProfileRepo.clearCache()).called(1);
      verifyNever(mockSharedPref.saveUserAndToken(any));
      verifyNever(mockSharedPref.saveProfileData(any));
    });

    test(
        'Error Path: saveUserAndToken throw -> rollback penuh dan return Left',
        () async {
      when(mockProfileRepo.getProfile())
          .thenAnswer((_) async => const Right(tProfileModel));
      when(mockSharedPref.saveUserAndToken(any))
          .thenThrow(Exception('prefs write error'));

      final result = await repository.completeTwoFaSession(tJwtToken);

      expect(result.isLeft(), isTrue);
      verify(mockSecureStorage.deleteTokens()).called(1);
      verify(mockSharedPref.removeDataPref()).called(1);
      verify(mockProfileRepo.clearCache()).called(1);
      verifyNever(mockSharedPref.saveProfileData(any));
    });

    test(
        'Error Path: saveProfileData throw -> rollback penuh termasuk hapus USERANDTOKEN & cache',
        () async {
      when(mockProfileRepo.getProfile())
          .thenAnswer((_) async => const Right(tProfileModel));
      when(mockSharedPref.saveProfileData(any))
          .thenThrow(Exception('disk full'));

      final result = await repository.completeTwoFaSession(tJwtToken);

      expect(result.isLeft(), isTrue);
      verify(mockSharedPref.saveUserAndToken(any)).called(1);
      verify(mockSecureStorage.deleteTokens()).called(1);
      verify(mockSharedPref.removeDataPref()).called(1);
      verify(mockProfileRepo.clearCache()).called(1);
    });
  });
}
