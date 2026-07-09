import 'package:equatable/equatable.dart';

// ---------------------------------------------------------------------------
// ForgotPasswordEvent (Superapp)
// ---------------------------------------------------------------------------

abstract class ForgotPasswordEvent extends Equatable {
  const ForgotPasswordEvent();

  @override
  List<Object?> get props => [];
}

/// User mengetik di field email
class ForgotEmailChangedEvent extends ForgotPasswordEvent {
  final String email;
  const ForgotEmailChangedEvent({required this.email});

  @override
  List<Object?> get props => [email];
}

/// User klik tombol "Kirim"
class SendButtonPressedEvent extends ForgotPasswordEvent {
  const SendButtonPressedEvent();
}

/// Reset status setelah navigasi / side effect
class SendStatusResetEvent extends ForgotPasswordEvent {
  const SendStatusResetEvent();
}

/// User klik "Kirim Ulang" di bottom sheet verifikasi email
class ResendForgotPasswordEvent extends ForgotPasswordEvent {
  const ResendForgotPasswordEvent();
}
