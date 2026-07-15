import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../../../core/domain/entities/create_invoice_model.dart';
import '../../../../../../core/domain/usecases/create_invoice_use_case.dart';

part 'create_invoice_event.dart';
part 'create_invoice_state.dart';

class CreateInvoiceBloc extends Bloc<CreateInvoiceEvent, CreateInvoiceState> {
  final CreateInvoiceUseCase createInvoiceUseCase;

  CreateInvoiceBloc({required this.createInvoiceUseCase})
      : super(CreateInvoiceInitial()) {
    on<DoCreateInvoice>((event, emit) async {
      emit(CreateInvoiceLoading());
      final result = await createInvoiceUseCase(
        description: event.description,
        amount: event.amount,
        invoiceDuration: event.invoiceDuration,
      );

      result.fold(
        (l) => emit(CreateInvoiceFailed(l.message)),
        (r) => emit(CreateInvoiceSuccess(r)),
      );
    });
  }
}
