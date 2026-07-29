import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komtim_partner/common/failure.dart';
import 'package:komtim_partner/core/domain/usecases/expire_invoice_use_case.dart';

part 'expire_invoice_event.dart';
part 'expire_invoice_state.dart';

class ExpireInvoiceBloc extends Bloc<ExpireInvoiceEvent, ExpireInvoiceState> {
  final ExpireInvoiceUseCase expireInvoiceUseCase;

  ExpireInvoiceBloc({required this.expireInvoiceUseCase}) : super(ExpireInvoiceInitial()) {
    on<SubmitExpireInvoiceEvent>(_onSubmit);
  }

  void _onSubmit(SubmitExpireInvoiceEvent event, Emitter<ExpireInvoiceState> emit) async {
    try {
      emit(ExpireInvoiceLoading());
      final result = await expireInvoiceUseCase.call(event.id);
      result.fold(
        (failure) => emit(ExpireInvoiceError(failure)),
        (data) => emit(ExpireInvoiceSuccess()),
      );
    } catch (e) {
      emit(ExpireInvoiceError(UnknownFailure(e.toString())));
    }
  }
}
