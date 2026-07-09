import 'package:equatable/equatable.dart';
import 'package:komtim_partner/core/domain/entities/invoice_detail_model.dart';

class InvoiceDetailResponse extends Equatable {
  final int? invoiceId;
  final String? invoiceCode;
  final bool? isPaid;
  final int? adminFeeAmount;
  final num taxAmount;
  final num ppnAmount;
  final int? talentSalaryAmount;
  final int? appsServiceAmount;
  final int? amountTotal;
  final String? xenditPaymentUrl;
  final num? subTotal1;
  final num? subTotal2;
  final String transactionStatus;
  final String? expiredAt;
  final String? createdAt;
  final String? updatedAt;
  final int? additionalCost;
  final bool? hideCosts;
  final String? notes;
  final String? paymentBy;
  final String? dueDate;

  const InvoiceDetailResponse({
    required this.invoiceId,
    required this.invoiceCode,
    required this.isPaid,
    required this.adminFeeAmount,
    this.taxAmount = 0,
    required this.talentSalaryAmount,
    required this.appsServiceAmount,
    required this.amountTotal,
    required this.ppnAmount,
    required this.xenditPaymentUrl,
    required this.subTotal1,
    required this.subTotal2,
    required this.transactionStatus,
    required this.expiredAt,
    required this.createdAt,
    required this.updatedAt,
    required this.additionalCost,
    required this.hideCosts,
    required this.notes,
    required this.paymentBy,
    required this.dueDate,
  });

  Map<String, dynamic> toJson() => {
        "invoice_id": invoiceId,
        "invoice_code": invoiceCode,
        "is_paid": isPaid,
        "admin_fee_amount": adminFeeAmount,
        "tax_amount": taxAmount,
        "ppn_amount": ppnAmount,
        "talent_salary_amount": talentSalaryAmount,
        "apps_service_amount": appsServiceAmount,
        "amount_total": amountTotal,
        "xendit_payment_url": xenditPaymentUrl,
        "sub_total_1": subTotal1,
        "sub_total_2": subTotal2,
        "transaction_status": transactionStatus,
        "expired_at": expiredAt,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "additional_cost": additionalCost,
        "hide_costs": hideCosts,
        "notes": notes,
        "payment_by": paymentBy,
        "due_date": dueDate,
      };

  factory InvoiceDetailResponse.fromJson(Map<String, dynamic> json) {
    return InvoiceDetailResponse(
      invoiceId: json['invoice_id'],
      invoiceCode: json['invoice_code'],
      isPaid: json['is_paid'],
      adminFeeAmount: json['admin_fee_amount'],
      taxAmount: json['tax_amount'],
      ppnAmount: json['ppn_amount'] ?? 0,
      talentSalaryAmount: json['talent_salary_amount'],
      appsServiceAmount: json['apps_service_amount'],
      amountTotal: json['amount_total'],
      xenditPaymentUrl: json['xendit_payment_url'],
      subTotal1: json['sub_total_1'],
      subTotal2: json['sub_total_2'],
      transactionStatus: json['transaction_status'],
      expiredAt: json['expired_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      additionalCost: json['additional_cost'],
      hideCosts: json['hide_costs'],
      notes: json['notes'],
      paymentBy: json['payment_by'],
      dueDate: json['due_date'],
    );
  }

  InvoiceDetailModel toEntity() {
    return InvoiceDetailModel(
      invoiceId: invoiceId,
      invoiceCode: invoiceCode,
      isPaid: isPaid,
      adminFeeAmount: adminFeeAmount,
      taxAmount: taxAmount,
      ppnAmount: ppnAmount,
      talentSalaryAmount: talentSalaryAmount,
      appsServiceAmount: appsServiceAmount,
      amountTotal: amountTotal,
      xenditPaymentUrl: xenditPaymentUrl,
      subTotal1: subTotal1,
      subTotal2: subTotal2,
      transactionStatus: transactionStatus,
      expiredAt: expiredAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      additionalCost: additionalCost,
      hideCosts: hideCosts,
      notes: notes,
      paymentBy: paymentBy,
      dueDate: dueDate,
    );
  }

  @override
  List<Object?> get props => [
        invoiceId,
        invoiceCode,
        isPaid,
        adminFeeAmount,
        taxAmount,
        ppnAmount,
        talentSalaryAmount,
        appsServiceAmount,
        amountTotal,
        xenditPaymentUrl,
        subTotal1,
        subTotal2,
        transactionStatus,
        expiredAt,
        createdAt,
        updatedAt,
        additionalCost,
        hideCosts,
        notes,
        paymentBy,
        dueDate,
      ];
}

class CheckEvaluationResponse extends Equatable {
  final int? invoiceId;
  final String? invoiceCode;
  final String? xenditPaymentUrl;

  const CheckEvaluationResponse(
      {required this.invoiceId,
      required this.invoiceCode,
      required this.xenditPaymentUrl});

  Map<String, dynamic> toJson() => {
        "invoice_id": invoiceId,
        "invoice_code": invoiceCode,
        "xendit_payment_link": xenditPaymentUrl,
      };

  factory CheckEvaluationResponse.fromJson(Map<String, dynamic> json) {
    return CheckEvaluationResponse(
      invoiceId: json['invoice_id'],
      invoiceCode: json['invoice_code'],
      xenditPaymentUrl: json['xendit_payment_link'],
    );
  }

  CheckEvaluationResponse toEntity() {
    return CheckEvaluationResponse(
      invoiceId: invoiceId,
      invoiceCode: invoiceCode,
      xenditPaymentUrl: xenditPaymentUrl,
    );
  }

  @override
  List<Object?> get props => [
        invoiceId,
        invoiceCode,
        xenditPaymentUrl,
      ];
}
