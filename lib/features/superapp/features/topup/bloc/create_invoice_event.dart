part of 'create_invoice_bloc.dart';

abstract class CreateInvoiceEvent extends Equatable {
  const CreateInvoiceEvent();

  @override
  List<Object> get props => [];
}

class DoCreateInvoice extends CreateInvoiceEvent {
  final String description;
  final int amount;
  final int invoiceDuration;

  const DoCreateInvoice({
    required this.description,
    required this.amount,
    required this.invoiceDuration,
  });

  @override
  List<Object> get props => [description, amount, invoiceDuration];
}
