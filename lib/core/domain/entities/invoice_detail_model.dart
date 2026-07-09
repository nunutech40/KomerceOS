import 'package:equatable/equatable.dart';

class InvoiceDetailModel extends Equatable {
  int? invoiceId;
  String? invoiceCode;
  bool? isPaid;
  int? adminFeeAmount;
  num taxAmount;
  int? talentSalaryAmount;
  int? appsServiceAmount;
  int? amountTotal;
  num ppnAmount;
  String? xenditPaymentUrl;
  String? expiredAt;
  String? createdAt;
  String? updatedAt;
  num? subTotal1;
  num? subTotal2;
  String? transactionStatus;
  final int? additionalCost;
  final bool? hideCosts;
  final String? notes;
  String? paymentBy;
  String? dueDate;

  InvoiceDetailModel({
    this.invoiceId,
    this.invoiceCode,
    this.isPaid = false,
    this.adminFeeAmount,
    this.taxAmount = 0,
    this.talentSalaryAmount,
    this.appsServiceAmount,
    this.amountTotal,
    this.ppnAmount = 0,
    this.xenditPaymentUrl,
    this.subTotal1,
    this.subTotal2,
    this.expiredAt,
    this.createdAt,
    this.updatedAt,
    this.transactionStatus,
    this.additionalCost,
    this.hideCosts,
    this.notes,
    this.paymentBy,
    this.dueDate,
  });

  @override
  List<Object?> get props => [
        invoiceId,
        invoiceCode,
        isPaid,
        adminFeeAmount,
        taxAmount,
        talentSalaryAmount,
        appsServiceAmount,
        amountTotal,
        ppnAmount,
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
