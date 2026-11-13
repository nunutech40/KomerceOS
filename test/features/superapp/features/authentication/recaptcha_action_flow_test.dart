import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komtim_partner/common/enum_status.dart';
import 'package:komtim_partner/common/failure.dart';
import 'package:komtim_partner/core/domain/entities/check_email_model.dart';
import 'package:komtim_partner/core/domain/entities/partner_login_model.dart';
import 'package:komtim_partner/core/domain/entities/request_login_otp_model.dart';
import 'package:komtim_partner/core/domain/entities/verify_login_otp_model.dart';
import 'package:komtim_partner/core/domain/usecases/check_email_login_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/recaptcha_use_case.dart';
import 'package:komtim_partner/features/superapp/features/authentication/bloc/check_email_bloc.dart';
import 'package:komtim_partner/features/superapp/features/authentication/bloc/login_bloc.dart';
import 'package:komtim_partner/features/superapp/features/authentication/widgets/two_fa_method_bottom_sheet.dart';
import 'package:mockito/mockito.dart';
import 'package:recaptcha_enterprise_flutter/recaptcha_action.dart';

import '../../../../helpers/mocks/mocks.dart';

class _RecordingRecaptcha extends RecaptchaUseCase {
  final actions = <String>[];

  @override
  bool get isInitialized => true;

  @override
  Future<String> getToken(RecaptchaAction action) async {
    actions.add(action.action);
    return 'test-token';
  }
}

void main() {
  late MockAuthRepository repository;
  late CheckEmailLoginUseCase checkEmail;
  late MockPartnerLoginUseCase partnerLogin;
  late MockRequestLoginOtpUseCase requestLoginOtp;
  late MockVerifyLoginOtpUseCase verifyLoginOtp;
  late _RecordingRecaptcha recaptcha;

  setUp(() {
    repository = MockAuthRepository();
    checkEmail = CheckEmailLoginUseCase(repository);
    partnerLogin = MockPartnerLoginUseCase();
    requestLoginOtp = MockRequestLoginOtpUseCase();
    verifyLoginOtp = MockVerifyLoginOtpUseCase();
    recaptcha = _RecordingRecaptcha();
    when(repository.checkEmailLogin(
      any,
      recaptchaToken: anyNamed('recaptchaToken'),
    )).thenAnswer((_) async => const Right(CheckEmailModel(
          allowedLogin: true,
          email: 'user@example.com',
        )));
  });

  LoginBloc createLoginBloc() => LoginBloc(
        checkEmailLoginUseCase: checkEmail,
        partnerLoginUseCase: partnerLogin,
        requestLoginOtpUseCase: requestLoginOtp,
        verifyLoginOtpUseCase: verifyLoginOtp,
        recaptchaUseCase: recaptcha,
      );

  test('halaman email membuat token CHECK_EMAIL untuk endpoint check-login',
      () async {
    final bloc = CheckEmailBloc(
      checkEmailLoginUseCase: checkEmail,
      recaptchaUseCase: recaptcha,
    );
    addTearDown(bloc.close);

    final completed =
        bloc.stream.firstWhere((state) => state is CheckEmailFound);
    bloc.add(const CheckEmailSubmitted('user@example.com'));
    await completed;

    expect(recaptcha.actions, ['CHECK_EMAIL']);
    verify(repository.checkEmailLogin(
      'user@example.com',
      recaptchaToken: 'test-token',
    )).called(1);
  });

  test('hasil check-login lama diabaikan setelah email diubah', () async {
    final pending = Completer<Either<Failure, CheckEmailModel>>();
    when(repository.checkEmailLogin(
      any,
      recaptchaToken: anyNamed('recaptchaToken'),
    )).thenAnswer((_) => pending.future);
    final bloc = CheckEmailBloc(
      checkEmailLoginUseCase: checkEmail,
      recaptchaUseCase: recaptcha,
    );
    addTearDown(bloc.close);

    bloc.add(const CheckEmailSubmitted('old@example.com'));
    await bloc.stream.firstWhere((state) => state is CheckEmailLoading);
    bloc.add(const CheckEmailReset());
    await bloc.stream.firstWhere((state) => state is CheckEmailInitial);
    pending.complete(const Right(CheckEmailModel(
      allowedLogin: true,
      email: 'old@example.com',
    )));
    await Future<void>.delayed(Duration.zero);

    expect(bloc.state, isA<CheckEmailInitial>());
  });

  test('submit password memakai token LOGIN untuk endpoint partner/login',
      () async {
    when(partnerLogin.call(
      any,
      any,
      recaptchaToken: anyNamed('recaptchaToken'),
    )).thenAnswer((_) async => const Left(ServerFailure('Login ditolak')));
    final bloc = createLoginBloc();
    addTearDown(bloc.close);

    bloc.add(const LoginEmailChangedEvent(email: 'user@example.com'));
    await bloc.stream
        .firstWhere((state) => state.username == 'user@example.com');
    bloc.add(const LoginButtonPressedEvent());
    await bloc.stream.firstWhere((state) => state.isEmailChecked);
    expect(recaptcha.actions, ['CHECK_EMAIL']);
    // Tahap email hanya menyiapkan state LoginBloc; periksa submit password
    // secara terpisah karena inilah request yang gagal di perangkat.
    recaptcha.actions.clear();

    bloc.add(const LoginPasswordChangedEvent(password: 'password123'));
    await bloc.stream.firstWhere((state) => state.password == 'password123');
    bloc.add(const LoginButtonPressedEvent());
    await bloc.stream.firstWhere(
      (state) => state.status == RequestStatus.failure,
    );

    expect(recaptcha.actions, ['LOGIN']);
    verify(partnerLogin.call(
      'user@example.com',
      'password123',
      recaptchaToken: 'test-token',
    )).called(1);
  });

  test(
      'email yang sudah lolos check-login tidak dicek ulang di halaman password',
      () async {
    when(partnerLogin.call(
      any,
      any,
      recaptchaToken: anyNamed('recaptchaToken'),
    )).thenAnswer((_) async => const Left(ServerFailure('Login ditolak')));
    final bloc = createLoginBloc();
    addTearDown(bloc.close);

    bloc.add(const LoginEmailPrecheckedEvent('user@example.com'));
    await bloc.stream.firstWhere((state) => state.isEmailChecked);
    bloc.add(const LoginPasswordChangedEvent(password: 'password123'));
    await bloc.stream.firstWhere((state) => state.password == 'password123');
    bloc.add(const LoginButtonPressedEvent());
    await bloc.stream.firstWhere(
      (state) => state.status == RequestStatus.failure,
    );

    expect(recaptcha.actions, ['LOGIN']);
    verifyNever(repository.checkEmailLogin(any,
        recaptchaToken: anyNamed('recaptchaToken')));
  });

  test(
      'pilih metode, kirim ulang, dan verifikasi OTP memakai token REQUEST_OTP lalu VERIFY_OTP',
      () async {
    when(partnerLogin.call(
      any,
      any,
      recaptchaToken: anyNamed('recaptchaToken'),
    )).thenAnswer((_) async => const Right(PartnerLoginModel(
          token: 'login-token-1',
          email: 'use***@e*****com',
          phone: '*********0034',
        )));
    when(requestLoginOtp.call(
      any,
      any,
      recaptchaToken: anyNamed('recaptchaToken'),
    )).thenAnswer((_) async => const Right(RequestLoginOtpModel(
          token: 'otp-token-1',
          expiresIn: 59,
          email: 'use***@e*****com',
          phone: '*********0034',
        )));
    when(verifyLoginOtp.call(
      any,
      any,
      recaptchaToken: anyNamed('recaptchaToken'),
    )).thenAnswer((_) async => const Right(VerifyLoginOtpModel(
          jwtToken: 'jwt-123',
        )));

    final bloc = createLoginBloc();
    addTearDown(bloc.close);

    bloc.add(const LoginEmailPrecheckedEvent('user@example.com'));
    await bloc.stream.firstWhere((state) => state.isEmailChecked);
    bloc.add(const LoginPasswordChangedEvent(password: 'password123'));
    await bloc.stream.firstWhere((state) => state.password == 'password123');

    bloc.add(const LoginButtonPressedEvent());
    await bloc.stream.firstWhere(
      (state) => state.twoFaStage == LoginTwoFaStage.selectMethod,
    );

    bloc.add(const LoginTwoFaMethodSelectedEvent(TwoFaMethodType.email));
    await bloc.stream.firstWhere(
      (state) => state.twoFaStage == LoginTwoFaStage.verifyOtp,
    );

    bloc.add(const LoginOtpResendRequestedEvent());
    await bloc.stream.firstWhere((state) => state.otpCountdownKey == 2);

    bloc.add(const LoginOtpSubmittedEvent('123456'));
    await bloc.stream.firstWhere(
      (state) => state.status == RequestStatus.success,
    );

    expect(
      recaptcha.actions,
      ['LOGIN', 'REQUEST_OTP', 'REQUEST_OTP', 'VERIFY_OTP'],
    );
    verify(requestLoginOtp.call(
      'login-token-1',
      'email',
      recaptchaToken: 'test-token',
    )).called(2);
    verify(verifyLoginOtp.call(
      'otp-token-1',
      '123456',
      recaptchaToken: 'test-token',
    )).called(1);
  });
}
