import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:komtim_partner/common/enum_status.dart';
import 'package:komtim_partner/core/data/models/topup_qris_response.dart';
import 'package:komtim_partner/core/domain/entities/balance_analytics_model.dart';
import 'package:komtim_partner/core/domain/entities/invoice_detail_model.dart';
import 'package:komtim_partner/core/domain/entities/profile_model.dart';
import 'package:komtim_partner/core/domain/usecases/check_pin_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/get_balance_analytics_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/get_invoice_detail_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/get_profile_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/topup_ceck_transaction_use_case.dart';

import '../../../common/failure.dart';
import '../../../core/domain/entities/check_pin_model.dart';

part 'payment_method_event.dart';
part 'payment_method_state.dart';

class PaymentMethodBloc extends Bloc<PaymentMethodEvent, PaymentMethodState> {
  PaymentMethodBloc({
    required this.getProfileUseCase,
    required this.checkPinUseCase,
    required this.getInvoiceDetailUseCase,
    required this.getBalanceAnalyticsUseCase,
    required this.topUpCeckTransactionUseCase,
  }) : super(const PaymentMethodState()) {
    on<CheckPinEvent>(_handleCheckPinExist);
    on<InvoiceDetailEvent>(_handleInvoiceDetail);
    on<GetProfileEvent>(_handleGetProfile);
    on<GetBalanceAnalyticsEvent>(_handleGetBalanceAnalitics);
    on<LoadDataCecktransactionTopUpEvent>(_handleToUpLoadCeckTransactionEvent);
  }

  final CheckPinUseCase checkPinUseCase;
  final GetInvoiceDetailUseCase getInvoiceDetailUseCase;
  final GetProfileUseCase getProfileUseCase;
  final GetBalanceAnalyticsUseCase getBalanceAnalyticsUseCase;
  final TopUpCeckUseCase topUpCeckTransactionUseCase;

 Future<void> _handleToUpLoadCeckTransactionEvent(
    LoadDataCecktransactionTopUpEvent event,
    Emitter<PaymentMethodState> emit,
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
              message: failure.message,
              status: RequestStatus.failure));
        } else {
          emit(state.copyWith(
              message: failure.message, status: RequestStatus.empty));
        }
      },
      (transcationCeckData) {
        emit(state.copyWith(
            message: 'Success',
            status: RequestStatus.success,
            detailTopup: transcationCeckData));
      },
    );
  }
  Future<void> _handleGetBalanceAnalitics(
    GetBalanceAnalyticsEvent event,
    Emitter<PaymentMethodState> emit,
  ) async {
    emit(state.copyWith(
        status: RequestStatus.loading, operation: 'getBalanceAnalytics'));
    final result = await getBalanceAnalyticsUseCase.execute(event.id ?? 0);
    await result.fold(
      (failure) async {
        emit(state.copyWith(
            message: failure.message, status: RequestStatus.failure));
      },
      (balanceData) async {
        emit(state.copyWith(
            message: 'Success',
            operation: 'getBalanceAnalytics',
            status: RequestStatus.success,
            balanceData: balanceData.data));
      },
    );
  }

  Future<void> _handleGetProfile(
    GetProfileEvent event,
    Emitter<PaymentMethodState> emit,
  ) async {
    emit(
        state.copyWith(status: RequestStatus.loading, operation: 'getProfile'));
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

  Future<void> _handleInvoiceDetail(
    InvoiceDetailEvent event,
    Emitter<PaymentMethodState> emit,
  ) async {
    emit(state.copyWith(
        status: RequestStatus.loading, operation: 'getInvoiceDetail'));

    final invoicesResult =
        await getInvoiceDetailUseCase.execute(event.invoiceId ?? '0');

    invoicesResult.fold(
      (failure) {
        emit(state.copyWith(
            message: failure.message, status: RequestStatus.failure));
      },
      (invoiceDetail) {
        emit(state.copyWith(
            message: 'Success',
            status: RequestStatus.success,
            invoiceDetail: invoiceDetail,
            operation: 'getInvoiceDetail'));
      },
    );
  }

  Future<void> _handleCheckPinExist(
    CheckPinEvent event,
    Emitter<PaymentMethodState> emit,
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
            operation: 'checkPinExist'));
      },
    );
  }
}
