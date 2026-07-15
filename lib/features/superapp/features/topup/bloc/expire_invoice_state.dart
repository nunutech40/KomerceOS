part of 'expire_invoice_bloc.dart';

abstract class ExpireInvoiceState extends Equatable {
  const ExpireInvoiceState();
  
  @override
  List<Object> get props => [];
}

class ExpireInvoiceInitial extends ExpireInvoiceState {}

class ExpireInvoiceLoading extends ExpireInvoiceState {}

class ExpireInvoiceSuccess extends ExpireInvoiceState {}

class ExpireInvoiceError extends ExpireInvoiceState {
  final String message;

  const ExpireInvoiceError(this.message);

  @override
  List<Object> get props => [message];
}
