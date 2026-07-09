import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:komtim_partner/core/data/models/topup_qris_response.dart';
import 'package:komtim_partner/core/domain/entities/profile_model.dart';

import 'package:komtim_partner/core/domain/entities/talents_model.dart';
import 'package:komtim_partner/core/domain/entities/topup_kompoin_model.dart';
import 'package:komtim_partner/core/domain/entities/transaction_history_model.dart';
import 'package:bloc/bloc.dart';
import 'package:komtim_partner/core/domain/usecases/get_profile_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/get_transaction_history_need_process_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/topup_detail_use_case.dart';

import '../../../common/enum_status.dart';
import '../../../common/failure.dart';
import '../../../core/domain/usecases/get_transaction_history_use_case.dart';

part 'history_page_state.dart';
part 'history_page_event.dart';

class HistoryPageBloc extends Bloc<HistoryPageEvent, HistoryPageState> {
  HistoryPageBloc({
    required this.getTransactionHistoryUseCase,
    required this.getTransactionNeedProcessHistoryUseCase,
    required this.topUpDetailUseCase,
    required this.getProfileUseCase,
  }) : super(const HistoryPageState()) {
    on<TransactionHistoryLoad>(_handleLoadDataTransactionHistory);
    on<RefreshDataEvent>(_refresStateAndEvent);
    on<TransactionNeedProcessHistoryLoad>(
        _handleLoadDataTransactionNeedProcessHistory);
    on<ClearHistory>(_handleClearHostory);
    on<LoadDataDetailTopUpEvent>(_handleToUpLoadDetailEvent);
    on<HomePageDidload>(_handleHomePageDidload);
  }

  final GetTransactionHistoryUseCase getTransactionHistoryUseCase;
  final GetTransactionNeedProcessHistoryUseCase
      getTransactionNeedProcessHistoryUseCase;
  final TopUpDetailuseCase topUpDetailUseCase;
  final GetProfileUseCase getProfileUseCase;

  Future<void> _refresStateAndEvent(
    RefreshDataEvent event,
    Emitter<HistoryPageState> emit,
  ) async {
    emit(const HistoryPageState());
  }

  Future<void> _handleLoadDataTransactionHistory(
    TransactionHistoryLoad event,
    Emitter<HistoryPageState> emit,
  ) async {
    emit(state.copyWith(
        status: RequestStatus.loading, operation: 'transactionHistory'));

    final transactionResult = await getTransactionHistoryUseCase.execute(
        event.type, event.offset, event.limit);

    transactionResult.fold(
      (failure) {
        if (failure is ConnectionFailure || failure is ServerFailure) {
          emit(state.copyWith(
              message: failure.message, status: RequestStatus.failure));
        } else {
          emit(state.copyWith(
              message: failure.message, status: RequestStatus.failure));
        }
      },
      (transactionData) {
        emit(state.copyWith(
          message: 'Success',
          status: RequestStatus.success,
          transactionHistoryData: transactionData,
        ));
      },
    );
  }

  Future<void> _handleLoadDataTransactionNeedProcessHistory(
    TransactionNeedProcessHistoryLoad event,
    Emitter<HistoryPageState> emit,
  ) async {
    emit(state.copyWith(
        status: RequestStatus.loading, operation: 'transactionHistory'));

    final transactionResult =
        await getTransactionNeedProcessHistoryUseCase.execute();

    transactionResult.fold(
      (failure) {
        if (failure is ConnectionFailure || failure is ServerFailure) {
          emit(state.copyWith(
              message: failure.message, status: RequestStatus.failure));
        } else {
          emit(state.copyWith(
              message: failure.message, status: RequestStatus.failure));
        }
      },
      (transactionData) {
        emit(state.copyWith(
          message: 'Success',
          status: RequestStatus.success,
          transactionNeedHistoryHistoryData: transactionData,
        ));
      },
    );
  }

  Future<void> _handleClearHostory(
    ClearHistory event,
    Emitter<HistoryPageState> emit,
  ) async {
    state.transactionHistoryData.clear();
  }

  Future<void> _handleToUpLoadDetailEvent(
    LoadDataDetailTopUpEvent event,
    Emitter<HistoryPageState> emit,
  ) async {
    // Emit the loading state first
    emit(state.copyWith(statusDetail: RequestStatus.loading));
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
            statusDetail: RequestStatus.success,
            dataResponseDetail: transcationDetailData));
      },
    );
  }

  Future<void> _handleHomePageDidload(
    HomePageDidload event,
    Emitter<HistoryPageState> emit,
  ) async {
    emit(
        state.copyWith(status: RequestStatus.loading, operation: 'getProfile'));
    // await Future.delayed(const Duration(seconds: 10));
    final profileResult = await getProfileUseCase.execute();

    await profileResult.fold(
      (failure) async {
        emit(state.copyWith(
            message: failure.message, status: RequestStatus.failure));
      },
      (profileData) async {
        emit(state.copyWith(
          message: 'Success',
          operation: 'getProfile',
          status: RequestStatus.success,
          profileData: profileData,
        ));
      },
    );
  }
}
