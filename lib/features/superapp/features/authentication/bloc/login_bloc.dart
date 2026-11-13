import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:komtim_partner/common/enum_status.dart';
import 'package:komtim_partner/common/string.dart';
import 'package:komtim_partner/core/domain/entities/partner_login_model.dart';
import 'package:komtim_partner/core/domain/entities/partner_product_model.dart';
import 'package:komtim_partner/core/domain/entities/two_fa_failure.dart';
import 'package:komtim_partner/core/domain/usecases/check_email_login_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/partner_login_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/recaptcha_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/request_login_otp_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/verify_login_otp_use_case.dart';
import 'package:komtim_partner/features/superapp/features/authentication/widgets/two_fa_locked_bottom_sheet.dart';
import 'package:komtim_partner/features/superapp/features/authentication/widgets/two_fa_method_bottom_sheet.dart';
import 'package:recaptcha_enterprise_flutter/recaptcha_action.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  static const String _recaptchaActionCheckEmail = 'CHECK_EMAIL';
  static const String _recaptchaActionLogin = 'LOGIN';
  static const String _recaptchaActionRequestOtp = 'REQUEST_OTP';
  static const String _recaptchaActionVerifyOtp = 'VERIFY_OTP';

  final CheckEmailLoginUseCase checkEmailLoginUseCase;
  final PartnerLoginUseCase partnerLoginUseCase;
  final RequestLoginOtpUseCase requestLoginOtpUseCase;
  final VerifyLoginOtpUseCase verifyLoginOtpUseCase;
  final RecaptchaUseCase recaptchaUseCase;

  int _inputVersion = 0;
  int _twoFaSessionVersion = 0;

  LoginBloc({
    required this.checkEmailLoginUseCase,
    required this.partnerLoginUseCase,
    required this.requestLoginOtpUseCase,
    required this.verifyLoginOtpUseCase,
    required this.recaptchaUseCase,
  }) : super(const LoginState()) {
    on<LoginButtonPressedEvent>(_handleLoginWithUsernameAndPasswordEvent,
        transformer: droppable());
    on<LoginEmailChangedEvent>(_handleLoginUsernameChangedEvent);
    on<LoginPasswordChangedEvent>(_handleLoginPasswordChangedEvent);
    on<LoginStatusResetEvent>(_handleStatusResetEvent);
    on<LoginEmailPrecheckedEvent>(_handleEmailPrecheckedEvent);
    on<LoginTwoFaMethodSelectedEvent>(_handleTwoFaMethodSelectedEvent,
        transformer: droppable());
    on<LoginOtpResendRequestedEvent>(_handleOtpResendRequestedEvent,
        transformer: droppable());
    on<LoginOtpSubmittedEvent>(_handleOtpSubmittedEvent,
        transformer: droppable());
    on<LoginTwoFaChangeMethodRequestedEvent>(_handleTwoFaChangeMethodRequested);
    on<LoginTwoFaDismissedEvent>(_handleTwoFaDismissed);
  }

  LoginState _resetTwoFaFields(LoginState baseState) {
    return baseState.copyWith(
      twoFaStage: LoginTwoFaStage.none,
      loginToken: '',
      otpToken: '',
      twoFaEmail: '',
      twoFaPhone: '',
      selectedMethod: null,
      otpExpiresIn: 0,
      otpLimitExceeded: false,
      otpAttemptsLeft: null,
      otpErrorMessage: null,
      isOtpSessionExpired: false,
      isOtpLocked: false,
      isRequestingOtp: false,
      isResendingOtp: false,
      isVerifyingOtp: false,
      twoFaActionErrorMessage: null,
      twoFaLockedVariant: null,
    );
  }

  Future<void> _handleEmailPrecheckedEvent(
    LoginEmailPrecheckedEvent event,
    Emitter<LoginState> emit,
  ) async {
    _inputVersion++;
    _twoFaSessionVersion++;
    emit(_resetTwoFaFields(state.copyWith(
      username: event.email,
      password: '',
      isEmailChecked: true,
      usernameErrorMessage: '',
      passwordErrorMessage: '',
      partnerLoginErrorType: null,
      loginAttemptsLeft: null,
      status: RequestStatus.empty,
    )));
  }

  Future<void> _handleStatusResetEvent(
    LoginStatusResetEvent event,
    Emitter<LoginState> emit,
  ) async {
    final isLockedStage = state.twoFaStage == LoginTwoFaStage.otpLocked24Hours;
    emit(state.copyWith(
      status: RequestStatus.empty,
      usernameErrorMessage: '',
      passwordErrorMessage: '',
      partnerLoginErrorType: null,
      loginAttemptsLeft: null,
      twoFaActionErrorMessage: null,
      twoFaStage: isLockedStage ? LoginTwoFaStage.none : state.twoFaStage,
      twoFaLockedVariant: isLockedStage ? null : state.twoFaLockedVariant,
    ));
  }

  Future<void> _handleLoginUsernameChangedEvent(
    LoginEmailChangedEvent event,
    Emitter<LoginState> emit,
  ) async {
    _inputVersion++;
    _twoFaSessionVersion++;
    emit(_resetTwoFaFields(state.copyWith(
      username: event.email,
      usernameErrorMessage: '',
      passwordErrorMessage: '',
      partnerLoginErrorType: null,
      loginAttemptsLeft: null,
      status: RequestStatus.empty,
      isEmailChecked: false,
    )));
  }

  Future<void> _handleLoginPasswordChangedEvent(
    LoginPasswordChangedEvent event,
    Emitter<LoginState> emit,
  ) async {
    _inputVersion++;
    if (event.password.contains(' ')) {
      emit(state.copyWith(
        password: event.password,
        passwordErrorMessage: Strings.label_pass_cant_use_space,
        usernameErrorMessage: '',
        partnerLoginErrorType: null,
        loginAttemptsLeft: null,
        status: RequestStatus.empty,
      ));
      return;
    }
    if (event.password.length < 8) {
      emit(state.copyWith(
        password: event.password,
        passwordErrorMessage: Strings.label_pass_min_8,
        usernameErrorMessage: '',
        partnerLoginErrorType: null,
        loginAttemptsLeft: null,
        status: RequestStatus.empty,
      ));
      return;
    }

    emit(state.copyWith(
      password: event.password,
      passwordErrorMessage: '',
      usernameErrorMessage: '',
      partnerLoginErrorType: null,
      loginAttemptsLeft: null,
      status: RequestStatus.empty,
    ));
  }

  Future<String?> _executeRecaptcha(String action) async {
    try {
      if (!recaptchaUseCase.isInitialized) {
        await recaptchaUseCase.initializeClient();
      }
      final token =
          await recaptchaUseCase.getToken(RecaptchaAction.custom(action));
      if (token.trim().isEmpty) return null;
      return token;
    } catch (e) {
      debugPrint('reCAPTCHA $action failed: $e');
      return null;
    }
  }

  Future<void> _handleLoginWithUsernameAndPasswordEvent(
    LoginButtonPressedEvent event,
    Emitter<LoginState> emit,
  ) async {
    final isPasswordStep = state.isEmailChecked;
    final email = state.username;
    final password = state.password;
    final inputVersion = _inputVersion;

    if (!isPasswordStep) {
      if (state.username.isEmpty) {
        emit(state.copyWith(
          status: RequestStatus.empty,
          usernameErrorMessage: Strings.label_username_cant_empty,
          passwordErrorMessage: '',
          partnerLoginErrorType: null,
          loginAttemptsLeft: null,
        ));
        return;
      }
    } else {
      if (state.username.isEmpty || state.password.isEmpty) {
        emit(state.copyWith(
          status: RequestStatus.empty,
          usernameErrorMessage:
              state.username.isEmpty ? Strings.label_username_cant_empty : '',
          passwordErrorMessage:
              state.password.isEmpty ? Strings.label_pass_cant_empty : '',
          partnerLoginErrorType: null,
          loginAttemptsLeft: null,
        ));
        return;
      }
    }

    emit(state.copyWith(
      status: RequestStatus.loading,
      usernameErrorMessage: '',
      passwordErrorMessage: '',
      partnerLoginErrorType: null,
      loginAttemptsLeft: null,
    ));

    final action =
        isPasswordStep ? _recaptchaActionLogin : _recaptchaActionCheckEmail;
    final recaptchaToken = await _executeRecaptcha(action);

    if (emit.isDone || inputVersion != _inputVersion) return;

    if (recaptchaToken == null) {
      emit(state.copyWith(
        status: RequestStatus.failure,
        usernameErrorMessage: 'Verifikasi keamanan gagal. Silakan coba lagi.',
        passwordErrorMessage: '',
      ));
      return;
    }

    if (!isPasswordStep) {
      final checkResult = await checkEmailLoginUseCase.call(
        email,
        recaptchaToken: recaptchaToken,
      );

      if (emit.isDone || inputVersion != _inputVersion) return;

      checkResult.fold(
        (failure) {
          emit(state.copyWith(
            status: RequestStatus.failure,
            usernameErrorMessage: failure.message,
            passwordErrorMessage: '',
          ));
        },
        (data) {
          if (data.isBanned) {
            emit(state.copyWith(
              status: RequestStatus.empty,
              isAccountBanned: true,
            ));
          } else if (data.isAllowedLogin) {
            emit(state.copyWith(
              status: RequestStatus.empty,
              isEmailChecked: true,
              usernameErrorMessage: '',
            ));
          } else if (data.isNotAllowedLogin) {
            emit(state.copyWith(
              status: RequestStatus.empty,
              isVerificationRequired: true,
              unverifiedProducts: data.unverifiedProducts,
            ));
          } else {
            emit(state.copyWith(
              status: RequestStatus.failure,
              usernameErrorMessage: 'Akun tidak valid',
              passwordErrorMessage: '',
            ));
          }
        },
      );
      return;
    }

    // 2. Proceed to Partner Login (2FA Step 1)
    final result = await partnerLoginUseCase.call(
      email,
      password,
      recaptchaToken: recaptchaToken,
    );

    if (emit.isDone || inputVersion != _inputVersion) return;

    result.fold(
      (failure) {
        if (failure is PartnerLoginFailure) {
          switch (failure.errorType) {
            case PartnerLoginErrorType.otpLocked24Hours:
              _twoFaSessionVersion++;
              emit(_resetTwoFaFields(state.copyWith(
                status: RequestStatus.empty,
                partnerLoginErrorType: PartnerLoginErrorType.otpLocked24Hours,
                loginAttemptsLeft: null,
                usernameErrorMessage: '',
                passwordErrorMessage: '',
              )).copyWith(
                twoFaStage: LoginTwoFaStage.otpLocked24Hours,
                twoFaLockedVariant: TwoFaLockedVariant.accountRestricted,
              ));
              return;
            case PartnerLoginErrorType.userNotFound:
              emit(state.copyWith(
                status: RequestStatus.empty,
                partnerLoginErrorType: PartnerLoginErrorType.userNotFound,
                loginAttemptsLeft: null,
                usernameErrorMessage: 'Email belum terdaftar',
                passwordErrorMessage: '',
              ));
              return;
            case PartnerLoginErrorType.incorrectPassword:
              emit(state.copyWith(
                status: RequestStatus.failure,
                partnerLoginErrorType: PartnerLoginErrorType.incorrectPassword,
                loginAttemptsLeft: failure.loginAttempt,
                usernameErrorMessage: '',
                passwordErrorMessage: failure.message,
              ));
              return;
            case PartnerLoginErrorType.passwordLocked24Hours:
              emit(state.copyWith(
                status: RequestStatus.failure,
                partnerLoginErrorType:
                    PartnerLoginErrorType.passwordLocked24Hours,
                loginAttemptsLeft: failure.loginAttempt ?? 0,
                usernameErrorMessage: '',
                passwordErrorMessage: failure.message,
              ));
              return;
            case PartnerLoginErrorType.generic:
              break;
          }
        }

        final cleanMessage = failure.message
            .replaceFirst(Strings.label_unexpected_error, '')
            .trim();
        emit(state.copyWith(
          status: RequestStatus.failure,
          partnerLoginErrorType: null,
          loginAttemptsLeft: null,
          usernameErrorMessage: '',
          passwordErrorMessage:
              cleanMessage.isEmpty ? failure.message : cleanMessage,
        ));
      },
      (loginData) => _handlePartnerLoginSuccess(loginData, emit),
    );
  }

  void _handlePartnerLoginSuccess(
    PartnerLoginModel loginData,
    Emitter<LoginState> emit,
  ) {
    final loginToken = loginData.token?.trim() ?? '';
    final twoFaEmail = loginData.email?.trim() ?? '';
    final twoFaPhone = loginData.phone?.trim() ?? '';
    final pendingOtp = loginData.pendingOtp;

    if (!loginData.otpLimitExceeded &&
        pendingOtp == null &&
        loginToken.isEmpty) {
      emit(state.copyWith(
        status: RequestStatus.failure,
        partnerLoginErrorType: null,
        loginAttemptsLeft: null,
        usernameErrorMessage: '',
        passwordErrorMessage: 'Respons login tidak memuat sesi yang valid.',
      ));
      return;
    }

    _twoFaSessionVersion++;

    if (loginData.otpLimitExceeded) {
      emit(state.copyWith(
        status: RequestStatus.empty,
        usernameErrorMessage: '',
        passwordErrorMessage: '',
        partnerLoginErrorType: null,
        loginAttemptsLeft: null,
        twoFaStage: LoginTwoFaStage.selectMethod,
        loginToken: loginToken,
        otpToken: '',
        twoFaEmail: twoFaEmail,
        twoFaPhone: twoFaPhone,
        selectedMethod: null,
        otpExpiresIn: 0,
        otpLimitExceeded: true,
        otpAttemptsLeft: null,
        otpErrorMessage: null,
        isOtpSessionExpired: false,
        isOtpLocked: false,
        isRequestingOtp: false,
        isResendingOtp: false,
        isVerifyingOtp: false,
        twoFaActionErrorMessage: null,
        twoFaLockedVariant: null,
      ));
      return;
    }

    if (pendingOtp == null) {
      emit(state.copyWith(
        status: RequestStatus.empty,
        usernameErrorMessage: '',
        passwordErrorMessage: '',
        partnerLoginErrorType: null,
        loginAttemptsLeft: null,
        twoFaStage: LoginTwoFaStage.selectMethod,
        loginToken: loginToken,
        otpToken: '',
        twoFaEmail: twoFaEmail,
        twoFaPhone: twoFaPhone,
        selectedMethod: null,
        otpExpiresIn: 0,
        otpLimitExceeded: false,
        otpAttemptsLeft: null,
        otpErrorMessage: null,
        isOtpSessionExpired: false,
        isOtpLocked: false,
        isRequestingOtp: false,
        isResendingOtp: false,
        isVerifyingOtp: false,
        twoFaActionErrorMessage: null,
        twoFaLockedVariant: null,
      ));
      return;
    }

    final pendingToken = pendingOtp.token?.trim() ?? '';
    final method = _mapPendingMethodType(pendingOtp.typeToken);
    emit(state.copyWith(
      status: RequestStatus.empty,
      usernameErrorMessage: '',
      passwordErrorMessage: '',
      partnerLoginErrorType: null,
      loginAttemptsLeft: null,
      twoFaStage: LoginTwoFaStage.verifyOtp,
      loginToken: loginToken,
      otpToken: pendingToken,
      twoFaEmail: twoFaEmail,
      twoFaPhone: twoFaPhone,
      selectedMethod: method,
      otpExpiresIn: pendingOtp.expiresIn ?? 0,
      otpCountdownKey: state.otpCountdownKey + 1,
      otpLimitExceeded: false,
      otpAttemptsLeft: null,
      otpErrorMessage: null,
      isOtpSessionExpired: false,
      isOtpLocked: false,
      isRequestingOtp: false,
      isResendingOtp: false,
      isVerifyingOtp: false,
      twoFaActionErrorMessage: null,
      twoFaLockedVariant: null,
    ));
  }

  Future<void> _handleTwoFaMethodSelectedEvent(
    LoginTwoFaMethodSelectedEvent event,
    Emitter<LoginState> emit,
  ) async {
    if (state.isRequestingOtp || state.otpLimitExceeded) return;

    final loginToken = state.loginToken.trim();
    if (loginToken.isEmpty) {
      emit(state.copyWith(
        isRequestingOtp: false,
        twoFaActionErrorMessage:
            'Sesi login tidak ditemukan. Silakan masuk kembali.',
      ));
      return;
    }

    final sessionVersion = _twoFaSessionVersion;
    emit(state.copyWith(
      isRequestingOtp: true,
      twoFaActionErrorMessage: null,
      otpErrorMessage: null,
    ));

    final recaptchaToken = await _executeRecaptcha(_recaptchaActionRequestOtp);
    if (emit.isDone || sessionVersion != _twoFaSessionVersion) return;

    if (recaptchaToken == null) {
      emit(state.copyWith(
        isRequestingOtp: false,
        twoFaActionErrorMessage:
            'Verifikasi keamanan gagal. Silakan coba lagi.',
      ));
      return;
    }

    final result = await requestLoginOtpUseCase.call(
      loginToken,
      event.method.apiValue,
      recaptchaToken: recaptchaToken,
    );
    if (emit.isDone || sessionVersion != _twoFaSessionVersion) return;

    result.fold(
      (failure) {
        final cleanMessage = failure.message
            .replaceFirst(Strings.label_unexpected_error, '')
            .trim();
        emit(state.copyWith(
          isRequestingOtp: false,
          twoFaActionErrorMessage:
              cleanMessage.isEmpty ? failure.message : cleanMessage,
        ));
      },
      (otpData) {
        final nextOtpToken = (otpData.token?.trim().isNotEmpty ?? false)
            ? otpData.token!.trim()
            : state.otpToken;
        final nextEmail = (otpData.email?.trim().isNotEmpty ?? false)
            ? otpData.email!.trim()
            : state.twoFaEmail;
        final nextPhone = (otpData.phone?.trim().isNotEmpty ?? false)
            ? otpData.phone!.trim()
            : state.twoFaPhone;

        emit(state.copyWith(
          isRequestingOtp: false,
          twoFaStage: LoginTwoFaStage.verifyOtp,
          selectedMethod: event.method,
          otpToken: nextOtpToken,
          twoFaEmail: nextEmail,
          twoFaPhone: nextPhone,
          otpExpiresIn:
              otpData.otpLimitExceeded ? 0 : (otpData.expiresIn ?? 0),
          otpCountdownKey: state.otpCountdownKey + 1,
          otpLimitExceeded: otpData.otpLimitExceeded,
          otpAttemptsLeft: null,
          otpErrorMessage: null,
          isOtpSessionExpired: false,
          isOtpLocked: false,
          twoFaActionErrorMessage: null,
        ));
      },
    );
  }

  Future<void> _handleOtpResendRequestedEvent(
    LoginOtpResendRequestedEvent event,
    Emitter<LoginState> emit,
  ) async {
    if (state.isResendingOtp ||
        state.isVerifyingOtp ||
        state.otpLimitExceeded ||
        state.isOtpSessionExpired ||
        state.isOtpLocked) {
      return;
    }

    final method = state.selectedMethod;
    final loginToken = state.loginToken.trim();
    if (method == null || loginToken.isEmpty) {
      emit(state.copyWith(
        otpErrorMessage: 'Sesi login tidak ditemukan. Silakan masuk kembali.',
      ));
      return;
    }

    final sessionVersion = _twoFaSessionVersion;
    emit(state.copyWith(
      isResendingOtp: true,
      otpErrorMessage: null,
      twoFaActionErrorMessage: null,
    ));

    final recaptchaToken = await _executeRecaptcha(_recaptchaActionRequestOtp);
    if (emit.isDone || sessionVersion != _twoFaSessionVersion) return;

    if (recaptchaToken == null) {
      emit(state.copyWith(
        isResendingOtp: false,
        otpErrorMessage: 'Verifikasi keamanan gagal. Silakan coba lagi.',
      ));
      return;
    }

    final result = await requestLoginOtpUseCase.call(
      loginToken,
      method.apiValue,
      recaptchaToken: recaptchaToken,
    );
    if (emit.isDone || sessionVersion != _twoFaSessionVersion) return;

    result.fold(
      (failure) {
        final cleanMessage = failure.message
            .replaceFirst(Strings.label_unexpected_error, '')
            .trim();
        emit(state.copyWith(
          isResendingOtp: false,
          otpErrorMessage:
              cleanMessage.isEmpty ? failure.message : cleanMessage,
        ));
      },
      (otpData) {
        // Pertahankan token verifikasi terbaru meski respons menandai limit tercapai.
        final nextOtpToken = (otpData.token?.trim().isNotEmpty ?? false)
            ? otpData.token!.trim()
            : state.otpToken;
        final nextEmail = (otpData.email?.trim().isNotEmpty ?? false)
            ? otpData.email!.trim()
            : state.twoFaEmail;
        final nextPhone = (otpData.phone?.trim().isNotEmpty ?? false)
            ? otpData.phone!.trim()
            : state.twoFaPhone;

        if (otpData.otpLimitExceeded) {
          emit(state.copyWith(
            isResendingOtp: false,
            otpToken: nextOtpToken,
            twoFaEmail: nextEmail,
            twoFaPhone: nextPhone,
            otpExpiresIn: 0,
            otpLimitExceeded: true,
            otpErrorMessage: null,
            twoFaActionErrorMessage: null,
          ));
          return;
        }

        emit(state.copyWith(
          isResendingOtp: false,
          otpToken: nextOtpToken,
          twoFaEmail: nextEmail,
          twoFaPhone: nextPhone,
          otpExpiresIn: otpData.expiresIn ?? 0,
          otpCountdownKey: state.otpCountdownKey + 1,
          otpLimitExceeded: false,
          otpAttemptsLeft: null,
          otpErrorMessage: null,
          isOtpLocked: false,
          twoFaActionErrorMessage: null,
        ));
      },
    );
  }

  Future<void> _handleOtpSubmittedEvent(
    LoginOtpSubmittedEvent event,
    Emitter<LoginState> emit,
  ) async {
    if (state.isVerifyingOtp ||
        state.isResendingOtp ||
        state.isOtpSessionExpired ||
        state.isOtpLocked) {
      return;
    }

    final trimmedOtp = event.otp.trim();
    if (trimmedOtp.length != 6) {
      emit(state.copyWith(otpErrorMessage: 'Kode OTP harus 6 digit.'));
      return;
    }

    final otpToken = state.otpToken.trim();
    if (otpToken.isEmpty) {
      emit(state.copyWith(
        otpErrorMessage: 'Sesi verifikasi OTP tidak valid. Silakan coba lagi.',
      ));
      return;
    }

    final sessionVersion = _twoFaSessionVersion;
    emit(state.copyWith(
      isVerifyingOtp: true,
      otpAttemptsLeft: null,
      otpErrorMessage: null,
      twoFaActionErrorMessage: null,
    ));

    final recaptchaToken = await _executeRecaptcha(_recaptchaActionVerifyOtp);
    if (emit.isDone || sessionVersion != _twoFaSessionVersion) return;

    if (recaptchaToken == null) {
      emit(state.copyWith(
        isVerifyingOtp: false,
        otpErrorMessage: 'Verifikasi keamanan gagal. Silakan coba lagi.',
      ));
      return;
    }

    final result = await verifyLoginOtpUseCase.call(
      otpToken,
      trimmedOtp,
      recaptchaToken: recaptchaToken,
    );
    if (emit.isDone || sessionVersion != _twoFaSessionVersion) return;

    result.fold(
      (failure) {
        if (failure is VerifyOtpFailure) {
          switch (failure.errorType) {
            case VerifyOtpErrorType.expiredToken:
              emit(state.copyWith(
                isVerifyingOtp: false,
                isOtpSessionExpired: true,
                isOtpLocked: true,
                otpAttemptsLeft: null,
                otpErrorMessage: null,
              ));
              return;
            case VerifyOtpErrorType.otpInvalidLocked:
              emit(state.copyWith(
                isVerifyingOtp: false,
                twoFaStage: LoginTwoFaStage.otpLocked24Hours,
                twoFaLockedVariant: TwoFaLockedVariant.otpVerificationFailed,
                isOtpLocked: true,
                otpAttemptsLeft: failure.attemptLeft ?? 0,
                otpErrorMessage: null,
              ));
              return;
            case VerifyOtpErrorType.otpInvalid:
              final attemptsLeft = failure.attemptLeft ?? 0;
              emit(state.copyWith(
                isVerifyingOtp: false,
                twoFaStage: LoginTwoFaStage.verifyOtp,
                otpAttemptsLeft: attemptsLeft,
                isOtpLocked: attemptsLeft <= 0,
                otpErrorMessage: null,
              ));
              return;
            case VerifyOtpErrorType.generic:
              break;
          }
        }

        final cleanMessage = failure.message
            .replaceFirst(Strings.label_unexpected_error, '')
            .trim();
        emit(state.copyWith(
          isVerifyingOtp: false,
          otpErrorMessage:
              cleanMessage.isEmpty ? failure.message : cleanMessage,
        ));
      },
      (_) {
        _twoFaSessionVersion++;
        emit(_resetTwoFaFields(state.copyWith(
          message: 'Success',
          status: RequestStatus.success,
          usernameErrorMessage: '',
          passwordErrorMessage: '',
          partnerLoginErrorType: null,
          loginAttemptsLeft: null,
        )));
      },
    );
  }

  Future<void> _handleTwoFaChangeMethodRequested(
    LoginTwoFaChangeMethodRequestedEvent event,
    Emitter<LoginState> emit,
  ) async {
    _twoFaSessionVersion++;
    emit(state.copyWith(
      twoFaStage: LoginTwoFaStage.selectMethod,
      otpAttemptsLeft: null,
      otpErrorMessage: null,
      twoFaActionErrorMessage: null,
      isOtpSessionExpired: false,
      isOtpLocked: false,
      isRequestingOtp: false,
      isResendingOtp: false,
      isVerifyingOtp: false,
    ));
  }

  Future<void> _handleTwoFaDismissed(
    LoginTwoFaDismissedEvent event,
    Emitter<LoginState> emit,
  ) async {
    _twoFaSessionVersion++;
    emit(_resetTwoFaFields(state.copyWith(
      status: RequestStatus.empty,
      usernameErrorMessage: '',
      passwordErrorMessage: '',
      partnerLoginErrorType: null,
      loginAttemptsLeft: null,
    )));
  }

  TwoFaMethodType _mapPendingMethodType(String? rawType) {
    switch (rawType?.trim().toLowerCase()) {
      case 'email':
        return TwoFaMethodType.email;
      case 'whatsapp':
      case 'wa':
        return TwoFaMethodType.whatsapp;
      case 'sms':
        return TwoFaMethodType.sms;
      default:
        return TwoFaMethodType.email;
    }
  }
}
