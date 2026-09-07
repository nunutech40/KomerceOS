part of 'payment_method_bloc.dart';

abstract class PaymentMethodEvent extends Equatable {
  const PaymentMethodEvent();

  @override
  List<Object?> get props => [];
}

class CheckPinEvent extends PaymentMethodEvent {
  const CheckPinEvent();
}


class InvoiceDetailEvent extends PaymentMethodEvent {
  final String? invoiceId;

  const InvoiceDetailEvent({this.invoiceId});

  @override
  List<Object?> get props => [invoiceId];
}

class GetProfileEvent extends PaymentMethodEvent {
  const GetProfileEvent();
}

class GetBalanceAnalyticsEvent extends PaymentMethodEvent {
 final int? id;

  const GetBalanceAnalyticsEvent({this.id});

  @override
  List<Object?> get props => [id];
}

class LoadDataCecktransactionTopUpEvent extends PaymentMethodEvent {
  final String typeCheckTrasaction;
  const LoadDataCecktransactionTopUpEvent({required this.typeCheckTrasaction});

  @override
  List<Object> get props => [typeCheckTrasaction];
}

class CheckActiveBillEvent extends PaymentMethodEvent {
  const CheckActiveBillEvent();

  @override
  List<Object?> get props => [];
}