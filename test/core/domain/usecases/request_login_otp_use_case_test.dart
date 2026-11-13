import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komtim_partner/common/failure.dart';
import 'package:komtim_partner/core/domain/entities/request_login_otp_model.dart';
import 'package:komtim_partner/core/domain/usecases/request_login_otp_use_case.dart';
import 'package:mockito/mockito.dart';

import '../../../helpers/helpers.dart';

void main() {
  late RequestLoginOtpUseCase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = RequestLoginOtpUseCase(mockRepository);
  });

  const tLoginToken = 'login-token-123';
  const tMethod = 'wa';
  const tRecaptchaToken = 'recaptcha-otp-request-token';

  const tResponseModel = RequestLoginOtpModel(
    token: 'otp-token-789',
    expiredAt: '2026-11-12T13:01:00Z',
    expiresIn: 60,
    email: 'pa*****@example.com',
    phone: '*******0034',
    otpLimitExceeded: false,
  );

  group('RequestLoginOtpUseCase', () {
    test(
      'harus meneruskan call ke repository.requestLoginOtp dan mengembalikan Right(RequestLoginOtpModel) secara utuh',
      () async {
        when(
          mockRepository.requestLoginOtp(
            tLoginToken,
            tMethod,
            recaptchaToken: tRecaptchaToken,
          ),
        ).thenAnswer((_) async => const Right(tResponseModel));

        final result = await usecase.call(
          tLoginToken,
          tMethod,
          recaptchaToken: tRecaptchaToken,
        );

        expect(result, const Right(tResponseModel));
        verify(
          mockRepository.requestLoginOtp(
            tLoginToken,
            tMethod,
            recaptchaToken: tRecaptchaToken,
          ),
        ).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test(
      'harus meneruskan parameter default recaptchaToken == null secara akurat dan menjaga flag otpLimitExceeded',
      () async {
        const tLimitedModel = RequestLoginOtpModel(
          otpLimitExceeded: true,
        );
        when(
          mockRepository.requestLoginOtp(
            tLoginToken,
            tMethod,
            recaptchaToken: null,
          ),
        ).thenAnswer((_) async => const Right(tLimitedModel));

        final result = await usecase.call(tLoginToken, tMethod);

        expect(result, const Right(tLimitedModel));
        verify(
          mockRepository.requestLoginOtp(
            tLoginToken,
            tMethod,
            recaptchaToken: null,
          ),
        ).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test(
      'harus meneruskan Left(Failure) dari repository secara utuh',
      () async {
        const tFailure = ServerFailure('Request OTP gagal');
        when(
          mockRepository.requestLoginOtp(
            tLoginToken,
            tMethod,
            recaptchaToken: tRecaptchaToken,
          ),
        ).thenAnswer((_) async => const Left(tFailure));

        final result = await usecase.call(
          tLoginToken,
          tMethod,
          recaptchaToken: tRecaptchaToken,
        );

        expect(result, const Left(tFailure));
        verify(
          mockRepository.requestLoginOtp(
            tLoginToken,
            tMethod,
            recaptchaToken: tRecaptchaToken,
          ),
        ).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );
  });
}

