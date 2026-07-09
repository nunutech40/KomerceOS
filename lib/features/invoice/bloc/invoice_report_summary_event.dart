part of 'invoice_report_summary_bloc.dart';

@immutable
abstract class InvoiceDetailEvent extends Equatable {
  const InvoiceDetailEvent();

  @override
  List<Object?> get props => [];
}

class InvoviceDetailPageDidload extends InvoiceDetailEvent {
  final String invoiceId;

  const InvoviceDetailPageDidload(this.invoiceId);

  @override
  List<Object?> get props => [invoiceId];
}

class InvoiceDownloadFile extends InvoiceDetailEvent {
  final String invoiceId;

  const InvoiceDownloadFile(this.invoiceId);

  @override
  List<Object?> get props => [invoiceId];
}

class CopyInvoiceDetail extends InvoiceDetailEvent {
  final String xenditUrl;
  const CopyInvoiceDetail(this.xenditUrl);

  @override
  List<Object?> get props => [xenditUrl];
}

class CheckEvalutionEvent extends InvoiceDetailEvent {
  final String invoiceId;

  const CheckEvalutionEvent(this.invoiceId);

  @override
  List<Object?> get props => [invoiceId];
}
