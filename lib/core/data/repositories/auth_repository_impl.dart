import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:komtim_partner/common/failure.dart';

import '../../domain/entities/check_email_model.dart';
import '../../domain/entities/login_model.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/preferences/shared_pref.dart';
import '../datasources/remote/auth_remote_datasource.dart';
import '../models/login_response.dart';
import 'base_repository.dart';

class AuthRepositoryImpl extends BaseRepository implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SharedPref sharedPref;

  AuthRepositoryImpl(
      {required this.remoteDataSource, required this.sharedPref});

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

  @override
  Future<Either<Failure, LoginModel>> doLogin(String username, String password,
      {String? recaptchaToken}) async {
    return executeEither(() async {
      final result = await remoteDataSource.doLogin(
          username, password,
          recaptchaToken: recaptchaToken);

      await sharedPref.saveUserAndToken(LoginResponse(
          accessToken: result.accessToken,
          tokenType: result.tokenType,
          data: result.data));
      return result.toEntity();
    });
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

