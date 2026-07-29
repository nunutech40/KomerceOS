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
  final Failure failure;

  const ExpireInvoiceError(this.failure);

  bool get isServerError => failure is ServerFailure;
  String get message => failure.message;

  @override
  List<Object> get props => [failure];
}
