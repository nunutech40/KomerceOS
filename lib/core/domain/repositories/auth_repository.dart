import 'package:dartz/dartz.dart';

import '../../../common/failure.dart';
import '../entities/check_email_model.dart';
import '../entities/login_model.dart';

abstract class AuthRepository {
  Future<Either<Failure, CheckEmailModel>> checkEmailLogin(String email,
      {String? recaptchaToken});
  Future<Either<Failure, LoginModel>> doLogin(
      String username, String password, {String? recaptchaToken});
  Future<Either<Failure, bool>> getAuthState();
  Future<Either<Failure, bool>> doLogout();
  Future<Either<Failure, bool>> sendForgotPass(String email,
      {String? recaptchaToken});
  Future<Either<Failure, bool>> changePassword(
      String oldPass, String newPass, String confirmPass);
  Future<Either<Failure, bool>> resetPassword(String code, String password);
  Future<Either<Failure, bool>> resendVerification(
      String email, String productName);
}
