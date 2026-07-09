import 'package:equatable/equatable.dart';

import '../../../../../common/enum_status.dart';

// ---------------------------------------------------------------------------
// ForgotPasswordState (Superapp)
//
// Menggunakan RequestStatus yang sama dengan old bloc agar view yang sudah ada
// bisa langsung kompatibel tanpa perubahan besar.
//
// countDown: jumlah detik yang di-parse dari error rate-limit server.
//            Contoh: "harap tunggu 960 detik..." → countDown = 960
// ---------------------------------------------------------------------------

class ForgotPasswordState extends Equatable {
  const ForgotPasswordState({
    this.message = '',
    this.status = RequestStatus.empty,
    this.email = '',
    this.emailErrorMessage = '',
    this.countDown = 0,
  });

  final String message;
  final RequestStatus status;
  final String email;
  final String emailErrorMessage;

  /// Countdown (detik) dari rate-limit server.
  /// 0 = tidak ada rate limit aktif.
  final int countDown;

  ForgotPasswordState copyWith({
    RequestStatus? status,
    String? message,
    String? email,
    String? emailErrorMessage,
    int? countDown,
  }) {
    return ForgotPasswordState(
      status: status ?? this.status,
      message: message ?? this.message,
      email: email ?? this.email,
      emailErrorMessage: emailErrorMessage ?? this.emailErrorMessage,
      countDown: countDown ?? this.countDown,
    );
  }

  @override
  List<Object?> get props =>
      [message, status, email, emailErrorMessage, countDown];
}
