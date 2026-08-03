part of 'invoice_list_bloc.dart';

class InvoiceListState extends Equatable {
  const InvoiceListState({
    this.message = '',
    this.status = RequestStatus.empty,
    this.invoicesData,
  });

  final String message;
  final RequestStatus status;
  final List<InvoicesDataModel>? invoicesData;

  InvoiceListState copyWith({
    RequestStatus? status,
    String? message,
    List<InvoicesDataModel>? invoicesData,
  }) {
    return InvoiceListState(
      status: status ?? this.status,
      message: message ?? this.message,
      invoicesData: invoicesData ?? this.invoicesData,
    );
  }

  @override
  List<Object?> get props => [
        message,
        status,
        invoicesData,
      ];
}
