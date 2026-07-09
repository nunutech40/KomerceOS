import 'package:equatable/equatable.dart';
import 'package:komtim_partner/core/domain/entities/invoices_model.dart';


class InvoicesResponse extends Equatable {
  final List<InvoicesResponseData>? data;

  const InvoicesResponse({required this.data});

  Map<String, dynamic> toJson() => {
        "data": data?.map((item) => item.toJson()).toList(),
      };

  factory InvoicesResponse.fromJson(Map<String, dynamic> json) {
    return InvoicesResponse(
      data: (json['data'] as List<dynamic>)
          .map((item) => InvoicesResponseData.fromJson(item))
          .toList(),
    );
  }

  InvoicesModel toEntity() {
    return InvoicesModel(
      data: data
          ?.map((item) => item.toEntity())
          .toList(), // Map each item to entity
    );
  }

  @override
  List<Object?> get props => [data];
}

class InvoicesResponseData extends Equatable {
  final int invoiceId;
  final String invoiceCode;
  final bool isPaid;
  final int amountTotal;
  final String expiredAt;
  final String createdAt;
  final String updatedAt;

  const InvoicesResponseData(
      {required this.invoiceId,
      required this.invoiceCode,
      required this.isPaid,
      required this.amountTotal,
      required this.expiredAt,
      required this.createdAt,
      required this.updatedAt});

  Map<String, dynamic> toJson() => {
        "invoice_id": invoiceId,
        "invoice_code": invoiceCode,
        "is_paid": isPaid,
        "amount_total": amountTotal,
        "expired_at": expiredAt,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };

  factory InvoicesResponseData.fromJson(Map<String, dynamic> json) {
    return InvoicesResponseData(
      invoiceId: json['invoice_id'],
      invoiceCode: json['invoice_code'],
      isPaid: json['is_paid'],
      amountTotal: json['amount_total'],
      expiredAt: json['expired_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  InvoicesDataModel toEntity() {
    return InvoicesDataModel(
      invoiceId: invoiceId,
      invoiceCode: invoiceCode,
      isPaid: isPaid,
      amountTotal: amountTotal,
      expiredAt: expiredAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        invoiceId,
        invoiceCode,
        isPaid,
        amountTotal,
        expiredAt,
        createdAt,
        updatedAt
      ];
}
