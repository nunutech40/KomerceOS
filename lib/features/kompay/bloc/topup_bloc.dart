import 'package:komtim_partner/common/failure.dart';
import 'package:komtim_partner/core/domain/usecases/topup_cancel_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/topup_ceck_transaction_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/topup_detail_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/topup_qris_usecase.dart';
import 'package:komtim_partner/core/domain/usecases/topup_usecase.dart';

import 'package:bloc/bloc.dart';
import 'package:komtim_partner/features/kompay/bloc/topup_event.dart';
import 'package:komtim_partner/features/kompay/bloc/topup_state.dart';
import '../../../../common/enum_status.dart';

class TopUpBloc extends Bloc<TopupEvent, TopupState> {
  final TopUpUseCase topUpUseCase;
  final TopUpQrisUseCase topUpQrissUseCase;
  final TopUpDetailuseCase topUpDetailUseCase;
  final TopUpCeckUseCase topUpCeckTransactionUseCase;
  final TopUpCancelUseCase topUpCancelUseCase;

  TopUpBloc({
    required this.topUpUseCase,
    required this.topUpQrissUseCase,
    required this.topUpDetailUseCase,
    required this.topUpCeckTransactionUseCase,
    required this.topUpCancelUseCase,
  }) : super(const TopupState()) {
    on<TopUpButtonPressedEvent>(_handleTopUpEvent);
    on<TopUpButtonPressedQrisEvent>(_handleTopUpQrisEvent);
    on<LoadDataDetailTopUpEvent>(_handleToUpLoadDetailEvent);
    on<LoadDataCecktransactionTopUpEvent>(_handleToUpLoadCeckTransactionEvent);
    on<CancelTopUpEvent>(_handleCancelTopUpEvent);
  }

  Future<void> _handleTopUpEvent(
    TopUpButtonPressedEvent event,
    Emitter<TopupState> emit,
  ) async {
    int? adminFee;

    if (int.parse(event.nominal) <= 500000 && event.jenisTf == "Bank") {
      adminFee = 1000;
    } else {
      adminFee = 0;
    }

    // Emit the loading state first
    emit(state.copyWith(status: RequestStatus.loading));

    final result = await topUpUseCase.execute(event.nominal, adminFee);
    result.fold(
      (failure) {
        if (failure is ConnectionFailure || failure is ServerFailure) {
          emit(state.copyWith(
              message: failure.message, status: RequestStatus.failure));
        } else {
          emit(state.copyWith(
              message: failure.message, status: RequestStatus.failure));
        }
      },
      (transcationData) {
        emit(state.copyWith(
          message: 'Success',
          status: RequestStatus.success,
          dataTopUpBank: transcationData,
        ));
      },
    );
  }

  Future<void> _handleTopUpQrisEvent(
    TopUpButtonPressedQrisEvent event,
    Emitter<TopupState> emit,
  ) async {
    // Emit the loading state first
    emit(state.copyWith(status: RequestStatus.loading));
    // await Future.delayed(const Duration(seconds: 2));
    final result = await topUpQrissUseCase.execute(event.nominal);
    result.fold(
      (failure) {
        if (failure is ConnectionFailure || failure is ServerFailure) {
          emit(state.copyWith(
              message: failure.message, status: RequestStatus.failure));
        } else {
          emit(state.copyWith(
              message: failure.message, status: RequestStatus.failure));
        }
      },
      (transcationDataQris) {
        emit(state.copyWith(
            message: 'Success',
            status: RequestStatus.success,
            dataResponseQris: transcationDataQris));
      },
    );
  }

  Future<void> _handleToUpLoadDetailEvent(
    LoadDataDetailTopUpEvent event,
    Emitter<TopupState> emit,
  ) async {
    // Emit the loading state first
    emit(state.copyWith(status: RequestStatus.loading));
    // await Future.delayed(const Duration(seconds: 2));
    final result = await topUpDetailUseCase.execute(event.id);
    result.fold(
      (failure) {
        if (failure is ConnectionFailure || failure is ServerFailure) {
          emit(state.copyWith(
              message: failure.message, status: RequestStatus.failure));
        } else {
          emit(state.copyWith(
              message: failure.message, status: RequestStatus.failure));
        }
      },
      (transcationDetailData) {
        emit(state.copyWith(
            message: 'Success',
            status: RequestStatus.success,
            dataResponseDetail: transcationDetailData));
      },
    );
  }

  Future<void> _handleToUpLoadCeckTransactionEvent(
    LoadDataCecktransactionTopUpEvent event,
    Emitter<TopupState> emit,
  ) async {
    // Emit the loading state first
    emit(state.copyWith(status: RequestStatus.loading));
    // await Future.delayed(const Duration(seconds: 2));
    final result =
        await topUpCeckTransactionUseCase.execute(event.typeCheckTrasaction);
    result.fold(
      (failure) {
        if (failure is ConnectionFailure || failure is ServerFailure) {
          emit(state.copyWith(
              message: failure.message, status: RequestStatus.failure));
        } else {
          emit(state.copyWith(
              message: failure.message, status: RequestStatus.empty));
        }
      },
      (transcationCeckData) {
        emit(state.copyWith(
            message: 'Success',
            status: RequestStatus.success,
            dataResponseCeckData: transcationCeckData));
      },
    );
  }

  Future<void> _handleCancelTopUpEvent(
    CancelTopUpEvent event,
    Emitter<TopupState> emit,
  ) async {
    // Emit the loading state first
    emit(state.copyWith(status: RequestStatus.loading));

    // await Future.delayed(const Duration(seconds: 2));
    final result = await topUpCancelUseCase.execute(event.id);
    result.fold(
      (failure) {
        if (failure is ConnectionFailure || failure is ServerFailure) {
          emit(state.copyWith(
              message: failure.message, status: RequestStatus.failure));
        } else {
          emit(state.copyWith(
              message: failure.message, status: RequestStatus.failure));
        }
      },
      (transcationCancelTopUp) {
        emit(state.copyWith(
          message: 'Success',
          status: RequestStatus.success,
        ));
      },
    );
  }
}
