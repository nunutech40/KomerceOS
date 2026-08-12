part of 'invoice_report_summary_bloc.dart';

class InvoiceDetailState extends Equatable {
  const InvoiceDetailState({
    this.message = '',
    this.status = RequestStatus.empty,
    this.statusEvaluation = RequestStatus.dataExhausted,
    this.invoiceDetail,
    this.invoiceCheckEvaluation,
    this.xenditUrl,
    this.isDownloading = false,
    this.operation = '',
  });

  final String message;
  final RequestStatus status;
  final RequestStatus statusEvaluation;
  final InvoiceDetailModel? invoiceDetail;
  final CheckEvaluationResponse? invoiceCheckEvaluation;
  final String? xenditUrl;
  final bool isDownloading;
  final String operation;

  InvoiceDetailState copyWith({
    RequestStatus? status,
    RequestStatus? statusEvaluation,
    String? message,
    InvoiceDetailModel? invoiceDetail,
    CheckEvaluationResponse? invoiceCheckEvaluation,
    String? xenditUrl,
    bool? isDownloading,
    String? operation,
  }) {
    return InvoiceDetailState(
        status: status ?? this.status,
        statusEvaluation: statusEvaluation ?? this.statusEvaluation,
        message: message ?? this.message,
        invoiceDetail: invoiceDetail ?? this.invoiceDetail,
        invoiceCheckEvaluation:
            invoiceCheckEvaluation ?? this.invoiceCheckEvaluation,
        xenditUrl: xenditUrl ?? this.xenditUrl,
        operation: operation ?? this.operation,
        isDownloading: isDownloading ?? this.isDownloading);
  }

  @override
  List<Object?> get props => [
        message,
        status,
        statusEvaluation,
        invoiceDetail,
        invoiceCheckEvaluation,
        xenditUrl,
        isDownloading,
        operation,
      ];
}
