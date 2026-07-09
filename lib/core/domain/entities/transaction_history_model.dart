import 'package:equatable/equatable.dart';

class TransactionHistoryModel extends Equatable {
  List<TransactionHistoryDataModel>? data;

  TransactionHistoryModel({this.data});

  @override
  List<Object?> get props => [data];
}

class TransactionHistoryDataModel extends Equatable {
  int? transactionId;
  String? transactionType;
  String? transactionCode;
  String? transactionDate;
  int? transactionNominal;
  String? transactionStatus;
  String? createdAt;
  String? updatedAt;

  TransactionHistoryDataModel({
    this.transactionId,
    this.transactionType,
    this.transactionCode,
    this.transactionDate,
    this.transactionNominal,
    this.transactionStatus,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        transactionId,
        transactionType,
        transactionCode,
        transactionDate,
        transactionNominal,
        transactionStatus,
        createdAt,
        updatedAt,
      ];
}
