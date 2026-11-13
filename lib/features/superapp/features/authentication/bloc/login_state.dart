part of 'login_bloc.dart';

const Object _unset = Object();

enum LoginTwoFaStage {
  none,
  selectMethod,
  verifyOtp,
  otpLocked24Hours,
}

class LoginState extends Equatable {
  const LoginState({
    this.message = '',
    this.status = RequestStatus.empty,
    this.username = '',
    this.password = '',
    this.fcmToken = '',
    this.passwordErrorMessage = '',
    this.usernameErrorMessage = '',
    this.isVerificationRequired = false,
    this.isEmailChecked = false,
    this.isAccountBanned = false,
    this.unverifiedProducts = const [],
    this.partnerLoginErrorType,
    this.loginAttemptsLeft,
    this.twoFaStage = LoginTwoFaStage.none,
    this.loginToken = '',
    this.otpToken = '',
    this.twoFaEmail = '',
    this.twoFaPhone = '',
    this.selectedMethod,
    this.otpExpiresIn = 0,
    this.otpCountdownKey = 0,
    this.otpLimitExceeded = false,
    this.otpAttemptsLeft,
    this.otpErrorMessage,
    this.isOtpSessionExpired = false,
    this.isOtpLocked = false,
    this.isRequestingOtp = false,
    this.isResendingOtp = false,
    this.isVerifyingOtp = false,
    this.twoFaActionErrorMessage,
    this.twoFaLockedVariant,
  });

  final String message;
  final RequestStatus status;
  final String username;
  final String password;
  final String fcmToken;
  final String usernameErrorMessage;
  final String passwordErrorMessage;
  final bool isVerificationRequired;
  final bool isEmailChecked;
  final bool isAccountBanned;
  final List<PartnerProductModel> unverifiedProducts;

  final PartnerLoginErrorType? partnerLoginErrorType;
  final int? loginAttemptsLeft;

  final LoginTwoFaStage twoFaStage;
  final String loginToken;
  final String otpToken;
  final String twoFaEmail;
  final String twoFaPhone;
  final TwoFaMethodType? selectedMethod;
  final int otpExpiresIn;
  final int otpCountdownKey;
  final bool otpLimitExceeded;
  final int? otpAttemptsLeft;
  final String? otpErrorMessage;
  final bool isOtpSessionExpired;
  final bool isOtpLocked;
  final bool isRequestingOtp;
  final bool isResendingOtp;
  final bool isVerifyingOtp;
  final String? twoFaActionErrorMessage;
  final TwoFaLockedVariant? twoFaLockedVariant;

  LoginState copyWith({
    String? username,
    String? password,
    String? fcmToken,
    RequestStatus? status,
    String? message,
    String? usernameErrorMessage,
    String? passwordErrorMessage,
    bool? isVerificationRequired,
    bool? isEmailChecked,
    bool? isAccountBanned,
    List<PartnerProductModel>? unverifiedProducts,
    Object? partnerLoginErrorType = _unset,
    Object? loginAttemptsLeft = _unset,
    LoginTwoFaStage? twoFaStage,
    String? loginToken,
    String? otpToken,
    String? twoFaEmail,
    String? twoFaPhone,
    Object? selectedMethod = _unset,
    int? otpExpiresIn,
    int? otpCountdownKey,
    bool? otpLimitExceeded,
    Object? otpAttemptsLeft = _unset,
    Object? otpErrorMessage = _unset,
    bool? isOtpSessionExpired,
    bool? isOtpLocked,
    bool? isRequestingOtp,
    bool? isResendingOtp,
    bool? isVerifyingOtp,
    Object? twoFaActionErrorMessage = _unset,
    Object? twoFaLockedVariant = _unset,
  }) {
    return LoginState(
      username: username ?? this.username,
      password: password ?? this.password,
      status: status ?? this.status,
      fcmToken: fcmToken ?? this.fcmToken,
      message: message ?? this.message,
      usernameErrorMessage: usernameErrorMessage ?? this.usernameErrorMessage,
      passwordErrorMessage: passwordErrorMessage ?? this.passwordErrorMessage,
      // Do not persist one-shot navigation/popup flags to avoid infinite loops.
      isVerificationRequired: isVerificationRequired ?? false,
      isEmailChecked: isEmailChecked ?? this.isEmailChecked,
      isAccountBanned: isAccountBanned ?? false,
      unverifiedProducts: unverifiedProducts ?? this.unverifiedProducts,
      partnerLoginErrorType: partnerLoginErrorType == _unset
          ? this.partnerLoginErrorType
          : partnerLoginErrorType as PartnerLoginErrorType?,
      loginAttemptsLeft: loginAttemptsLeft == _unset
          ? this.loginAttemptsLeft
          : loginAttemptsLeft as int?,
      twoFaStage: twoFaStage ?? this.twoFaStage,
      loginToken: loginToken ?? this.loginToken,
      otpToken: otpToken ?? this.otpToken,
      twoFaEmail: twoFaEmail ?? this.twoFaEmail,
      twoFaPhone: twoFaPhone ?? this.twoFaPhone,
      selectedMethod: selectedMethod == _unset
          ? this.selectedMethod
          : selectedMethod as TwoFaMethodType?,
      otpExpiresIn: otpExpiresIn ?? this.otpExpiresIn,
      otpCountdownKey: otpCountdownKey ?? this.otpCountdownKey,
      otpLimitExceeded: otpLimitExceeded ?? this.otpLimitExceeded,
      otpAttemptsLeft: otpAttemptsLeft == _unset
          ? this.otpAttemptsLeft
          : otpAttemptsLeft as int?,
      otpErrorMessage: otpErrorMessage == _unset
          ? this.otpErrorMessage
          : otpErrorMessage as String?,
      isOtpSessionExpired: isOtpSessionExpired ?? this.isOtpSessionExpired,
      isOtpLocked: isOtpLocked ?? this.isOtpLocked,
      isRequestingOtp: isRequestingOtp ?? this.isRequestingOtp,
      isResendingOtp: isResendingOtp ?? this.isResendingOtp,
      isVerifyingOtp: isVerifyingOtp ?? this.isVerifyingOtp,
      twoFaActionErrorMessage: twoFaActionErrorMessage == _unset
          ? this.twoFaActionErrorMessage
          : twoFaActionErrorMessage as String?,
      twoFaLockedVariant: twoFaLockedVariant == _unset
          ? this.twoFaLockedVariant
          : twoFaLockedVariant as TwoFaLockedVariant?,
    );
  }

  @override
  List<Object?> get props => [
        message,
        status,
        username,
        password,
        fcmToken,
        usernameErrorMessage,
        passwordErrorMessage,
        isVerificationRequired,
        isEmailChecked,
        isAccountBanned,
        unverifiedProducts,
        partnerLoginErrorType,
        loginAttemptsLeft,
        twoFaStage,
        loginToken,
        otpToken,
        twoFaEmail,
        twoFaPhone,
        selectedMethod,
        otpExpiresIn,
        otpCountdownKey,
        otpLimitExceeded,
        otpAttemptsLeft,
        otpErrorMessage,
        isOtpSessionExpired,
        isOtpLocked,
        isRequestingOtp,
        isResendingOtp,
        isVerifyingOtp,
        twoFaActionErrorMessage,
        twoFaLockedVariant,
      ];
}
