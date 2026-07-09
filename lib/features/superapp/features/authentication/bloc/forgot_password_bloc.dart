import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komtim_partner/common/failure.dart';
import 'package:komtim_partner/common/string.dart';
import 'package:komtim_partner/core/domain/usecases/recaptcha_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/send_forgot_password_use_case.dart';
import 'package:recaptcha_enterprise_flutter/recaptcha_action.dart';

import '../../../../../common/enum_status.dart';
import 'forgot_password_event.dart';
import 'forgot_password_state.dart';

// ---------------------------------------------------------------------------
// ForgotPasswordBloc (Superapp)
//
// Mengelola state halaman Lupa Password.
// Flow: email input → reCAPTCHA → hit API forgot-password → emit result.
//
// Rate-limit handling:
//   Server bisa mengembalikan error: "harap tunggu 960 detik sebelum meminta..."
//   Bloc parse angka detik dari pesan tersebut, simpan di state.countDown,
//   lalu view menampilkan countdown timer di bottom sheet.
// ---------------------------------------------------------------------------

class ForgotPasswordBloc
    extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  final SendForgotPasswordUseCase sendForgotPasswordUseCase;
  final RecaptchaUseCase recaptchaUseCase;

  ForgotPasswordBloc({
    required this.sendForgotPasswordUseCase,
    required this.recaptchaUseCase,
  }) : super(const ForgotPasswordState()) {
    on<ForgotEmailChangedEvent>(_handleEmailChanged);
    on<SendButtonPressedEvent>(_handleSendForgotPassword);
    on<SendStatusResetEvent>(_handleStatusReset);
    on<ResendForgotPasswordEvent>(_handleResend);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Parse angka detik dari pesan rate-limit server.
  /// Contoh: "harap tunggu 960 detik sebelum meminta..." → 960
  /// Jika tidak ada angka, return 0.
  int _parseCountdownFromMessage(String message) {
    final regex = RegExp(r'(\d+)\s*detik');
    final match = regex.firstMatch(message.toLowerCase());
    if (match != null) {
      return int.tryParse(match.group(1)!) ?? 0;
    }
    return 0;
  }

  /// Cek apakah pesan error adalah rate-limit (berisi "detik" dan angka).
  bool _isRateLimitError(String message) {
    return _parseCountdownFromMessage(message) > 0;
  }

  // ---------------------------------------------------------------------------
  // Email changed
  // ---------------------------------------------------------------------------

  Future<void> _handleEmailChanged(
    ForgotEmailChangedEvent event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    final email = event.email;

    if (email.isEmpty) {
      emit(state.copyWith(
        email: email,
        emailErrorMessage: Strings.label_email_cant_empty,
      ));
      return;
    }

    final emailRegex =
        RegExp(r'^[\w-]+(\.[\w-]+)*@[a-z0-9-]+(\.[a-z0-9-]+)*(\.[a-z]{2,})$');
    if (!emailRegex.hasMatch(email)) {
      emit(state.copyWith(
        email: email,
        emailErrorMessage: Strings.label_email_format_not_valid,
      ));
      return;
    }

    emit(state.copyWith(email: email, emailErrorMessage: ''));
  }

  // ---------------------------------------------------------------------------
  // Status reset
  // ---------------------------------------------------------------------------

  Future<void> _handleStatusReset(
    SendStatusResetEvent event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(state.copyWith(
      status: RequestStatus.empty,
      emailErrorMessage: '',
      countDown: 0,
    ));
  }

  // ---------------------------------------------------------------------------
  // Kirim forgot password (pertama kali)
  // ---------------------------------------------------------------------------

  Future<void> _handleSendForgotPassword(
    SendButtonPressedEvent event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    final email = state.email;

    if (email.isEmpty) {
      emit(state.copyWith(
        emailErrorMessage: Strings.label_email_cant_empty,
      ));
      return;
    }

    emit(state.copyWith(status: RequestStatus.loading));

    // --- reCAPTCHA ---
    String recaptchaToken = '';
    try {
      if (!recaptchaUseCase.isInitialized) {
        await recaptchaUseCase.initializeClient();
      }
      recaptchaToken = await recaptchaUseCase.getToken(RecaptchaAction.LOGIN());
    } catch (e) {
      debugPrint('reCAPTCHA failed for forgot password: $e');
    }

    // --- Hit API ---
    final result = await sendForgotPasswordUseCase.execute(
      email,
      recaptchaToken: recaptchaToken,
    );

    result.fold(
      (failure) {
        String newMessageError = failure.message;

        // Cek rate-limit: "harap tunggu 960 detik..."
        if (_isRateLimitError(newMessageError)) {
          final seconds = _parseCountdownFromMessage(newMessageError);
          // Rate-limited pada pengiriman pertama → tetap tampilkan bottom sheet
          // dengan countdown dari server
          emit(state.copyWith(
            message: 'Success',
            status: RequestStatus.success,
            countDown: seconds,
          ));
          return;
        }

        if (failure is ConnectionFailure || failure is ServerFailure) {
          emit(state.copyWith(
            message: failure.message,
            status: RequestStatus.failure,
          ));
        } else {
          if (newMessageError.contains(Strings.label_email_not_found)) {
            newMessageError = Strings.label_email_not_registered;
          } else {
            newMessageError = newMessageError.replaceFirst(
                Strings.label_unexpected_error, '');
          }
          emit(state.copyWith(
            status: RequestStatus.empty,
            emailErrorMessage: newMessageError,
          ));
        }
      },
      (_) {
        emit(state.copyWith(
          message: 'Success',
          status: RequestStatus.success,
          countDown: 0,
        ));
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Kirim ulang (resend)
  // ---------------------------------------------------------------------------

  Future<void> _handleResend(
    ResendForgotPasswordEvent event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    final email = state.email;
    if (email.isEmpty) return;

    emit(state.copyWith(status: RequestStatus.loading));

    // --- reCAPTCHA ---
    String recaptchaToken = '';
    try {
      if (!recaptchaUseCase.isInitialized) {
        await recaptchaUseCase.initializeClient();
      }
      recaptchaToken = await recaptchaUseCase.getToken(RecaptchaAction.LOGIN());
    } catch (e) {
      debugPrint('reCAPTCHA failed for resend forgot password: $e');
    }

    final result = await sendForgotPasswordUseCase.execute(
      email,
      recaptchaToken: recaptchaToken,
    );

    result.fold(
      (failure) {
        String msg = failure.message;
        int countDown = 0;

        // Cek rate-limit dari server
        if (_isRateLimitError(msg)) {
          countDown = _parseCountdownFromMessage(msg);
        }

        emit(state.copyWith(
          message: msg,
          status: RequestStatus.failure,
          countDown: countDown,
        ));
      },
      (_) {
        emit(state.copyWith(
          message: 'Resend success',
          status: RequestStatus.success,
          countDown: 0,
        ));
      },
    );
  }
}
