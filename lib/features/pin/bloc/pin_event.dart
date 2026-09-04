part of 'pin_bloc.dart';

abstract class PinEvent extends Equatable {
  const PinEvent();

  @override
  List<Object?> get props => [];
}

class VerifyPinFullEvent extends PinEvent {
  final String pin;

  const VerifyPinFullEvent({required this.pin});

  @override
  List<Object?> get props => [pin];
}

class SavePinFullEvent extends PinEvent {
  final String pin;

  const SavePinFullEvent({required this.pin});

  @override
  List<Object?> get props => [pin];
}

class UpdatePinFullEvent extends PinEvent {
  final String pin;

  const UpdatePinFullEvent({required this.pin});

  @override
  List<Object?> get props => [pin];
}

class DoWithdrawalEvent extends PinEvent {
  final int nominal;
  final int bankAccountId;
  const DoWithdrawalEvent({
    required this.nominal,
    required this.bankAccountId,
  });

  @override
  List<Object?> get props => [nominal, bankAccountId];
}

class DoPaymentKompayEvent extends PinEvent {
  final String? id;
  const DoPaymentKompayEvent({
    this.id,
  });

  @override
  List<Object?> get props => [id];
}

class ForgetPinEvent extends PinEvent {
  @override
  List<Object?> get props => [];
}

class VerifyOtpEvent extends PinEvent {
  final String otp;

  const VerifyOtpEvent({required this.otp});

  @override
  List<Object?> get props => [otp];
}

class GetProfileEmail extends PinEvent {
  @override
  List<Object?> get props => [];
}

/// Ambil profil dari local storage (SharedPreferences) sebagai fallback email.
class GetProfileLocalEvent extends PinEvent {
  @override
  List<Object?> get props => [];
}

class SaveTimeEvent extends PinEvent {
  final String time;

  const SaveTimeEvent({required this.time});

  @override
  List<Object?> get props => [time];
}

class DeletetTimeEvent extends PinEvent {
  @override
  List<Object?> get props => [];
}

class GetTimeEvent extends PinEvent {
  @override
  List<Object?> get props => [];
}
