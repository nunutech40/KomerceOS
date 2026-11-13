import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:komtim_partner/common/failure.dart';
import 'package:komtim_partner/common/exception.dart';

import '../../domain/entities/check_email_model.dart';
import '../../domain/entities/login_model.dart';
import '../../domain/entities/partner_login_model.dart';
import '../../domain/entities/request_login_otp_model.dart';
import '../../domain/entities/verify_login_otp_model.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/preferences/shared_pref.dart';
import '../datasources/remote/auth_remote_datasource.dart';
import '../models/login_response.dart';
import '../models/profile_response.dart';
import '../models/two_fa_auth_exception.dart';
import 'base_repository.dart';
import 'superapp_profile_repository_impl.dart';

class AuthRepositoryImpl extends BaseRepository implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SharedPref sharedPref;
  final SuperappProfileRepository? superappProfileRepository;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.sharedPref,
    this.superappProfileRepository,
  });

  @override
  Future<Either<Failure, CheckEmailModel>> checkEmailLogin(String email,
      {String? recaptchaToken}) {
    return executeEither(() async {
      final result = await remoteDataSource.checkEmailLogin(email,
          recaptchaToken: recaptchaToken);
      return result.toEntity();
    });
  }

  @override
  Future<Either<Failure, bool>> getAuthState() async {
    return executeEitherPref(() async {
      return await sharedPref.isLoggedIn();
    });
  }

  /// [LEGACY] Gunakan [partnerLogin], [requestLoginOtp], [verifyLoginOtp], dan
  /// [completeTwoFaSession] untuk flow login 2FA partner.
  @override
  Future<Either<Failure, LoginModel>> doLogin(String username, String password,
      {String? recaptchaToken}) async {
    return executeEither(() async {
      final result = await remoteDataSource.doLogin(username, password,
          recaptchaToken: recaptchaToken);

      if (result.accessToken == null ||
          result.accessToken!.trim().isEmpty ||
          result.data == null) {
        throw ServerException('Respons login tidak memuat sesi yang valid');
      }

      await sharedPref.saveUserAndToken(LoginResponse(
          accessToken: result.accessToken,
          tokenType: result.tokenType,
          data: result.data));
      return result.toEntity();
    });
  }

  @override
  Future<Either<Failure, PartnerLoginModel>> partnerLogin(
    String username,
    String password, {
    String? recaptchaToken,
  }) async {
    try {
      final result = await remoteDataSource.partnerLogin(
        username,
        password,
        recaptchaToken: recaptchaToken,
      );
      return Right(result.toEntity());
    } on PartnerLoginException catch (e) {
      return Left(e.toFailure());
    } on DioException catch (e, st) {
      if (e.type == DioExceptionType.badResponse && e.response != null) {
        final parsedException = tryParsePartnerLoginException(
          e.response!.statusCode,
          e.response!.data,
        );
        if (parsedException != null) {
          return Left(parsedException.toFailure());
        }
      }
      return executeEither(() async {
        Error.throwWithStackTrace(e, st);
      });
    } catch (e, st) {
      return executeEither(() async {
        Error.throwWithStackTrace(e, st);
      });
    }
  }

  @override
  Future<Either<Failure, RequestLoginOtpModel>> requestLoginOtp(
    String loginToken,
    String method, {
    String? recaptchaToken,
  }) {
    return executeEither(() async {
      final result = await remoteDataSource.requestLoginOtp(
        loginToken,
        method,
        recaptchaToken: recaptchaToken,
      );
      return result.toEntity();
    });
  }

  @override
  Future<Either<Failure, VerifyLoginOtpModel>> verifyLoginOtp(
    String otpToken,
    String otp, {
    String? recaptchaToken,
  }) async {
    try {
      final result = await remoteDataSource.verifyLoginOtp(
        otpToken,
        otp,
        recaptchaToken: recaptchaToken,
      );
      return Right(result.toEntity());
    } on VerifyOtpException catch (e) {
      return Left(e.toFailure());
    } on DioException catch (e, st) {
      if (e.type == DioExceptionType.badResponse && e.response != null) {
        final parsedException = tryParseVerifyOtpException(
          e.response!.statusCode,
          e.response!.data,
        );
        if (parsedException != null) {
          return Left(parsedException.toFailure());
        }
      }
      return executeEither(() async {
        Error.throwWithStackTrace(e, st);
      });
    } catch (e, st) {
      return executeEither(() async {
        Error.throwWithStackTrace(e, st);
      });
    }
  }

  @override
  Future<Either<Failure, UserLoginModel>> completeTwoFaSession(
    String jwtToken,
  ) async {
    final trimmedToken = jwtToken.trim();
    if (trimmedToken.isEmpty) {
      return const Left(ServerFailure('Respons login tidak memuat sesi yang valid'));
    }

    final profileRepo = superappProfileRepository;
    if (profileRepo == null) {
      return const Left(ServerFailure('Layanan profil tidak tersedia'));
    }

    try {
      await sharedPref.secureStorage.saveAccessToken(trimmedToken);

      final profileResult = await profileRepo.getProfile();
      if (profileResult.isLeft()) {
        await _rollbackTwoFaSession(profileRepo);
        return profileResult.fold(
          Left.new,
          (_) => throw StateError('Unreachable Right after isLeft()'),
        );
      }

      final profile = profileResult.getOrElse(
        () => throw StateError('Unreachable Left after isLeft() check'),
      );

      final userData = UserLoginData(
        id: profile.id,
        username: profile.username,
        fullName: profile.fullName,
        email: profile.email,
      );

      await sharedPref.saveUserAndToken(
        LoginResponse(
          accessToken: trimmedToken,
          tokenType: 'Bearer',
          data: userData,
        ),
      );

      await sharedPref.saveProfileData(
        ProfileResponse(
          id: profile.id,
          partnerId: profile.id ?? 0,
          partnerNo: null,
          fullname: profile.fullName,
          username: profile.username,
          email: profile.email,
          noTelp: profile.noHp,
          address: profile.address,
          joinDate: null,
          bankName: null,
          bankAccountNumber: null,
          bankOwnername: '',
          photoProfileUrl: profile.photoProfileUrl,
          kmPoin: profile.saldo,
          accountStatus: profile.accountStatus,
          createdAt: null,
          updatedAt: null,
          kompoin: profile.kompoints,
          businessSectoreId: null,
        ),
      );

      // Seed profile agar consumer berikutnya (SuperappProfileBloc saat login)
      // dapat langsung mengonsumsi data segar tanpa hit ulang API get-profile-mobile.
      profileRepo.seedPendingProfile(profile);

      return Right(userData.toEntity());
    } catch (e, st) {
      await _rollbackTwoFaSession(profileRepo);
      return executeEither(() async {
        Error.throwWithStackTrace(e, st);
      });
    }
  }

  Future<void> _rollbackTwoFaSession(
    SuperappProfileRepository profileRepo,
  ) async {
    try {
      await sharedPref.secureStorage.deleteTokens();
    } catch (_) {}
    try {
      await sharedPref.removeDataPref();
    } catch (_) {}
    try {
      await profileRepo.clearCache();
    } catch (_) {}
  }

  @override
  Future<Either<Failure, bool>> doLogout() async {
    return executeEither(() async {
      try {
        final result = await remoteDataSource.doLogout();

        if (result) {
          await sharedPref.removeDataPref();
        }
        return result;
      } catch (e) {
        await sharedPref.removeDataPref();
        rethrow;
      }
    });
  }

  @override
  Future<Either<Failure, bool>> sendForgotPass(String email,
      {String? recaptchaToken}) {
    return executeEither(() async {
      final result = await remoteDataSource.sendForgotPassword(email,
          recaptchaToken: recaptchaToken);
      return result;
    });
  }

  @override
  Future<Either<Failure, bool>> changePassword(
      String oldPass, String newPass, String confirmPass) {
    return executeEither(() async {
      final result =
          await remoteDataSource.changePassword(oldPass, newPass, confirmPass);
      return result;
    });
  }

  @override
  Future<Either<Failure, bool>> resetPassword(String code, String password) {
    return executeEither(() async {
      return await remoteDataSource.resetPassword(code, password);
    });
  }

  @override
  Future<Either<Failure, bool>> resendVerification(
      String email, String productName) {
    return executeEither(() async {
      return await remoteDataSource.resendVerification(email, productName);
    });
  }
}
