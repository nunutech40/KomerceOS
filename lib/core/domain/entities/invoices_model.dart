import 'package:equatable/equatable.dart';

class InvoicesModel extends Equatable {
  List<InvoicesDataModel>? data;

  InvoicesModel({this.data});

  @override
  List<Object?> get props => [data];
}

class InvoicesDataModel extends Equatable {
  int? invoiceId;
  String? invoiceCode;
  bool isPaid;
  int? amountTotal;
  String? expiredAt;
  String? createdAt;
  String? updatedAt;
  String? transactionType;
  String? transactionStatus;

  InvoicesDataModel(
      {this.invoiceId,
      this.invoiceCode,
      this.isPaid = false,
      this.amountTotal,
      this.expiredAt,
      this.createdAt,
      this.updatedAt,
      this.transactionType = 'Invoice',
      this.transactionStatus});

  @override
  List<Object?> get props => [
        invoiceId,
        invoiceCode,
        isPaid,
        amountTotal,
        expiredAt,
        createdAt,
        updatedAt,
        transactionType,
        transactionStatus
      ];
}
