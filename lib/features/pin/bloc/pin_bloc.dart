import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:komtim_partner/common/enum_status.dart';
import 'package:komtim_partner/core/domain/entities/profile_model.dart';
import 'package:komtim_partner/core/domain/entities/verify_pin_model.dart';
import 'package:komtim_partner/core/domain/usecases/delete_time_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/do_payment_kompay_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/forget_pin_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/get_locale_profile_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/get_profile_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/get_time_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/save_pin_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/save_time_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/update_pin_secured_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/update_pin_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/verify_otp_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/verify_pin_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/withdraw_kompoin_use_case.dart';

import '../../../common/failure.dart';

part 'pin_event.dart';
part 'pin_state.dart';

class PinBloc extends Bloc<PinEvent, PinState> {
  PinBloc({
    required this.verifyPinUseCase,
    required this.savePinUseCase,
    required this.withdrawKompoinUseCase,
    required this.forgetPinUseCase,
    required this.verifyOtpUseCase,
    required this.getProfileUseCase,
    required this.saveTimeUseCase,
    required this.getTimeUseCase,
    required this.deleteTimeUseCase,
    required this.doPaymentKompayUseCase,
    required this.updatePinUseCase,
    required this.updatePinSecuredUseCase,
    required this.getLocaleProfileUseCase,
  }) : super(const PinState()) {
    on<SavePinFullEvent>(_handleSavePin);
    on<UpdatePinFullEvent>(_handleUpdatePin);
    on<VerifyPinFullEvent>(_handleVerifyPin);
    on<DoWithdrawalEvent>(_doWithdrawal);
    on<ForgetPinEvent>(_forgetPin);
    on<VerifyOtpEvent>(_verifyOtp);
    on<GetProfileEmail>(_getProfileEmail);
    on<GetProfileLocalEvent>(_getProfileLocal);
    on<SaveTimeEvent>(_saveTime);
    on<GetTimeEvent>(_getTime);
    on<DeletetTimeEvent>(_deleteTime);
    on<DoPaymentKompayEvent>(_handlePaymentKompay);
  }

  VerifyPinUseCase verifyPinUseCase;
  SavePinUseCase savePinUseCase;
  GetLocaleProfileUseCase getLocaleProfileUseCase;
  WithdrawKompoinUseCase withdrawKompoinUseCase;
  ForgetPinUseCase forgetPinUseCase;
  VerifyOtpUseCase verifyOtpUseCase;
  GetProfileUseCase getProfileUseCase;
  SaveTimeUseCase saveTimeUseCase;
  DeleteTimeUseCase deleteTimeUseCase;
  GetTimeUseCase getTimeUseCase;
  DoPaymentKompayUseCase doPaymentKompayUseCase;
  UpdatePinUseCase updatePinUseCase;
  UpdatePinSecuredUseCase updatePinSecuredUseCase;

  Future<void> _handleSavePin(
    SavePinFullEvent event,
    Emitter<PinState> emit,
  ) async {
    emit(state.copyWith(status: RequestStatus.loading, operation: 'savePin'));

    final savePinResult = await savePinUseCase.execute(event.pin);

    savePinResult.fold(
      (failure) {
        if (failure is ConnectionFailure || failure is ServerFailure) {
          emit(state.copyWith(
              message: failure.message, status: RequestStatus.failure));
        } else {
          emit(state.copyWith(
              message: failure.message, status: RequestStatus.failure));
        }
      },
      (pinData) {
        emit(state.copyWith(
          message: 'Success',
          status: RequestStatus.success,
          isSetPin: true,
          pinData: null,
        ));
      },
    );
  }

  Future<void> _handleUpdatePin(
    UpdatePinFullEvent event,
    Emitter<PinState> emit,
  ) async {
    emit(state.copyWith(status: RequestStatus.loading, operation: 'updatePin'));

    // Flow lupa PIN: token OTP tersedia -> endpoint secured (internal auth).
    // Flow ubah PIN (dengan PIN lama): endpoint legacy /pin/save.
    final updatePinResult =
        (state.otpToken != null && state.otpToken!.isNotEmpty)
            ? await updatePinSecuredUseCase.execute(event.pin, state.otpToken!)
            : await updatePinUseCase.execute(event.pin);

    updatePinResult.fold(
      (failure) {
        emit(state.copyWith(
            message: failure.message, status: RequestStatus.failure));
      },
      (pinData) {
        emit(state.copyWith(
          message: 'Success',
          status: RequestStatus.success,
          pinData: null,
        ));
      },
    );
  }

  Future<void> _handleVerifyPin(
    VerifyPinFullEvent event,
    Emitter<PinState> emit,
  ) async {
    emit(state.copyWith(status: RequestStatus.loading, operation: 'verifyPin'));

    final savePinResult = await verifyPinUseCase.execute(event.pin);

    savePinResult.fold(
      (failure) {
        if (failure is ConnectionFailure || failure is ServerFailure) {
          emit(state.copyWith(
              message: failure.message, status: RequestStatus.failure));
        } else {
          emit(state.copyWith(
              message: failure.message, status: RequestStatus.failure));
        }
      },
      (pinData) {
        emit(state.copyWith(
          message: 'Success',
          status: RequestStatus.success,
          pinData: pinData,
        ));
      },
    );
  }

  Future<void> _doWithdrawal(
    DoWithdrawalEvent event,
    Emitter<PinState> emit,
  ) async {
    emit(state.copyWith(
        status: RequestStatus.loading, operation: 'withdrawalReq'));

    final withdrawResult = await withdrawKompoinUseCase.execute(
        event.nominal, event.bankAccountId);

    withdrawResult.fold(
      (failure) {
        if (failure is ConnectionFailure || failure is ServerFailure) {
          emit(state.copyWith(
              message: failure.message, status: RequestStatus.failure));
        } else {
          emit(state.copyWith(
              message: failure.message, status: RequestStatus.failure));
        }
      },
      (withdrawData) {
        emit(state.copyWith(
          message: 'Success',
          status: RequestStatus.success,
        ));
      },
    );
  }

  Future<void> _handlePaymentKompay(
    DoPaymentKompayEvent event,
    Emitter<PinState> emit,
  ) async {
    emit(state.copyWith(
        status: RequestStatus.loading, operation: 'doPaymentKompay'));

    final paymentResult = await doPaymentKompayUseCase.execute(event.id ?? '');

    paymentResult.fold(
      (failure) {
        if (failure is ConnectionFailure || failure is ServerFailure) {
          emit(state.copyWith(
              message: failure.message, status: RequestStatus.failure));
        } else {
          emit(state.copyWith(
              message: failure.message, status: RequestStatus.failure));
        }
      },
      (paymentData) {
        emit(state.copyWith(
          message: 'Success',
          status: RequestStatus.success,
        ));
      },
    );
  }

  Future<void> _forgetPin(
    ForgetPinEvent event,
    Emitter<PinState> emit,
  ) async {
    emit(state.copyWith(status: RequestStatus.loading, operation: 'forgetPin'));

    final forgetPinResult = await forgetPinUseCase.execute();

    forgetPinResult.fold(
      (failure) {
        if (failure is ConnectionFailure || failure is ServerFailure) {
          emit(state.copyWith(
              message: failure.message, status: RequestStatus.failure));
        } else {
          emit(state.copyWith(
              message: failure.message, status: RequestStatus.failure));
        }
      },
      (data) {
        emit(state.copyWith(
            message: 'Success',
            status: RequestStatus.success,
            expiredAt: data,
            otpToken: data.token,
            nextRequestAt: data.nextRequestAt,
            attemptLeft: 0));
      },
    );
  }

  Future<void> _verifyOtp(
    VerifyOtpEvent event,
    Emitter<PinState> emit,
  ) async {
    emit(state.copyWith(status: RequestStatus.loading, operation: 'verifyOtp'));

    final verifyOtpResult =
        await verifyOtpUseCase.execute(event.otp, token: state.otpToken);

    verifyOtpResult.fold(
      (failure) {
        if (failure is ConnectionFailure || failure is ServerFailure) {
          emit(state.copyWith(
              message: failure.message, status: RequestStatus.failure));
        } else {
          emit(state.copyWith(
              message: failure.message, status: RequestStatus.failure));
        }
      },
      (pinData) {
        emit(state.copyWith(
          message: 'Success',
          status: RequestStatus.success,
          pinData: pinData,
          attemptLeft: pinData.attemptLeft,
        ));
      },
    );
  }

  Future<void> _getProfileEmail(
    GetProfileEmail event,
    Emitter<PinState> emit,
  ) async {
    emit(
        state.copyWith(status: RequestStatus.loading, operation: 'getProfile'));
    final profileResult = await getProfileUseCase.execute();

    profileResult.fold(
      (failure) {
        emit(state.copyWith(
            message: failure.message, status: RequestStatus.failure));
      },
      (profileData) {
        emit(state.copyWith(
            message: 'Success',
            status: RequestStatus.success,
            profileData: profileData));
      },
    );
  }

  /// Ambil profil dari local storage (SharedPreferences) tanpa memicu loading.
  /// Dipakai sebagai fallback email di halaman OTP lupa PIN.
  Future<void> _getProfileLocal(
    GetProfileLocalEvent event,
    Emitter<PinState> emit,
  ) async {
    final profileResult = await getLocaleProfileUseCase.execute();

    profileResult.fold(
      (failure) {
        // Gagal baca lokal tidak perlu mengganggu flow — email fallback tetap kosong.
        emit(state.copyWith(
            status: RequestStatus.empty, operation: 'getProfileLocal'));
      },
      (profileData) {
        emit(state.copyWith(
            message: 'Success',
            status: RequestStatus.empty,
            operation: 'getProfileLocal',
            profileData: profileData));
      },
    );
  }

  Future<void> _saveTime(
    SaveTimeEvent event,
    Emitter<PinState> emit,
  ) async {
    emit(state.copyWith(status: RequestStatus.loading, operation: 'saveTime'));

    final savePinResult = await saveTimeUseCase.execute(event.time);

    savePinResult.fold(
      (failure) {
        if (failure is ConnectionFailure || failure is ServerFailure) {
          emit(state.copyWith(
              message: failure.message, status: RequestStatus.failure));
        } else {
          emit(state.copyWith(
              message: failure.message, status: RequestStatus.failure));
        }
      },
      (pinData) {
        emit(state.copyWith(
          message: 'Success',
          status: RequestStatus.success,
        ));
      },
    );
  }

  Future<void> _deleteTime(
    DeletetTimeEvent event,
    Emitter<PinState> emit,
  ) async {
    emit(
        state.copyWith(status: RequestStatus.loading, operation: 'deleteTime'));

    final savePinResult = await deleteTimeUseCase.execute();

    savePinResult.fold(
      (failure) {
        if (failure is ConnectionFailure || failure is ServerFailure) {
          emit(state.copyWith(
              message: failure.message, status: RequestStatus.failure));
        } else {
          emit(state.copyWith(
              message: failure.message, status: RequestStatus.failure));
        }
      },
      (pinData) {
        emit(state.copyWith(
          message: 'Success',
          status: RequestStatus.success,
        ));
      },
    );
  }

  Future<void> _getTime(
    GetTimeEvent event,
    Emitter<PinState> emit,
  ) async {
    emit(state.copyWith(status: RequestStatus.loading, operation: 'getTime'));

    final forgetPinResult = await getTimeUseCase.execute();

    forgetPinResult.fold(
      (failure) {
        if (failure is ConnectionFailure || failure is ServerFailure) {
          emit(state.copyWith(
              message: failure.message, status: RequestStatus.failure));
        } else {
          emit(state.copyWith(
              message: failure.message, status: RequestStatus.failure));
        }
      },
      (data) {
        emit(state.copyWith(
            message: 'Success',
            status: RequestStatus.success,
            expiredAt: data));
      },
    );
  }
}
