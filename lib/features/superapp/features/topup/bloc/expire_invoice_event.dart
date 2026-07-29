part of 'expire_invoice_bloc.dart';

abstract class ExpireInvoiceEvent extends Equatable {
  const ExpireInvoiceEvent();

  @override
  List<Object> get props => [];
}

class SubmitExpireInvoiceEvent extends ExpireInvoiceEvent {
  final String id;

  const SubmitExpireInvoiceEvent(this.id);

  @override
  List<Object> get props => [id];
}
