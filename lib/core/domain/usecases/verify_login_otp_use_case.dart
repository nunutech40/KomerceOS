import 'package:dartz/dartz.dart';
import 'package:komtim_partner/common/global/bloc/auth/auth_bloc.dart';
import 'package:komtim_partner/common/global/bloc/auth/auth_event.dart';

import '../../../common/failure.dart';
import '../entities/verify_login_otp_model.dart';
import '../repositories/auth_repository.dart';

class VerifyLoginOtpUseCase {
  final AuthRepository repository;
  final AuthBloc authBloc;

  VerifyLoginOtpUseCase(this.repository, this.authBloc);

  Future<Either<Failure, VerifyLoginOtpModel>> call(
    String otpToken,
    String otp, {
    String? recaptchaToken,
  }) async {
    final verifyResult = await repository.verifyLoginOtp(
      otpToken,
      otp,
      recaptchaToken: recaptchaToken,
    );

    if (verifyResult.isLeft()) {
      return verifyResult;
    }

    final verifyData = verifyResult.getOrElse(
      () => throw StateError('Unreachable Left after isLeft() check'),
    );

    final jwtToken = verifyData.jwtToken?.trim() ?? '';
    if (jwtToken.isEmpty) {
      return const Left(
        ServerFailure('Respons login tidak memuat sesi yang valid'),
      );
    }

    final sessionResult = await repository.completeTwoFaSession(jwtToken);
    return sessionResult.fold(
      Left.new,
      (user) {
        authBloc.add(AuthLoginRequested(user));
        return Right(verifyData);
      },
    );
  }
}

