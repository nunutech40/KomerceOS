import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komtim_partner/common/failure.dart';
import 'package:komtim_partner/core/domain/entities/partner_login_model.dart';
import 'package:komtim_partner/core/domain/entities/request_login_otp_model.dart';
import 'package:komtim_partner/core/domain/entities/two_fa_failure.dart';
import 'package:komtim_partner/core/domain/entities/verify_login_otp_model.dart';
import 'package:komtim_partner/features/superapp/features/authentication/bloc/login_bloc.dart';
import 'package:komtim_partner/features/superapp/features/authentication/views/login_page.dart';
import 'package:komtim_partner/features/superapp/features/authentication/widgets/two_fa_locked_bottom_sheet.dart';
import 'package:komtim_partner/features/superapp/features/authentication/widgets/two_fa_method_bottom_sheet.dart';
import 'package:komtim_partner/features/superapp/features/authentication/widgets/two_fa_verify_otp_bottom_sheet.dart';
import 'package:mockito/mockito.dart';

import '../../../../helpers/mocks/mocks.dart';

void main() {
  late MockCheckEmailLoginUseCase mockCheckEmailUseCase;
  late MockPartnerLoginUseCase mockPartnerLoginUseCase;
  late MockRequestLoginOtpUseCase mockRequestLoginOtpUseCase;
  late MockVerifyLoginOtpUseCase mockVerifyLoginOtpUseCase;
  late MockRecaptchaUseCase mockRecaptchaUseCase;

  const tEmail = 'gerry@komerce.id';
  const tPassword = 'Password123!';
  const tRecaptchaToken = 'recaptcha-ok';
  const tLoginToken = 'login-token-1';
  const tOtpToken = 'otp-token-1';
  const tMaskedEmail = 'ger***@g*****com';
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
  });

  Future<LoginBloc> pumpLoginPage(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final bloc = LoginBloc(
      checkEmailLoginUseCase: mockCheckEmailUseCase,
      partnerLoginUseCase: mockPartnerLoginUseCase,
      requestLoginOtpUseCase: mockRequestLoginOtpUseCase,
      verifyLoginOtpUseCase: mockVerifyLoginOtpUseCase,
      recaptchaUseCase: mockRecaptchaUseCase,
    );
    addTearDown(() {
      if (!bloc.isClosed) {
        unawaited(bloc.close());
      }
    });

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<LoginBloc>(
          create: (_) => bloc,
          child: const LoginPage(email: tEmail),
        ),
      ),
    );
    await tester.pump();
    return bloc;
  }

  Future<void> enterPasswordAndSubmit(WidgetTester tester) async {
    final fields = find.byType(TextField);
    final passwordField = fields.at(1);
    await tester.tap(passwordField);
    await tester.pump();
    for (int i = 1; i <= tPassword.length; i++) {
      await tester.enterText(passwordField, tPassword.substring(0, i));
    }
    await tester.pump();
    await tester.tap(find.text('Masuk'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
  }

  group('LoginPage 2FA UI Flow', () {
    testWidgets(
      'flow lengkap: partner/login -> pilih metode -> gagal resend tetap bisa klik ulang -> salah OTP -> lock 24 jam -> Mengerti menutup sheet',
      (tester) async {
        when(mockPartnerLoginUseCase.call(
          tEmail,
          tPassword,
          recaptchaToken: tRecaptchaToken,
        )).thenAnswer((_) async => const Right(PartnerLoginModel(
              token: tLoginToken,
              email: tMaskedEmail,
              phone: tMaskedPhone,
            )));

        when(mockRequestLoginOtpUseCase.call(
          tLoginToken,
          'email',
          recaptchaToken: tRecaptchaToken,
        )).thenAnswer((_) async => const Right(RequestLoginOtpModel(
              token: tOtpToken,
              expiresIn: 0,
              email: tMaskedEmail,
              phone: tMaskedPhone,
            )));

        await pumpLoginPage(tester);
        await enterPasswordAndSubmit(tester);

        // 1. Sheet pilih metode 2FA tampil
        expect(find.byType(TwoFaMethodBottomSheet), findsOneWidget);
        expect(find.text('Kirim Verifikasi OTP'), findsOneWidget);
        expect(find.text(tMaskedEmail), findsOneWidget);

        // Pilih Email lalu Konfirmasi
        await tester.tap(find.text('Email ke'));
        await tester.pump();
        await tester.tap(find.text('Konfirmasi'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        // 2. Transisi ke Verifikasi Kode OTP
        expect(find.byType(TwoFaVerifyOtpBottomSheet), findsOneWidget);
        expect(find.text('Verifikasi Kode OTP'), findsOneWidget);

        // 3. Resend gagal -> tampil error, Kirim Ulang tetap aktif tanpa restart timer
        when(mockRequestLoginOtpUseCase.call(
          tLoginToken,
          'email',
          recaptchaToken: tRecaptchaToken,
        )).thenAnswer(
            (_) async => const Left(ConnectionFailure('Koneksi gagal')));

        await tester.tap(find.text('Kirim Ulang'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.text('Koneksi gagal'), findsOneWidget);
        expect(find.text('Kirim Ulang'), findsOneWidget);

        // 4. Input OTP 6 digit salah (percobaan 1 -> sisa 2)
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

        final firstOtpBox = find
            .descendant(
              of: find.byType(TwoFaVerifyOtpBottomSheet),
              matching: find.byType(TextField),
            )
            .first;
        await tester.enterText(firstOtpBox, '123455');
        await tester.pump();

        await tester.tap(find.text('Konfirmasi'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(
          find.text(
            'Kode OTP yang kamu masukkan salah.\nTersisa 2 kali percobaan.',
          ),
          findsOneWidget,
        );

        // 5. Submit lagi saat salah ke-3 -> lock 24 jam
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

        await tester.tap(find.text('Konfirmasi'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(TwoFaLockedBottomSheet), findsOneWidget);
        expect(find.text('Verifikasi Kode OTP Gagal'), findsOneWidget);

        // 6. Tap Mengerti -> sheet tertutup
        await tester.tap(find.text('Mengerti'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        expect(find.byType(TwoFaLockedBottomSheet), findsNothing);
      },
    );

    testWidgets(
      'pendingOtp langsung membuka Verifikasi OTP dan OTP valid menutup sheet otomatis',
      (tester) async {
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
                expiresIn: 0,
                typeToken: 'whatsapp',
              ),
            )));

        when(mockVerifyLoginOtpUseCase.call(
          tOtpToken,
          '123456',
          recaptchaToken: tRecaptchaToken,
        )).thenAnswer(
            (_) async => const Right(VerifyLoginOtpModel(jwtToken: 'jwt-ok')));

        final bloc = await pumpLoginPage(tester);
        await enterPasswordAndSubmit(tester);

        expect(find.byType(TwoFaVerifyOtpBottomSheet), findsOneWidget);
        expect(
          find.text(
            'Masukkan Kode OTP WhatsApp yang kami\nkirimkan ke $tMaskedPhone',
          ),
          findsOneWidget,
        );

        final firstOtpBox = find
            .descendant(
              of: find.byType(TwoFaVerifyOtpBottomSheet),
              matching: find.byType(TextField),
            )
            .first;
        await tester.enterText(firstOtpBox, '123456');
        await tester.pump();

        await tester.tap(find.text('Konfirmasi'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        expect(find.byType(TwoFaVerifyOtpBottomSheet), findsNothing);
        expect(bloc.state.twoFaStage, LoginTwoFaStage.none);
      },
    );

    testWidgets(
      'userNotFound menampilkan error inline Email belum terdaftar tanpa popup, otpLocked24Hours membuka Akun Kamu Dibatasi!',
      (tester) async {
        when(mockPartnerLoginUseCase.call(
          tEmail,
          tPassword,
          recaptchaToken: tRecaptchaToken,
        )).thenAnswer((_) async => const Left(PartnerLoginFailure(
              'user not found',
              errorType: PartnerLoginErrorType.userNotFound,
            )));

        await pumpLoginPage(tester);
        await enterPasswordAndSubmit(tester);

        expect(find.text('Email belum terdaftar'), findsOneWidget);
        expect(find.text('Belum Ada Produk Terhubung'), findsNothing);
        expect(find.byType(TwoFaMethodBottomSheet), findsNothing);
        expect(find.byType(SnackBar), findsNothing);

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

        await tester.tap(find.text('Masuk'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));

        expect(find.byType(TwoFaLockedBottomSheet), findsOneWidget);
        expect(find.text('Akun Kamu Dibatasi!'), findsOneWidget);
        expect(find.text('Hubungi CS'), findsOneWidget);
      },
    );

    testWidgets(
      'Gunakan Metode Lain mereset input OTP dan menampilkan notice saat batas request OTP tercapai',
      (tester) async {
        when(mockPartnerLoginUseCase.call(
          tEmail,
          tPassword,
          recaptchaToken: tRecaptchaToken,
        )).thenAnswer((_) async => const Right(PartnerLoginModel(
              token: tLoginToken,
              email: tMaskedEmail,
              phone: tMaskedPhone,
            )));

        when(mockRequestLoginOtpUseCase.call(
          tLoginToken,
          'email',
          recaptchaToken: tRecaptchaToken,
        )).thenAnswer((_) async => const Right(RequestLoginOtpModel(
              token: tOtpToken,
              expiresIn: 0,
              email: tMaskedEmail,
              phone: tMaskedPhone,
            )));

        when(mockRequestLoginOtpUseCase.call(
          tLoginToken,
          'whatsapp',
          recaptchaToken: tRecaptchaToken,
        )).thenAnswer((_) async => const Right(RequestLoginOtpModel(
              token: 'otp-token-wa',
              expiresIn: 0,
              email: tMaskedEmail,
              phone: tMaskedPhone,
            )));

        await pumpLoginPage(tester);
        await enterPasswordAndSubmit(tester);

        // Pilih Email -> Verifikasi OTP Email
        await tester.tap(find.text('Email ke'));
        await tester.pump();
        await tester.tap(find.text('Konfirmasi'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        expect(find.byType(TwoFaVerifyOtpBottomSheet), findsOneWidget);

        // Ketik sebagian digit lalu pilih Gunakan Metode Lain
        final firstOtpBox = find
            .descendant(
              of: find.byType(TwoFaVerifyOtpBottomSheet),
              matching: find.byType(TextField),
            )
            .first;
        await tester.enterText(firstOtpBox, '1234');
        await tester.pump();

        await tester.tap(find.text('Gunakan Metode Lain'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        expect(find.byType(TwoFaMethodBottomSheet), findsOneWidget);

        // Pilih WhatsApp -> Verifikasi OTP WhatsApp, digit OTP lama ter-reset
        await tester.tap(find.text('WhatsApp Kode OTP ke'));
        await tester.pump();
        await tester.tap(find.text('Konfirmasi'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        expect(find.byType(TwoFaVerifyOtpBottomSheet), findsOneWidget);
        expect(
          find.text(
            'Masukkan Kode OTP WhatsApp yang kami\nkirimkan ke $tMaskedPhone',
          ),
          findsOneWidget,
        );
        final otpFieldAfterSwitch = tester.widget<TextField>(
          find
              .descendant(
                of: find.byType(TwoFaVerifyOtpBottomSheet),
                matching: find.byType(TextField),
              )
              .first,
        );
        expect(otpFieldAfterSwitch.controller?.text, isEmpty);

        // Resend berhasil tetapi backend menandai batas OTP tercapai -> tampil notice di Verify sheet
        when(mockRequestLoginOtpUseCase.call(
          tLoginToken,
          'whatsapp',
          recaptchaToken: tRecaptchaToken,
        )).thenAnswer((_) async => const Right(RequestLoginOtpModel(
              token: 'otp-token-wa',
              expiresIn: 0,
              email: tMaskedEmail,
              phone: tMaskedPhone,
              otpLimitExceeded: true,
            )));

        await tester.tap(find.text('Kirim Ulang'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.text('Request OTP sudah mencapai batas.'), findsOneWidget);

        // Kembali ke pilih metode -> notice batas juga tampil & Konfirmasi nonaktif
        await tester.tap(find.text('Gunakan Metode Lain'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
        expect(find.byType(TwoFaMethodBottomSheet), findsOneWidget);
        expect(find.text('Request OTP sudah mencapai batas.'), findsOneWidget);
      },
    );

    testWidgets(
      'incorrectPassword menampilkan sisa percobaan dan passwordLocked24Hours menampilkan tombol Reset Password',
      (tester) async {
        when(mockPartnerLoginUseCase.call(
          tEmail,
          tPassword,
          recaptchaToken: tRecaptchaToken,
        )).thenAnswer((_) async => const Left(PartnerLoginFailure(
              'Incorrect password',
              errorType: PartnerLoginErrorType.incorrectPassword,
              loginAttempt: 1,
            )));

        await pumpLoginPage(tester);
        await enterPasswordAndSubmit(tester);

        expect(find.text('Gagal Login'), findsOneWidget);
        expect(find.textContaining('Tersisa 1 kali'), findsOneWidget);
        await tester.tap(find.text('Coba Lagi'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        when(mockPartnerLoginUseCase.call(
          tEmail,
          tPassword,
          recaptchaToken: tRecaptchaToken,
        )).thenAnswer((_) async => const Left(PartnerLoginFailure(
              'Please wait 24 hours',
              errorType: PartnerLoginErrorType.passwordLocked24Hours,
              lock: 1,
              lockSource: 'password',
            )));

        await tester.tap(find.text('Masuk'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));

        expect(find.text('Gagal Login'), findsOneWidget);
        expect(find.text('Reset Password'), findsOneWidget);
      },
    );
  });
}

