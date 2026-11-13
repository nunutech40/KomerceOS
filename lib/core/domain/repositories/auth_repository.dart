import 'package:dartz/dartz.dart';

import '../../../common/failure.dart';
import '../entities/check_email_model.dart';
import '../entities/login_model.dart';
import '../entities/partner_login_model.dart';
import '../entities/request_login_otp_model.dart';
import '../entities/verify_login_otp_model.dart';

abstract class AuthRepository {
  Future<Either<Failure, CheckEmailModel>> checkEmailLogin(String email,
      {String? recaptchaToken});

  /// [LEGACY] Gunakan flow [partnerLogin], [requestLoginOtp], [verifyLoginOtp],
  /// dan [completeTwoFaSession] untuk login 2FA partner.
  Future<Either<Failure, LoginModel>> doLogin(
      String username, String password, {String? recaptchaToken});

  Future<Either<Failure, PartnerLoginModel>> partnerLogin(
    String username,
    String password, {
    String? recaptchaToken,
  });

  Future<Either<Failure, RequestLoginOtpModel>> requestLoginOtp(
    String loginToken,
    String method, {
    String? recaptchaToken,
  });

  Future<Either<Failure, VerifyLoginOtpModel>> verifyLoginOtp(
    String otpToken,
    String otp, {
    String? recaptchaToken,
  });

  Future<Either<Failure, UserLoginModel>> completeTwoFaSession(String jwtToken);

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
