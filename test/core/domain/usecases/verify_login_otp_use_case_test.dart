import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komtim_partner/common/failure.dart';
import 'package:komtim_partner/common/global/bloc/auth/auth_bloc.dart';
import 'package:komtim_partner/common/global/bloc/auth/auth_event.dart';
import 'package:komtim_partner/core/domain/entities/login_model.dart';
import 'package:komtim_partner/core/domain/entities/two_fa_failure.dart';
import 'package:komtim_partner/core/domain/entities/verify_login_otp_model.dart';
import 'package:komtim_partner/core/domain/usecases/verify_login_otp_use_case.dart';
import 'package:mockito/mockito.dart';

import '../../../helpers/helpers.dart';

class _FakeAuthBloc extends AuthBloc {
  final List<UserLoginModel> loginUsers = [];

  _FakeAuthBloc({required super.sharedPref});

  @override
  void add(AuthEvent event) {
    if (event is AuthLoginRequested) {
      loginUsers.add(event.user);
    }
    super.add(event);
  }
}

void main() {
  late VerifyLoginOtpUseCase usecase;
  late MockAuthRepository mockRepository;
  late _FakeAuthBloc fakeAuthBloc;

  setUp(() {
    mockRepository = MockAuthRepository();
    fakeAuthBloc = _FakeAuthBloc(sharedPref: MockSharedPref());
    usecase = VerifyLoginOtpUseCase(mockRepository, fakeAuthBloc);
  });

  tearDown(() async {
    await fakeAuthBloc.close();
  });

  const tOtpToken = 'otp-token-789';
  const tOtp = '123456';
  const tRecaptchaToken = 'recaptcha-otp-verify-token';
  const tJwtRaw = '  jwt-session-token-123  ';
  const tJwtTrimmed = 'jwt-session-token-123';

  const tVerifyModel = VerifyLoginOtpModel(
    jwtToken: tJwtRaw,
    attemptLeft: null,
  );

  const tUser = UserLoginModel(
    id: 42,
    username: 'partner_user',
    fullName: 'Partner Komtim',
    email: 'partner@example.com',
  );

  group('VerifyLoginOtpUseCase', () {
    test(
      'harus memverifikasi OTP, menyinkronkan sesi dengan JWT yang di-trim, dispatch AuthLoginRequested, dan mengembalikan Right(VerifyLoginOtpModel) (Happy + Chain Path)',
      () async {
        when(
          mockRepository.verifyLoginOtp(
            tOtpToken,
            tOtp,
            recaptchaToken: tRecaptchaToken,
          ),
        ).thenAnswer((_) async => const Right(tVerifyModel));
        when(mockRepository.completeTwoFaSession(tJwtTrimmed))
            .thenAnswer((_) async => const Right(tUser));

        final result = await usecase.call(
          tOtpToken,
          tOtp,
          recaptchaToken: tRecaptchaToken,
        );

        expect(result, const Right(tVerifyModel));
        verifyInOrder([
          mockRepository.verifyLoginOtp(
            tOtpToken,
            tOtp,
            recaptchaToken: tRecaptchaToken,
          ),
          mockRepository.completeTwoFaSession(tJwtTrimmed),
        ]);
        verifyNoMoreInteractions(mockRepository);
        expect(fakeAuthBloc.loginUsers, [tUser]);
      },
    );

    test(
      'harus mengembalikan Left(VerifyOtpFailure) dan TIDAK memanggil completeTwoFaSession maupun dispatch AuthLoginRequested bila verifyLoginOtp gagal',
      () async {
        const tFailure = VerifyOtpFailure(
          'Kode OTP salah',
          errorType: VerifyOtpErrorType.otpInvalid,
          attemptLeft: 2,
        );
        when(
          mockRepository.verifyLoginOtp(
            tOtpToken,
            tOtp,
            recaptchaToken: null,
          ),
        ).thenAnswer((_) async => const Left(tFailure));

        final result = await usecase.call(tOtpToken, tOtp);

        expect(result, const Left(tFailure));
        verify(
          mockRepository.verifyLoginOtp(
            tOtpToken,
            tOtp,
            recaptchaToken: null,
          ),
        ).called(1);
        verifyNever(mockRepository.completeTwoFaSession(any));
        verifyNoMoreInteractions(mockRepository);
        expect(fakeAuthBloc.loginUsers, isEmpty);
      },
    );

    test(
      'harus mengembalikan Left(ServerFailure) dan tidak memanggil completeTwoFaSession bila jwtToken null',
      () async {
        when(
          mockRepository.verifyLoginOtp(
            tOtpToken,
            tOtp,
            recaptchaToken: tRecaptchaToken,
          ),
        ).thenAnswer((_) async => const Right(VerifyLoginOtpModel()));

        final result = await usecase.call(
          tOtpToken,
          tOtp,
          recaptchaToken: tRecaptchaToken,
        );

        expect(
          result,
          const Left(ServerFailure('Respons login tidak memuat sesi yang valid')),
        );
        verify(
          mockRepository.verifyLoginOtp(
            tOtpToken,
            tOtp,
            recaptchaToken: tRecaptchaToken,
          ),
        ).called(1);
        verifyNever(mockRepository.completeTwoFaSession(any));
        verifyNoMoreInteractions(mockRepository);
        expect(fakeAuthBloc.loginUsers, isEmpty);
      },
    );

    test(
      'harus mengembalikan Left(ServerFailure) dan tidak memanggil completeTwoFaSession bila jwtToken kosong/whitespace',
      () async {
        when(
          mockRepository.verifyLoginOtp(
            tOtpToken,
            tOtp,
            recaptchaToken: null,
          ),
        ).thenAnswer(
          (_) async => const Right(VerifyLoginOtpModel(jwtToken: '   ')),
        );

        final result = await usecase.call(tOtpToken, tOtp);

        expect(
          result,
          const Left(ServerFailure('Respons login tidak memuat sesi yang valid')),
        );
        verify(
          mockRepository.verifyLoginOtp(
            tOtpToken,
            tOtp,
            recaptchaToken: null,
          ),
        ).called(1);
        verifyNever(mockRepository.completeTwoFaSession(any));
        verifyNoMoreInteractions(mockRepository);
        expect(fakeAuthBloc.loginUsers, isEmpty);
      },
    );

    test(
      'harus mengembalikan Left(Failure) dan TIDAK dispatch AuthLoginRequested bila completeTwoFaSession gagal',
      () async {
        const tProfileFailure = ServerFailure('Gagal memuat profil');
        when(
          mockRepository.verifyLoginOtp(
            tOtpToken,
            tOtp,
            recaptchaToken: tRecaptchaToken,
          ),
        ).thenAnswer((_) async => const Right(tVerifyModel));
        when(mockRepository.completeTwoFaSession(tJwtTrimmed))
            .thenAnswer((_) async => const Left(tProfileFailure));

        final result = await usecase.call(
          tOtpToken,
          tOtp,
          recaptchaToken: tRecaptchaToken,
        );

        expect(result, const Left(tProfileFailure));
        verify(
          mockRepository.verifyLoginOtp(
            tOtpToken,
            tOtp,
            recaptchaToken: tRecaptchaToken,
          ),
        ).called(1);
        verify(mockRepository.completeTwoFaSession(tJwtTrimmed)).called(1);
        verifyNoMoreInteractions(mockRepository);
        expect(fakeAuthBloc.loginUsers, isEmpty);
      },
    );
  });
}

