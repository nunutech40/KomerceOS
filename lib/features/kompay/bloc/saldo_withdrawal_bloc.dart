import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:komtim_partner/common/enum_status.dart';
import 'package:komtim_partner/core/domain/entities/bank_accounts_model.dart';
import 'package:komtim_partner/core/domain/entities/ideal_balance_model.dart';
import 'package:komtim_partner/core/domain/usecases/check_pin_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/get_bank_list_withdrawal_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/get_ideal_balance_use_case.dart';

import '../../../common/failure.dart';
import '../../../core/domain/entities/check_pin_model.dart';

part 'saldo_withdrawal_event.dart';
part 'saldo_withdrawal_state.dart';

class SaldoWithdrawalBloc
    extends Bloc<SaldoWithdrawalEvent, SaldoWitdrawalState> {
  SaldoWithdrawalBloc({
    required this.getBankListWithdrawalUseCase,
    required this.checkPinUseCase,
    required this.idealBalanceUseCase,
  }) : super(const SaldoWitdrawalState()) {
    on<BankDataLoad>(_handleBankDataLoad);
    on<NextPressedButtonEvent>(_handleCheckPinExist);
    on<RefreshDataEvent>(_refresStateAndEvent);
    on<IdealBalanceEvent>(_handleIdealBalance);
  }

  GetBankListWithdrawalUseCase getBankListWithdrawalUseCase;
  CheckPinUseCase checkPinUseCase;
  GetIdealBalanceUseCase idealBalanceUseCase;

  Future<void> _refresStateAndEvent(
    RefreshDataEvent event,
    Emitter<SaldoWitdrawalState> emit,
  ) async {
    emit(const SaldoWitdrawalState());
  }

  Future<void> _handleBankDataLoad(
    BankDataLoad event,
    Emitter<SaldoWitdrawalState> emit,
  ) async {
    emit(state.copyWith(
        status: RequestStatus.loading, operation: 'getBankList'));

    final bankResult = await getBankListWithdrawalUseCase.execute();

    bankResult.fold(
      (failure) {
        if (failure is ConnectionFailure || failure is ServerFailure) {
          emit(state.copyWith(
              message: failure.message, status: RequestStatus.failure));
        } else {
          emit(state.copyWith(
              message: failure.message, status: RequestStatus.failure));
        }
      },
      (bankDataList) {
        emit(state.copyWith(
          message: 'Success',
          status: RequestStatus.success,
          bankList: bankDataList,
        ));
      },
    );
  }

  Future<void> _handleCheckPinExist(
    NextPressedButtonEvent event,
    Emitter<SaldoWitdrawalState> emit,
  ) async {
    emit(state.copyWith(
        status: RequestStatus.loading, operation: 'checkPinExist'));

    final pinResult = await checkPinUseCase.execute();

    pinResult.fold(
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

  Future<void> _handleIdealBalance(
    IdealBalanceEvent event,
    Emitter<SaldoWitdrawalState> emit,
  ) async {
    emit(state.copyWith(
        status: RequestStatus.loading, operation: 'idealBalanceCheck'));

    final saldoResult =
        await idealBalanceUseCase.call(partnerId: event.partnerId);

    saldoResult.fold(
      (failure) {
        if (failure is ConnectionFailure || failure is ServerFailure) {
          emit(state.copyWith(
              message: failure.message, status: RequestStatus.failure));
        } else {
          emit(state.copyWith(
              message: failure.message, status: RequestStatus.failure));
        }
      },
      (idealBalance) {
        emit(state.copyWith(
          message: 'Success',
          status: RequestStatus.success,
          operation: 'idealBalanceCheck',
          idealBalance: idealBalance,
        ));
      },
    );
  }
}
