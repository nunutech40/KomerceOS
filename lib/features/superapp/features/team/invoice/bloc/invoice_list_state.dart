part of 'invoice_list_bloc.dart';

class InvoiceListState extends Equatable {
  const InvoiceListState({
    this.message = '',
    this.status = RequestStatus.empty,
    this.invoicesData,
    this.needProcessData,
  });

  final String message;
  final RequestStatus status;
  final List<InvoicesDataModel>? invoicesData;
  final List<InvoicesDataModel>? needProcessData;

  InvoiceListState copyWith({
    RequestStatus? status,
    String? message,
    List<InvoicesDataModel>? invoicesData,
    List<InvoicesDataModel>? needProcessData,
  }) {
    return InvoiceListState(
      status: status ?? this.status,
      message: message ?? this.message,
      invoicesData: invoicesData ?? this.invoicesData,
      needProcessData: needProcessData ?? this.needProcessData,
    );
  }

  @override
  List<Object?> get props => [
        message,
        status,
        invoicesData,
        needProcessData,
      ];
}
