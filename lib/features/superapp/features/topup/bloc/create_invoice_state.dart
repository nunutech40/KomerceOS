part of 'create_invoice_bloc.dart';

abstract class CreateInvoiceState extends Equatable {
  const CreateInvoiceState();

  @override
  List<Object> get props => [];
}

class CreateInvoiceInitial extends CreateInvoiceState {}

class CreateInvoiceLoading extends CreateInvoiceState {}

class CreateInvoiceSuccess extends CreateInvoiceState {
  final CreateInvoiceModel data;

  const CreateInvoiceSuccess(this.data);

  @override
  List<Object> get props => [data];
}

class CreateInvoiceFailed extends CreateInvoiceState {
  final String message;

  const CreateInvoiceFailed(this.message);

  @override
  List<Object> get props => [message];
}
