import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komtim_partner/common/enum_status.dart';
import 'package:komtim_partner/common/failure.dart';
import 'package:komtim_partner/core/domain/entities/check_email_model.dart';
import 'package:komtim_partner/core/domain/usecases/check_email_login_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/recaptcha_use_case.dart';
import 'package:komtim_partner/features/superapp/features/authentication/bloc/check_email_bloc.dart';
import 'package:komtim_partner/features/superapp/features/authentication/bloc/login_bloc.dart';
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
  late _RecordingRecaptcha recaptcha;

  setUp(() {
    repository = MockAuthRepository();
    checkEmail = CheckEmailLoginUseCase(repository);
    recaptcha = _RecordingRecaptcha();
    when(repository.checkEmailLogin(
      any,
      recaptchaToken: anyNamed('recaptchaToken'),
    )).thenAnswer((_) async => const Right(CheckEmailModel(
          allowedLogin: true,
          email: 'user@example.com',
        )));
  });

  test('halaman email membuat token CHECK_LOGIN untuk endpoint check-login',
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

    expect(recaptcha.actions, ['CHECK_LOGIN']);
    verify(repository.checkEmailLogin(
      'user@example.com',
      recaptchaToken: 'test-token',
    )).called(1);
  });

  test('submit password memakai token CHECK_LOGIN untuk endpoint login',
      () async {
    final doLogin = MockDoLoginUseCase();
    when(doLogin.execute(
      any,
      any,
      recaptchaToken: anyNamed('recaptchaToken'),
    )).thenAnswer((_) async => const Left(ServerFailure('Login ditolak')));
    final bloc = LoginBloc(
      checkEmailLoginUseCase: checkEmail,
      doLoginUseCase: doLogin,
      recaptchaUseCase: recaptcha,
    );
    addTearDown(bloc.close);

    bloc.add(const LoginEmailChangedEvent(email: 'user@example.com'));
    await bloc.stream
        .firstWhere((state) => state.username == 'user@example.com');
    bloc.add(const LoginButtonPressedEvent());
    await bloc.stream.firstWhere((state) => state.isEmailChecked);
    // Tahap email hanya menyiapkan state LoginBloc; periksa submit password
    // secara terpisah karena inilah request yang gagal di perangkat.
    recaptcha.actions.clear();

    bloc.add(const LoginPasswordChangedEvent(password: 'password123'));
    await bloc.stream.firstWhere((state) => state.password == 'password123');
    bloc.add(const LoginButtonPressedEvent());
    await bloc.stream.firstWhere(
      (state) => state.status == RequestStatus.failure,
    );

    expect(recaptcha.actions, ['CHECK_LOGIN']);
    verify(doLogin.execute(
      'user@example.com',
      'password123',
      recaptchaToken: 'test-token',
    )).called(1);
  });
}
