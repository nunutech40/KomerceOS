part of 'login_bloc.dart';

@immutable
abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

class LoginButtonPressedEvent extends LoginEvent {
  const LoginButtonPressedEvent();

  @override
  List<Object> get props => [];
}

class LoginStatusResetEvent extends LoginEvent {}

/// Email was already accepted by /auth/check-login on EmailCheckPage.
class LoginEmailPrecheckedEvent extends LoginEvent {
  const LoginEmailPrecheckedEvent(this.email);

  final String email;

  @override
  List<Object> get props => [email];
}

class LoginEmailChangedEvent extends LoginEvent {
  const LoginEmailChangedEvent({required this.email});

  final String email;

  @override
  List<Object> get props => [email];
}

class LoginPasswordChangedEvent extends LoginEvent {
  const LoginPasswordChangedEvent({required this.password});

  final String password;

  @override
  List<Object> get props => [password];
}

/// User memilih metode 2FA dan menekan "Konfirmasi" untuk request OTP.
class LoginTwoFaMethodSelectedEvent extends LoginEvent {
  const LoginTwoFaMethodSelectedEvent(this.method);

  final TwoFaMethodType method;

  @override
  List<Object> get props => [method];
}

/// User menekan "Kirim Ulang" di bottom sheet verifikasi OTP.
class LoginOtpResendRequestedEvent extends LoginEvent {
  const LoginOtpResendRequestedEvent();

  @override
  List<Object> get props => [];
}

/// User mengirim kode OTP 6 digit di bottom sheet verifikasi OTP.
class LoginOtpSubmittedEvent extends LoginEvent {
  const LoginOtpSubmittedEvent(this.otp);

  final String otp;

  @override
  List<Object> get props => [otp];
}

/// User menekan "Gunakan Metode Lain" di bottom sheet verifikasi OTP.
class LoginTwoFaChangeMethodRequestedEvent extends LoginEvent {
  const LoginTwoFaChangeMethodRequestedEvent();

  @override
  List<Object> get props => [];
}

/// Bottom sheet 2FA ditutup / dibatalkan sebelum verifikasi selesai.
class LoginTwoFaDismissedEvent extends LoginEvent {
  const LoginTwoFaDismissedEvent();

  @override
  List<Object> get props => [];
}
