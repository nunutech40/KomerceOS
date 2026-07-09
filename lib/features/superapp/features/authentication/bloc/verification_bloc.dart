import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komtim_partner/core/domain/entities/partner_product_model.dart';
import 'package:komtim_partner/core/domain/usecases/resend_verification_use_case.dart';

part 'verification_event.dart';
part 'verification_state.dart';

// -----------------------------------------------------------------------------
// VerificationBloc
//
// Mengelola state pada VerificationRequiredPage.
// - Menyimpan produk yang dipilih user (radio button)
// - Mengirim request resend verification email
// - Menangani rate limit (count_down) dari API
// -----------------------------------------------------------------------------

class VerificationBloc extends Bloc<VerificationEvent, VerificationState> {
  final ResendVerificationUseCase resendVerificationUseCase;

  VerificationBloc({required this.resendVerificationUseCase})
      : super(const VerificationState()) {
    on<VerificationProductSelected>(_onProductSelected);
    on<VerificationEmailSent>(_onEmailSent);
    on<VerificationResendEmail>(_onResendEmail);
    on<VerificationResetStatus>(_onResetStatus);
  }

  void _onProductSelected(
    VerificationProductSelected event,
    Emitter<VerificationState> emit,
  ) {
    emit(state.copyWith(
      selectedProduct: event.product,
      status: VerificationStatus.idle,
      errorMessage: null,
    ));
  }

  Future<void> _onEmailSent(
    VerificationEmailSent event,
    Emitter<VerificationState> emit,
  ) async {
    final product = state.selectedProduct;
    if (product == null) return;

    emit(state.copyWith(status: VerificationStatus.loading));

    final result = await resendVerificationUseCase.execute(
      event.email,
      product.productName ?? '',
    );

    result.fold(
      (failure) {
        // Parse count_down dari error message jika ada
        final countDown = _parseCountDown(failure.message);
        if (countDown > 0) {
          emit(state.copyWith(
            status: VerificationStatus.rateLimited,
            errorMessage: failure.message,
            countDown: countDown,
          ));
        } else {
          emit(state.copyWith(
            status: VerificationStatus.failure,
            errorMessage: failure.message,
          ));
        }
      },
      (_) => emit(state.copyWith(status: VerificationStatus.success)),
    );
  }

  /// Resend email dari halaman EmailVerifSentPage
  Future<void> _onResendEmail(
    VerificationResendEmail event,
    Emitter<VerificationState> emit,
  ) async {
    emit(state.copyWith(status: VerificationStatus.loading));

    final result = await resendVerificationUseCase.execute(
      event.email,
      event.productName,
    );

    result.fold(
      (failure) {
        final countDown = _parseCountDown(failure.message);
        if (countDown > 0) {
          emit(state.copyWith(
            status: VerificationStatus.rateLimited,
            errorMessage: failure.message,
            countDown: countDown,
          ));
        } else {
          emit(state.copyWith(
            status: VerificationStatus.failure,
            errorMessage: failure.message,
          ));
        }
      },
      (_) => emit(state.copyWith(
        status: VerificationStatus.success,
        countDown: 0,
      )),
    );
  }

  void _onResetStatus(
    VerificationResetStatus event,
    Emitter<VerificationState> emit,
  ) {
    emit(state.copyWith(
      status: VerificationStatus.idle,
      errorMessage: null,
    ));
  }

  /// Parse count_down dari error message format: "... count_down: 49"
  int _parseCountDown(String message) {
    final match = RegExp(r'count_down:\s*(\d+)').firstMatch(message);
    if (match != null) {
      return int.tryParse(match.group(1) ?? '0') ?? 0;
    }
    return 0;
  }
}
