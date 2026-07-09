import 'package:equatable/equatable.dart';
import 'package:komtim_partner/core/domain/entities/invoices_model.dart';
import 'package:komtim_partner/core/domain/usecases/get_invoices_use_case.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:komtim_partner/common/enum_status.dart';

import '../../../common/failure.dart';

part 'invoice_list_event.dart';
part 'invoice_list_state.dart';

class InvoiceListBloc extends Bloc<InvoiceListEvent, InvoiceListState> {
  InvoiceListBloc({required this.getInvoiceUseCase})
      : super(const InvoiceListState()) {
    on<InvoviceListPageDidload>(_handleDidLoadPage);
    on<RefreshDataEvent>(_refresStateAndEvent);
  }

  final GetInvoiceUseCase getInvoiceUseCase;

  Future<void> _refresStateAndEvent(
    RefreshDataEvent event,
    Emitter<InvoiceListState> emit,
  ) async {
    emit(const InvoiceListState());
  }

  Future<void> _handleDidLoadPage(
    InvoviceListPageDidload event,
    Emitter<InvoiceListState> emit,
  ) async {
    emit(state.copyWith(status: RequestStatus.loading));

    final invoicesResult =
        await getInvoiceUseCase.execute(event.type, event.offset, event.limit);

    invoicesResult.fold(
      (failure) {
        if (failure is ConnectionFailure || failure is ServerFailure) {
          emit(state.copyWith(
              message: failure.message, status: RequestStatus.failure));
        } else {
          emit(state.copyWith(
              message: failure.message, status: RequestStatus.failure));
        }
      },
      (invoicesData) {
        emit(state.copyWith(
            message: 'Success',
            status: RequestStatus.success,
            invoicesData: invoicesData));
      },
    );
  }
}
