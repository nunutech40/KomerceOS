import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komtim_partner/common/enum_status.dart';
import 'package:komtim_partner/common/failure.dart';
import 'package:komtim_partner/core/domain/entities/check_email_model.dart';
import 'package:komtim_partner/core/domain/entities/partner_login_model.dart';
import 'package:komtim_partner/core/domain/entities/partner_product_model.dart';
import 'package:komtim_partner/core/domain/entities/request_login_otp_model.dart';
import 'package:komtim_partner/core/domain/entities/two_fa_failure.dart';
import 'package:komtim_partner/core/domain/entities/verify_login_otp_model.dart';
import 'package:komtim_partner/features/superapp/features/authentication/bloc/login_bloc.dart';
import 'package:komtim_partner/features/superapp/features/authentication/widgets/two_fa_locked_bottom_sheet.dart';
import 'package:komtim_partner/features/superapp/features/authentication/widgets/two_fa_method_bottom_sheet.dart';
import 'package:mockito/mockito.dart';
import 'package:recaptcha_enterprise_flutter/recaptcha_action.dart';

import '../../../../../helpers/mocks/mocks.dart';

void main() {
  late LoginBloc bloc;
  late MockCheckEmailLoginUseCase mockCheckEmailUseCase;
  late MockPartnerLoginUseCase mockPartnerLoginUseCase;
  late MockRequestLoginOtpUseCase mockRequestLoginOtpUseCase;
  late MockVerifyLoginOtpUseCase mockVerifyLoginOtpUseCase;
  late MockRecaptchaUseCase mockRecaptchaUseCase;

  const tEmail = 'partner@komerce.id';
  const tPassword = 'Password123!';
  const tRecaptchaToken = 'recaptcha-token';
  const tLoginToken = 'login-session-token';
  const tOtpToken = 'otp-session-token';
  const tMaskedEmail = 'par***@k*****id';
  const tMaskedPhone = '*********0034';

  setUp(() {
    mockCheckEmailUseCase = MockCheckEmailLoginUseCase();
    mockPartnerLoginUseCase = MockPartnerLoginUseCase();
    mockRequestLoginOtpUseCase = MockRequestLoginOtpUseCase();
    mockVerifyLoginOtpUseCase = MockVerifyLoginOtpUseCase();
    mockRecaptchaUseCase = MockRecaptchaUseCase();

    when(mockRecaptchaUseCase.isInitialized).thenReturn(true);
    when(mockRecaptchaUseCase.initializeClient()).thenAnswer((_) async {});
    when(mockRecaptchaUseCase.getToken(any))
        .thenAnswer((_) async => tRecaptchaToken);

    bloc = LoginBloc(
      checkEmailLoginUseCase: mockCheckEmailUseCase,
      partnerLoginUseCase: mockPartnerLoginUseCase,
      requestLoginOtpUseCase: mockRequestLoginOtpUseCase,
      verifyLoginOtpUseCase: mockVerifyLoginOtpUseCase,
      recaptchaUseCase: mockRecaptchaUseCase,
    );
  });

  tearDown(() {
    bloc.close();
  });

  test('initial state harus memiliki status empty dan twoFaStage none', () {
    expect(bloc.state, const LoginState());
    expect(bloc.state.status, RequestStatus.empty);
    expect(bloc.state.twoFaStage, LoginTwoFaStage.none);
    expect(bloc.state.isEmailChecked, isFalse);
  });

  group('Check Email Step (check-login)', () {
    blocTest<LoginBloc, LoginState>(
      'harus emit [loading, isEmailChecked: true] saat check-login mengizinkan login',
      build: () {
        when(mockCheckEmailUseCase.call(
          tEmail,
          recaptchaToken: tRecaptchaToken,
        )).thenAnswer((_) async => const Right(CheckEmailModel(
              allowedLogin: true,
              email: tEmail,
            )));
        return bloc;
      },
      seed: () => const LoginState(username: tEmail, isEmailChecked: false),
      act: (b) => b.add(const LoginButtonPressedEvent()),
      expect: () => [
        isA<LoginState>()
            .having((s) => s.status, 'status', RequestStatus.loading),
        isA<LoginState>()
            .having((s) => s.status, 'status', RequestStatus.empty)
            .having((s) => s.isEmailChecked, 'isEmailChecked', isTrue)
            .having((s) => s.usernameErrorMessage, 'usernameError', ''),
      ],
    );

    blocTest<LoginBloc, LoginState>(
      'harus emit isAccountBanned saat akun dibanned',
      build: () {
        when(mockCheckEmailUseCase.call(
          tEmail,
          recaptchaToken: tRecaptchaToken,
        )).thenAnswer((_) async => const Right(CheckEmailModel(
              allowedLogin: false,
              banned: true,
            )));
        return bloc;
      },
      seed: () => const LoginState(username: tEmail, isEmailChecked: false),
      act: (b) => b.add(const LoginButtonPressedEvent()),
      expect: () => [
        isA<LoginState>()
            .having((s) => s.status, 'status', RequestStatus.loading),
        isA<LoginState>()
            .having((s) => s.isAccountBanned, 'isAccountBanned', isTrue)
            .having((s) => s.status, 'status', RequestStatus.empty),
      ],
    );

    blocTest<LoginBloc, LoginState>(
      'harus emit isVerificationRequired beserta unverifiedProducts saat butuh verifikasi',
      build: () {
        const products = [
          PartnerProductModel(id: 1, productName: 'Komship', isVerified: false),
        ];
        when(mockCheckEmailUseCase.call(
          tEmail,
          recaptchaToken: tRecaptchaToken,
        )).thenAnswer((_) async => const Right(CheckEmailModel(
              allowedLogin: false,
              partnerProducts: products,
            )));
        return bloc;
      },
      seed: () => const LoginState(username: tEmail, isEmailChecked: false),
      act: (b) => b.add(const LoginButtonPressedEvent()),
      expect: () => [
        isA<LoginState>()
            .having((s) => s.status, 'status', RequestStatus.loading),
        isA<LoginState>()
            .having((s) => s.isVerificationRequired, 'verifRequired', isTrue)
            .having((s) => s.unverifiedProducts.length, 'products count', 1),
      ],
    );

    blocTest<LoginBloc, LoginState>(
      'harus emit failure saat reCAPTCHA gagal pada check-login',
      build: () {
        when(mockRecaptchaUseCase.getToken(any)).thenThrow(Exception('fail'));
        return bloc;
      },
      seed: () => const LoginState(username: tEmail, isEmailChecked: false),
      act: (b) => b.add(const LoginButtonPressedEvent()),
      expect: () => [
        isA<LoginState>()
            .having((s) => s.status, 'status', RequestStatus.loading),
        isA<LoginState>()
            .having((s) => s.status, 'status', RequestStatus.failure)
            .having(
              (s) => s.usernameErrorMessage,
              'recaptcha error',
              'Verifikasi keamanan gagal. Silakan coba lagi.',
            ),
      ],
    );
  });

  group('Partner Login Step (auth/partner/login)', () {
    const basePasswordState = LoginState(
      username: tEmail,
      password: tPassword,
      isEmailChecked: true,
    );

    blocTest<LoginBloc, LoginState>(
      'harus masuk ke stage selectMethod dengan token, masked email & phone saat pendingOtp null',
      build: () {
        when(mockPartnerLoginUseCase.call(
          tEmail,
          tPassword,
          recaptchaToken: tRecaptchaToken,
        )).thenAnswer((_) async => const Right(PartnerLoginModel(
              token: tLoginToken,
              email: tMaskedEmail,
              phone: tMaskedPhone,
              otpLimitExceeded: false,
            )));
        return bloc;
      },
      seed: () => basePasswordState,
      act: (b) => b.add(const LoginButtonPressedEvent()),
      expect: () => [
        isA<LoginState>()
            .having((s) => s.status, 'status', RequestStatus.loading),
        isA<LoginState>()
            .having((s) => s.status, 'status', RequestStatus.empty)
            .having((s) => s.twoFaStage, 'stage', LoginTwoFaStage.selectMethod)
            .having((s) => s.loginToken, 'loginToken', tLoginToken)
            .having((s) => s.twoFaEmail, 'twoFaEmail', tMaskedEmail)
            .having((s) => s.twoFaPhone, 'twoFaPhone', tMaskedPhone)
            .having((s) => s.otpLimitExceeded, 'otpLimitExceeded', isFalse),
      ],
    );

    blocTest<LoginBloc, LoginState>(
      'harus masuk ke stage selectMethod dengan otpLimitExceeded: true saat limit request OTP tercapai',
      build: () {
        when(mockPartnerLoginUseCase.call(
          tEmail,
          tPassword,
          recaptchaToken: tRecaptchaToken,
        )).thenAnswer((_) async => const Right(PartnerLoginModel(
              token: tLoginToken,
              email: tMaskedEmail,
              phone: tMaskedPhone,
              otpLimitExceeded: true,
            )));
        return bloc;
      },
      seed: () => basePasswordState,
      act: (b) => b.add(const LoginButtonPressedEvent()),
      expect: () => [
        isA<LoginState>()
            .having((s) => s.status, 'status', RequestStatus.loading),
        isA<LoginState>()
            .having((s) => s.twoFaStage, 'stage', LoginTwoFaStage.selectMethod)
            .having((s) => s.otpLimitExceeded, 'otpLimitExceeded', isTrue)
            .having((s) => s.loginToken, 'loginToken', tLoginToken),
      ],
    );

    blocTest<LoginBloc, LoginState>(
      'harus langsung masuk ke stage verifyOtp dengan whatsapp saat pendingOtp bertipe wa',
      build: () {
        when(mockPartnerLoginUseCase.call(
          tEmail,
          tPassword,
          recaptchaToken: tRecaptchaToken,
        )).thenAnswer((_) async => const Right(PartnerLoginModel(
              token: tLoginToken,
              email: tMaskedEmail,
              phone: tMaskedPhone,
              pendingOtp: PendingOtpModel(
                token: tOtpToken,
                expiresIn: 45,
                typeToken: 'WA',
              ),
            )));
        return bloc;
      },
      seed: () => basePasswordState,
      act: (b) => b.add(const LoginButtonPressedEvent()),
      expect: () => [
        isA<LoginState>()
            .having((s) => s.status, 'status', RequestStatus.loading),
        isA<LoginState>()
            .having((s) => s.status, 'status', RequestStatus.empty)
            .having((s) => s.twoFaStage, 'stage', LoginTwoFaStage.verifyOtp)
            .having((s) => s.loginToken, 'loginToken', tLoginToken)
            .having((s) => s.otpToken, 'otpToken', tOtpToken)
            .having(
              (s) => s.selectedMethod,
              'selectedMethod',
              TwoFaMethodType.whatsapp,
            )
            .having((s) => s.otpExpiresIn, 'otpExpiresIn', 45)
            .having((s) => s.otpCountdownKey, 'otpCountdownKey', 1),
      ],
    );

    blocTest<LoginBloc, LoginState>(
      'harus langsung masuk ke stage verifyOtp dengan sms saat pendingOtp bertipe sms',
      build: () {
        when(mockPartnerLoginUseCase.call(
          tEmail,
          tPassword,
          recaptchaToken: tRecaptchaToken,
        )).thenAnswer((_) async => const Right(PartnerLoginModel(
              token: tLoginToken,
              email: tMaskedEmail,
              phone: tMaskedPhone,
              pendingOtp: PendingOtpModel(
                token: tOtpToken,
                expiresIn: 59,
                typeToken: 'sms',
              ),
            )));
        return bloc;
      },
      seed: () => basePasswordState,
      act: (b) => b.add(const LoginButtonPressedEvent()),
      expect: () => [
        isA<LoginState>()
            .having((s) => s.status, 'status', RequestStatus.loading),
        isA<LoginState>()
            .having((s) => s.twoFaStage, 'stage', LoginTwoFaStage.verifyOtp)
            .having(
              (s) => s.selectedMethod,
              'selectedMethod',
              TwoFaMethodType.sms,
            ),
      ],
    );

    blocTest<LoginBloc, LoginState>(
      'harus emit failure bila response sukses tidak memiliki loginToken dan pendingOtp (Edge Path)',
      build: () {
        when(mockPartnerLoginUseCase.call(
          tEmail,
          tPassword,
          recaptchaToken: tRecaptchaToken,
        )).thenAnswer((_) async => const Right(PartnerLoginModel(
              token: '',
              otpLimitExceeded: false,
            )));
        return bloc;
      },
      seed: () => basePasswordState,
      act: (b) => b.add(const LoginButtonPressedEvent()),
      expect: () => [
        isA<LoginState>()
            .having((s) => s.status, 'status', RequestStatus.loading),
        isA<LoginState>()
            .having((s) => s.status, 'status', RequestStatus.failure)
            .having(
              (s) => s.passwordErrorMessage,
              'passwordErrorMessage',
              'Respons login tidak memuat sesi yang valid.',
            ),
      ],
    );

    blocTest<LoginBloc, LoginState>(
      'harus emit status empty + usernameErrorMessage inline saat PartnerLoginFailure userNotFound',
      build: () {
        when(mockPartnerLoginUseCase.call(
          tEmail,
          tPassword,
          recaptchaToken: tRecaptchaToken,
        )).thenAnswer((_) async => const Left(PartnerLoginFailure(
              'user not found',
              errorType: PartnerLoginErrorType.userNotFound,
            )));
        return bloc;
      },
      seed: () => basePasswordState,
      act: (b) => b.add(const LoginButtonPressedEvent()),
      expect: () => [
        isA<LoginState>()
            .having((s) => s.status, 'status', RequestStatus.loading),
        isA<LoginState>()
            .having((s) => s.status, 'status', RequestStatus.empty)
            .having(
              (s) => s.partnerLoginErrorType,
              'errorType',
              PartnerLoginErrorType.userNotFound,
            )
            .having(
              (s) => s.usernameErrorMessage,
              'usernameErrorMessage',
              'Email belum terdaftar',
            )
            .having((s) => s.twoFaStage, 'stage', LoginTwoFaStage.none),
      ],
    );

    blocTest<LoginBloc, LoginState>(
      'harus masuk ke stage otpLocked24Hours accountRestricted saat PartnerLoginFailure otpLocked24Hours',
      build: () {
        when(mockPartnerLoginUseCase.call(
          tEmail,
          tPassword,
          recaptchaToken: tRecaptchaToken,
        )).thenAnswer((_) async => const Left(PartnerLoginFailure(
              'Please wait 24 hours to login!',
              errorType: PartnerLoginErrorType.otpLocked24Hours,
              lock: 1,
              lockSource: 'otp',
            )));
        return bloc;
      },
      seed: () => basePasswordState,
      act: (b) => b.add(const LoginButtonPressedEvent()),
      expect: () => [
        isA<LoginState>()
            .having((s) => s.status, 'status', RequestStatus.loading),
        isA<LoginState>()
            .having((s) => s.status, 'status', RequestStatus.empty)
            .having(
              (s) => s.twoFaStage,
              'stage',
              LoginTwoFaStage.otpLocked24Hours,
            )
            .having(
              (s) => s.twoFaLockedVariant,
              'variant',
              TwoFaLockedVariant.accountRestricted,
            )
            .having(
              (s) => s.partnerLoginErrorType,
              'errorType',
              PartnerLoginErrorType.otpLocked24Hours,
            ),
      ],
    );

    blocTest<LoginBloc, LoginState>(
      'harus emit failure dengan loginAttemptsLeft saat PartnerLoginFailure incorrectPassword',
      build: () {
        when(mockPartnerLoginUseCase.call(
          tEmail,
          tPassword,
          recaptchaToken: tRecaptchaToken,
        )).thenAnswer((_) async => const Left(PartnerLoginFailure(
              'Incorrect Password',
              errorType: PartnerLoginErrorType.incorrectPassword,
              loginAttempt: 2,
            )));
        return bloc;
      },
      seed: () => basePasswordState,
      act: (b) => b.add(const LoginButtonPressedEvent()),
      expect: () => [
        isA<LoginState>()
            .having((s) => s.status, 'status', RequestStatus.loading),
        isA<LoginState>()
            .having((s) => s.status, 'status', RequestStatus.failure)
            .having(
              (s) => s.partnerLoginErrorType,
              'errorType',
              PartnerLoginErrorType.incorrectPassword,
            )
            .having((s) => s.loginAttemptsLeft, 'loginAttemptsLeft', 2),
      ],
    );

    blocTest<LoginBloc, LoginState>(
      'harus emit failure saat PartnerLoginFailure passwordLocked24Hours',
      build: () {
        when(mockPartnerLoginUseCase.call(
          tEmail,
          tPassword,
          recaptchaToken: tRecaptchaToken,
        )).thenAnswer((_) async => const Left(PartnerLoginFailure(
              'Please wait 24 hours to login!',
              errorType: PartnerLoginErrorType.passwordLocked24Hours,
              loginAttempt: 0,
              lock: 1,
            )));
        return bloc;
      },
      seed: () => basePasswordState,
      act: (b) => b.add(const LoginButtonPressedEvent()),
      expect: () => [
        isA<LoginState>()
            .having((s) => s.status, 'status', RequestStatus.loading),
        isA<LoginState>()
            .having((s) => s.status, 'status', RequestStatus.failure)
            .having(
              (s) => s.partnerLoginErrorType,
              'errorType',
              PartnerLoginErrorType.passwordLocked24Hours,
            )
            .having((s) => s.loginAttemptsLeft, 'loginAttemptsLeft', 0),
      ],
    );

    blocTest<LoginBloc, LoginState>(
      'harus meneruskan pesan error Team Internal dan Non Partner lewat RequestStatus.failure',
      build: () {
        when(mockPartnerLoginUseCase.call(
          tEmail,
          tPassword,
          recaptchaToken: tRecaptchaToken,
        )).thenAnswer((_) async => const Left(ServerFailure(
              'ERR_ROLE_TEAM_INTERNAL_BLOCKED: Akses ditolak',
            )));
        return bloc;
      },
      seed: () => basePasswordState,
      act: (b) => b.add(const LoginButtonPressedEvent()),
      expect: () => [
        isA<LoginState>()
            .having((s) => s.status, 'status', RequestStatus.loading),
        isA<LoginState>()
            .having((s) => s.status, 'status', RequestStatus.failure)
            .having((s) => s.partnerLoginErrorType, 'errorType', isNull)
            .having(
              (s) => s.passwordErrorMessage,
              'passwordErrorMessage',
              contains('ERR_ROLE_TEAM_INTERNAL_BLOCKED'),
            ),
      ],
    );
  });

  group('Request OTP Method Step (v2/otp/request)', () {
    const selectMethodState = LoginState(
      username: tEmail,
      isEmailChecked: true,
      twoFaStage: LoginTwoFaStage.selectMethod,
      loginToken: tLoginToken,
      twoFaEmail: tMaskedEmail,
      twoFaPhone: tMaskedPhone,
    );

    blocTest<LoginBloc, LoginState>(
      'harus transisi ke verifyOtp, menjaga loginToken tetap utuh, dan set otpToken baru',
      build: () {
        when(mockRequestLoginOtpUseCase.call(
          tLoginToken,
          'whatsapp',
          recaptchaToken: tRecaptchaToken,
        )).thenAnswer((_) async => const Right(RequestLoginOtpModel(
              token: tOtpToken,
              expiresIn: 59,
              email: tMaskedEmail,
              phone: tMaskedPhone,
              otpLimitExceeded: false,
            )));
        return bloc;
      },
      seed: () => selectMethodState,
      act: (b) =>
          b.add(const LoginTwoFaMethodSelectedEvent(TwoFaMethodType.whatsapp)),
      expect: () => [
        isA<LoginState>()
            .having((s) => s.isRequestingOtp, 'isRequestingOtp', isTrue)
            .having((s) => s.twoFaActionErrorMessage, 'actionError', isNull),
        isA<LoginState>()
            .having((s) => s.isRequestingOtp, 'isRequestingOtp', isFalse)
            .having((s) => s.twoFaStage, 'stage', LoginTwoFaStage.verifyOtp)
            .having((s) => s.loginToken, 'loginToken preserved', tLoginToken)
            .having((s) => s.otpToken, 'otpToken updated', tOtpToken)
            .having(
              (s) => s.selectedMethod,
              'selectedMethod',
              TwoFaMethodType.whatsapp,
            )
            .having((s) => s.otpExpiresIn, 'otpExpiresIn', 59)
            .having((s) => s.otpCountdownKey, 'otpCountdownKey', 1),
      ],
    );

    blocTest<LoginBloc, LoginState>(
      'harus set twoFaActionErrorMessage dan tetap di selectMethod saat request OTP gagal',
      build: () {
        when(mockRequestLoginOtpUseCase.call(
          tLoginToken,
          'email',
          recaptchaToken: tRecaptchaToken,
        )).thenAnswer(
            (_) async => const Left(ServerFailure('Gagal kirim OTP')));
        return bloc;
      },
      seed: () => selectMethodState,
      act: (b) =>
          b.add(const LoginTwoFaMethodSelectedEvent(TwoFaMethodType.email)),
      expect: () => [
        isA<LoginState>()
            .having((s) => s.isRequestingOtp, 'isRequestingOtp', isTrue),
        isA<LoginState>()
            .having((s) => s.isRequestingOtp, 'isRequestingOtp', isFalse)
            .having((s) => s.twoFaStage, 'stage', LoginTwoFaStage.selectMethod)
            .having((s) => s.status, 'status stays empty', RequestStatus.empty)
            .having(
              (s) => s.twoFaActionErrorMessage,
              'actionError',
              'Gagal kirim OTP',
            ),
      ],
    );
  });

  group('Resend OTP Step (v2/otp/request)', () {
    const verifyOtpState = LoginState(
      username: tEmail,
      isEmailChecked: true,
      twoFaStage: LoginTwoFaStage.verifyOtp,
      loginToken: tLoginToken,
      otpToken: 'old-otp-token',
      twoFaEmail: tMaskedEmail,
      twoFaPhone: tMaskedPhone,
      selectedMethod: TwoFaMethodType.sms,
      otpExpiresIn: 59,
      otpCountdownKey: 1,
    );

    blocTest<LoginBloc, LoginState>(
      'harus memperbarui otpToken dan menaikkan otpCountdownKey saat resend sukses',
      build: () {
        when(mockRequestLoginOtpUseCase.call(
          tLoginToken,
          'sms',
          recaptchaToken: tRecaptchaToken,
        )).thenAnswer((_) async => const Right(RequestLoginOtpModel(
              token: 'new-otp-token',
              expiresIn: 59,
              otpLimitExceeded: false,
            )));
        return bloc;
      },
      seed: () => verifyOtpState,
      act: (b) => b.add(const LoginOtpResendRequestedEvent()),
      expect: () => [
        isA<LoginState>()
            .having((s) => s.isResendingOtp, 'isResendingOtp', isTrue),
        isA<LoginState>()
            .having((s) => s.isResendingOtp, 'isResendingOtp', isFalse)
            .having((s) => s.loginToken, 'loginToken preserved', tLoginToken)
            .having((s) => s.otpToken, 'otpToken updated', 'new-otp-token')
            .having((s) => s.otpExpiresIn, 'otpExpiresIn', 59)
            .having((s) => s.otpCountdownKey, 'otpCountdownKey', 2),
      ],
    );

    blocTest<LoginBloc, LoginState>(
      'harus set otpLimitExceeded: true dan otpExpiresIn: 0 saat resend melewati batas',
      build: () {
        when(mockRequestLoginOtpUseCase.call(
          tLoginToken,
          'sms',
          recaptchaToken: tRecaptchaToken,
        )).thenAnswer((_) async => const Right(RequestLoginOtpModel(
              token: 'new-otp-token',
              expiresIn: 0,
              otpLimitExceeded: true,
            )));
        return bloc;
      },
      seed: () => verifyOtpState,
      act: (b) => b.add(const LoginOtpResendRequestedEvent()),
      expect: () => [
        isA<LoginState>()
            .having((s) => s.isResendingOtp, 'isResendingOtp', isTrue),
        isA<LoginState>()
            .having((s) => s.isResendingOtp, 'isResendingOtp', isFalse)
            .having((s) => s.otpLimitExceeded, 'otpLimitExceeded', isTrue)
            .having((s) => s.otpExpiresIn, 'otpExpiresIn', 0)
            .having((s) => s.otpCountdownKey, 'countdownKey unchanged', 1),
      ],
    );

    blocTest<LoginBloc, LoginState>(
      'harus set otpErrorMessage dan tidak mengubah otpCountdownKey saat resend gagal',
      build: () {
        when(mockRequestLoginOtpUseCase.call(
          tLoginToken,
          'sms',
          recaptchaToken: tRecaptchaToken,
        )).thenAnswer(
            (_) async => const Left(ConnectionFailure('Koneksi bermasalah')));
        return bloc;
      },
      seed: () => verifyOtpState,
      act: (b) => b.add(const LoginOtpResendRequestedEvent()),
      expect: () => [
        isA<LoginState>()
            .having((s) => s.isResendingOtp, 'isResendingOtp', isTrue),
        isA<LoginState>()
            .having((s) => s.isResendingOtp, 'isResendingOtp', isFalse)
            .having((s) => s.otpErrorMessage, 'otpError', 'Koneksi bermasalah')
            .having((s) => s.otpCountdownKey, 'countdownKey unchanged', 1)
            .having((s) => s.isOtpLocked, 'not locked', isFalse),
      ],
    );
  });

  group('Verify OTP Step (v2/otp/verify-login)', () {
    const verifyOtpState = LoginState(
      username: tEmail,
      isEmailChecked: true,
      twoFaStage: LoginTwoFaStage.verifyOtp,
      loginToken: tLoginToken,
      otpToken: tOtpToken,
      twoFaEmail: tMaskedEmail,
      twoFaPhone: tMaskedPhone,
      selectedMethod: TwoFaMethodType.email,
      otpExpiresIn: 59,
      otpCountdownKey: 1,
    );

    blocTest<LoginBloc, LoginState>(
      'harus validasi OTP kurang dari 6 digit tanpa memanggil VerifyLoginOtpUseCase',
      build: () => bloc,
      seed: () => verifyOtpState,
      act: (b) => b.add(const LoginOtpSubmittedEvent('123')),
      expect: () => [
        isA<LoginState>()
            .having((s) => s.otpErrorMessage, 'error', 'Kode OTP harus 6 digit.'),
      ],
      verify: (_) {
        verifyNever(mockVerifyLoginOtpUseCase.call(
          any,
          any,
          recaptchaToken: anyNamed('recaptchaToken'),
        ));
      },
    );

    blocTest<LoginBloc, LoginState>(
      'harus emit RequestStatus.success dan reset semua state 2FA saat verify OTP + profile sync sukses',
      build: () {
        when(mockVerifyLoginOtpUseCase.call(
          tOtpToken,
          '123456',
          recaptchaToken: tRecaptchaToken,
        )).thenAnswer(
            (_) async => const Right(VerifyLoginOtpModel(jwtToken: 'jwt-ok')));
        return bloc;
      },
      seed: () => verifyOtpState,
      act: (b) => b.add(const LoginOtpSubmittedEvent('123456')),
      expect: () => [
        isA<LoginState>()
            .having((s) => s.isVerifyingOtp, 'isVerifyingOtp', isTrue),
        isA<LoginState>()
            .having((s) => s.isVerifyingOtp, 'isVerifyingOtp', isFalse)
            .having((s) => s.status, 'status', RequestStatus.success)
            .having((s) => s.twoFaStage, 'stage reset', LoginTwoFaStage.none)
            .having((s) => s.loginToken, 'loginToken cleared', '')
            .having((s) => s.otpToken, 'otpToken cleared', ''),
      ],
      verify: (_) {
        final captured =
            verify(mockRecaptchaUseCase.getToken(captureAny)).captured;
        expect(
          (captured.single as RecaptchaAction).action,
          'VERIFY_OTP',
        );
      },
    );

    blocTest<LoginBloc, LoginState>(
      'harus emit otpAttemptsLeft: 2 dan tetap di verifyOtp saat VerifyOtpFailure.otpInvalid',
      build: () {
        when(mockVerifyLoginOtpUseCase.call(
          tOtpToken,
          '123455',
          recaptchaToken: tRecaptchaToken,
        )).thenAnswer((_) async => const Left(VerifyOtpFailure(
              'OTP not valid',
              errorType: VerifyOtpErrorType.otpInvalid,
              attemptLeft: 2,
              lock: 0,
            )));
        return bloc;
      },
      seed: () => verifyOtpState,
      act: (b) => b.add(const LoginOtpSubmittedEvent('123455')),
      expect: () => [
        isA<LoginState>()
            .having((s) => s.isVerifyingOtp, 'isVerifyingOtp', isTrue),
        isA<LoginState>()
            .having((s) => s.isVerifyingOtp, 'isVerifyingOtp', isFalse)
            .having((s) => s.twoFaStage, 'stage', LoginTwoFaStage.verifyOtp)
            .having((s) => s.otpAttemptsLeft, 'attemptsLeft', 2)
            .having((s) => s.isOtpLocked, 'isOtpLocked', isFalse),
      ],
    );

    blocTest<LoginBloc, LoginState>(
      'harus transisi ke otpLocked24Hours otpVerificationFailed saat VerifyOtpFailure.otpInvalidLocked',
      build: () {
        when(mockVerifyLoginOtpUseCase.call(
          tOtpToken,
          '123455',
          recaptchaToken: tRecaptchaToken,
        )).thenAnswer((_) async => const Left(VerifyOtpFailure(
              'OTP not valid',
              errorType: VerifyOtpErrorType.otpInvalidLocked,
              attemptLeft: 0,
              lock: 1,
            )));
        return bloc;
      },
      seed: () => verifyOtpState,
      act: (b) => b.add(const LoginOtpSubmittedEvent('123455')),
      expect: () => [
        isA<LoginState>()
            .having((s) => s.isVerifyingOtp, 'isVerifyingOtp', isTrue),
        isA<LoginState>()
            .having((s) => s.isVerifyingOtp, 'isVerifyingOtp', isFalse)
            .having(
              (s) => s.twoFaStage,
              'stage',
              LoginTwoFaStage.otpLocked24Hours,
            )
            .having(
              (s) => s.twoFaLockedVariant,
              'variant',
              TwoFaLockedVariant.otpVerificationFailed,
            )
            .having((s) => s.isOtpLocked, 'isOtpLocked', isTrue),
      ],
    );

    blocTest<LoginBloc, LoginState>(
      'harus set isOtpSessionExpired & isOtpLocked saat VerifyOtpFailure.expiredToken',
      build: () {
        when(mockVerifyLoginOtpUseCase.call(
          tOtpToken,
          '123455',
          recaptchaToken: tRecaptchaToken,
        )).thenAnswer((_) async => const Left(VerifyOtpFailure(
              'Expired token',
              errorType: VerifyOtpErrorType.expiredToken,
              lock: 0,
            )));
        return bloc;
      },
      seed: () => verifyOtpState,
      act: (b) => b.add(const LoginOtpSubmittedEvent('123455')),
      expect: () => [
        isA<LoginState>()
            .having((s) => s.isVerifyingOtp, 'isVerifyingOtp', isTrue),
        isA<LoginState>()
            .having((s) => s.isVerifyingOtp, 'isVerifyingOtp', isFalse)
            .having((s) => s.twoFaStage, 'stage stays verifyOtp',
                LoginTwoFaStage.verifyOtp)
            .having((s) => s.isOtpSessionExpired, 'isOtpSessionExpired', isTrue)
            .having((s) => s.isOtpLocked, 'isOtpLocked', isTrue),
      ],
    );

    blocTest<LoginBloc, LoginState>(
      'harus set otpErrorMessage saat completeTwoFaSession atau jaringan gagal (Edge Path)',
      build: () {
        when(mockVerifyLoginOtpUseCase.call(
          tOtpToken,
          '123456',
          recaptchaToken: tRecaptchaToken,
        )).thenAnswer((_) async => const Left(ServerFailure('Gagal sinkron profil')));
        return bloc;
      },
      seed: () => verifyOtpState,
      act: (b) => b.add(const LoginOtpSubmittedEvent('123456')),
      expect: () => [
        isA<LoginState>()
            .having((s) => s.isVerifyingOtp, 'isVerifyingOtp', isTrue),
        isA<LoginState>()
            .having((s) => s.isVerifyingOtp, 'isVerifyingOtp', isFalse)
            .having((s) => s.status, 'status stays empty', RequestStatus.empty)
            .having(
              (s) => s.otpErrorMessage,
              'otpErrorMessage',
              'Gagal sinkron profil',
            ),
      ],
    );
  });

  group('Change Method, Dismiss, dan Cancellation Guard', () {
    const activeVerifyState = LoginState(
      username: tEmail,
      isEmailChecked: true,
      twoFaStage: LoginTwoFaStage.verifyOtp,
      loginToken: tLoginToken,
      otpToken: tOtpToken,
      twoFaEmail: tMaskedEmail,
      twoFaPhone: tMaskedPhone,
      selectedMethod: TwoFaMethodType.sms,
      otpAttemptsLeft: 2,
      otpErrorMessage: 'Old error',
      isOtpSessionExpired: true,
      isOtpLocked: true,
      otpLimitExceeded: true,
    );

    blocTest<LoginBloc, LoginState>(
      'LoginTwoFaChangeMethodRequestedEvent kembali ke selectMethod dengan loginToken & otpLimitExceeded terjaga',
      build: () => bloc,
      seed: () => activeVerifyState,
      act: (b) => b.add(const LoginTwoFaChangeMethodRequestedEvent()),
      expect: () => [
        isA<LoginState>()
            .having((s) => s.twoFaStage, 'stage', LoginTwoFaStage.selectMethod)
            .having((s) => s.loginToken, 'loginToken preserved', tLoginToken)
            .having((s) => s.otpLimitExceeded, 'limit preserved', isTrue)
            .having((s) => s.selectedMethod, 'selected preserved',
                TwoFaMethodType.sms)
            .having((s) => s.otpAttemptsLeft, 'attempts cleared', isNull)
            .having((s) => s.otpErrorMessage, 'error cleared', isNull)
            .having((s) => s.isOtpSessionExpired, 'expired cleared', isFalse)
            .having((s) => s.isOtpLocked, 'locked cleared', isFalse),
      ],
    );

    blocTest<LoginBloc, LoginState>(
      'LoginTwoFaDismissedEvent harus reset seluruh state 2FA ke none',
      build: () => bloc,
      seed: () => activeVerifyState,
      act: (b) => b.add(const LoginTwoFaDismissedEvent()),
      expect: () => [
        isA<LoginState>()
            .having((s) => s.twoFaStage, 'stage', LoginTwoFaStage.none)
            .having((s) => s.loginToken, 'loginToken', '')
            .having((s) => s.otpToken, 'otpToken', '')
            .having((s) => s.selectedMethod, 'selectedMethod', isNull)
            .having((s) => s.otpLimitExceeded, 'otpLimitExceeded', isFalse),
      ],
    );

    test('response requestLoginOtp yang terlambat diabaikan setelah dismissed',
        () async {
      final completer =
          Completer<Either<Failure, RequestLoginOtpModel>>();
      when(mockRequestLoginOtpUseCase.call(
        tLoginToken,
        'email',
        recaptchaToken: tRecaptchaToken,
      )).thenAnswer((_) => completer.future);

      bloc.add(const LoginEmailPrecheckedEvent(tEmail));
      await bloc.stream.firstWhere((s) => s.isEmailChecked);

      when(mockPartnerLoginUseCase.call(
        tEmail,
        tPassword,
        recaptchaToken: tRecaptchaToken,
      )).thenAnswer((_) async => const Right(PartnerLoginModel(
            token: tLoginToken,
            email: tMaskedEmail,
          )));

      bloc.add(const LoginPasswordChangedEvent(password: tPassword));
      await bloc.stream.firstWhere((s) => s.password == tPassword);
      bloc.add(const LoginButtonPressedEvent());
      await bloc.stream
          .firstWhere((s) => s.twoFaStage == LoginTwoFaStage.selectMethod);

      bloc.add(const LoginTwoFaMethodSelectedEvent(TwoFaMethodType.email));
      await bloc.stream.firstWhere((s) => s.isRequestingOtp);

      bloc.add(const LoginTwoFaDismissedEvent());
      await bloc.stream
          .firstWhere((s) => s.twoFaStage == LoginTwoFaStage.none);

      completer.complete(const Right(RequestLoginOtpModel(
        token: 'late-otp-token',
        expiresIn: 59,
      )));
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.twoFaStage, LoginTwoFaStage.none);
      expect(bloc.state.otpToken, '');
    });
  });
}

