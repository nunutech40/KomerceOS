import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komtim_partner/common/failure.dart';
import 'package:komtim_partner/core/domain/entities/partner_login_model.dart';
import 'package:komtim_partner/core/domain/entities/two_fa_failure.dart';
import 'package:komtim_partner/core/domain/usecases/partner_login_use_case.dart';
import 'package:mockito/mockito.dart';

import '../../../helpers/helpers.dart';

void main() {
  late PartnerLoginUseCase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = PartnerLoginUseCase(mockRepository);
  });

  const tUsername = 'partner@example.com';
  const tPassword = 'secret-password';
  const tRecaptchaToken = 'recaptcha-login-token';

  const tPartnerLoginModel = PartnerLoginModel(
    token: 'login-token-123',
    email: 'pa*****@example.com',
    phone: '*******0034',
    pendingOtp: PendingOtpModel(
      token: 'otp-token-456',
      expiredAt: '2026-11-12T13:00:00Z',
      expiresIn: 60,
      typeToken: 'email',
    ),
    otpLimitExceeded: false,
  );

  group('PartnerLoginUseCase', () {
    test(
      'harus meneruskan call ke repository.partnerLogin dan mengembalikan Right(PartnerLoginModel) secara utuh',
      () async {
        when(
          mockRepository.partnerLogin(
            tUsername,
            tPassword,
            recaptchaToken: tRecaptchaToken,
          ),
        ).thenAnswer((_) async => const Right(tPartnerLoginModel));

        final result = await usecase.call(
          tUsername,
          tPassword,
          recaptchaToken: tRecaptchaToken,
        );

        expect(result, const Right(tPartnerLoginModel));
        verify(
          mockRepository.partnerLogin(
            tUsername,
            tPassword,
            recaptchaToken: tRecaptchaToken,
          ),
        ).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test(
      'harus meneruskan parameter default recaptchaToken == null secara akurat',
      () async {
        const tLimitModel = PartnerLoginModel(
          token: 'login-token-limit',
          email: 'pa*****@example.com',
          otpLimitExceeded: true,
        );
        when(
          mockRepository.partnerLogin(
            tUsername,
            tPassword,
            recaptchaToken: null,
          ),
        ).thenAnswer((_) async => const Right(tLimitModel));

        final result = await usecase.call(tUsername, tPassword);

        expect(result, const Right(tLimitModel));
        verify(
          mockRepository.partnerLogin(
            tUsername,
            tPassword,
            recaptchaToken: null,
          ),
        ).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test(
      'harus meneruskan Left(PartnerLoginFailure) dari repository tanpa mengubah failure',
      () async {
        const tFailure = PartnerLoginFailure(
          'Password salah',
          errorType: PartnerLoginErrorType.incorrectPassword,
          loginAttempt: 1,
        );
        when(
          mockRepository.partnerLogin(
            tUsername,
            tPassword,
            recaptchaToken: tRecaptchaToken,
          ),
        ).thenAnswer((_) async => const Left(tFailure));

        final result = await usecase.call(
          tUsername,
          tPassword,
          recaptchaToken: tRecaptchaToken,
        );

        expect(result, const Left(tFailure));
        verify(
          mockRepository.partnerLogin(
            tUsername,
            tPassword,
            recaptchaToken: tRecaptchaToken,
          ),
        ).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test(
      'harus meneruskan Left(ServerFailure) umum dari repository secara utuh',
      () async {
        const tFailure = ServerFailure('Internal server error');
        when(
          mockRepository.partnerLogin(
            tUsername,
            tPassword,
            recaptchaToken: null,
          ),
        ).thenAnswer((_) async => const Left(tFailure));

        final result = await usecase.call(tUsername, tPassword);

        expect(result, const Left(tFailure));
        verify(
          mockRepository.partnerLogin(
            tUsername,
            tPassword,
            recaptchaToken: null,
          ),
        ).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );
  });
}

