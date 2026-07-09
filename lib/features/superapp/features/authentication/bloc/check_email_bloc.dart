import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komtim_partner/core/domain/entities/partner_product_model.dart';
import 'package:komtim_partner/core/domain/usecases/check_email_login_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/recaptcha_use_case.dart';
import 'package:recaptcha_enterprise_flutter/recaptcha_action.dart';

part 'check_email_event.dart';
part 'check_email_state.dart';

// -----------------------------------------------------------------------------
// CheckEmailBloc
//
// Mengelola state pengecekan email pada EmailCheckPage.
// Menerima CheckEmailSubmitted → emit Loading → emit result state.
//
// State transitions:
//   CheckEmailInitial
//     └─ CheckEmailSubmitted
//         ├─ CheckEmailLoading
//         ├─ CheckEmailFound       (allowed_login == true)
//         ├─ CheckEmailNotAllowed  (allowed_login == false, ada produk unverified)
//         ├─ CheckEmailUnregistered (banned == true atau response lain)
//         └─ CheckEmailFailure     (network / server error)
// -----------------------------------------------------------------------------

class CheckEmailBloc extends Bloc<CheckEmailEvent, CheckEmailState> {
  final CheckEmailLoginUseCase checkEmailLoginUseCase;
  final RecaptchaUseCase recaptchaUseCase;

  CheckEmailBloc({
    required this.checkEmailLoginUseCase,
    required this.recaptchaUseCase,
  }) : super(CheckEmailInitial()) {
    on<CheckEmailSubmitted>(_onSubmitted);
    on<CheckEmailReset>(_onReset);
  }

  Future<void> _onSubmitted(
    CheckEmailSubmitted event,
    Emitter<CheckEmailState> emit,
  ) async {
    emit(CheckEmailLoading());

    // reCAPTCHA init
    if (!recaptchaUseCase.isInitialized) {
      try {
        await recaptchaUseCase.initializeClient();
      } catch (e) {
        emit(CheckEmailFailure(
            message: 'reCAPTCHA init failed: ${e.toString()}'));
        return;
      }
    }

    String recaptchaToken = '';
    try {
      recaptchaToken = await recaptchaUseCase.getToken(RecaptchaAction.LOGIN());
    } catch (e) {
      emit(CheckEmailFailure(
          message: 'reCAPTCHA token failed: ${e.toString()}'));
      return;
    }

    final result = await checkEmailLoginUseCase.call(event.email,
        recaptchaToken: recaptchaToken);

    result.fold(
      (failure) => emit(CheckEmailFailure(message: failure.message)),
      (data) {
        final email = data.email ?? event.email;

        if (data.isBanned) {
          // banned == true → tampilkan Bottom Sheet "Akun Tidak Aktif"
          emit(const CheckEmailBanned());
        } else if (data.isAllowedLogin) {
          // allowed_login == true → lanjut ke halaman password (LoginPage)
          emit(CheckEmailFound(email: email));
        } else if (data.isNotAllowedLogin) {
          // allowed_login == false & tidak banned → tampilkan halaman verifikasi produk
          emit(CheckEmailNotAllowed(
            email: email,
            partnerProducts: data.unverifiedProducts,
          ));
        } else {
          // Fallback: data tidak dikenali
          emit(const CheckEmailFailure(message: 'Status email tidak dikenali'));
        }
      },
    );
  }

  void _onReset(CheckEmailReset event, Emitter<CheckEmailState> emit) {
    emit(CheckEmailInitial());
  }
}
