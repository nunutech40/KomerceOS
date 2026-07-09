import 'package:equatable/equatable.dart';
import 'package:komtim_partner/core/domain/entities/transaction_history_model.dart';

class TransactionHistoryResponse extends Equatable {
  final List<TransactionHistoryResponseData>? data;

  const TransactionHistoryResponse({required this.data});

  Map<String, dynamic> toJson() => {
        "data": data?.map((item) => item.toJson()).toList(),
      };

  factory TransactionHistoryResponse.fromJson(Map<String, dynamic> json) {
    return TransactionHistoryResponse(
      data: (json['data'] as List<dynamic>)
          .map((item) => TransactionHistoryResponseData.fromJson(item))
          .toList(),
    );
  }

  TransactionHistoryModel toEntity() {
    return TransactionHistoryModel(
      data: data
          ?.map((item) => item.toEntity())
          .toList(), // Map each item to entity
    );
  }

  @override
  List<Object?> get props => [data];
}

class TransactionHistoryResponseData extends Equatable {
  final int transactionId;
  final String transactionType;
  final String transactionCode;
  final String transactionDate;
  final int transactionNominal;
  final String transactionStatus;
  final String createdAt;
  final String updatedAt;

  const TransactionHistoryResponseData(
      {required this.transactionId,
      required this.transactionType,
      required this.transactionCode,
      required this.transactionDate,
      required this.transactionNominal,
      required this.transactionStatus,
      required this.createdAt,
      required this.updatedAt});

  Map<String, dynamic> toJson() => {
        "transaction_id": transactionId,
        "transaction_type": transactionType,
        "transaction_code": transactionCode,
        "transaction_date": transactionDate,
        "transaction_nominal": transactionNominal,
        "transaction_status": transactionStatus,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };

  factory TransactionHistoryResponseData.fromJson(Map<String, dynamic> json) {
    return TransactionHistoryResponseData(
      transactionId: json['transaction_id'],
      transactionType: json['transaction_type'],
      transactionCode: json['transaction_code'],
      transactionDate: json['transaction_date'],
      transactionNominal: json['transaction_nominal'],
      transactionStatus: json['transaction_status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  TransactionHistoryDataModel toEntity() {
    return TransactionHistoryDataModel(
      transactionId: transactionId,
      transactionType: transactionType,
      transactionCode: transactionCode,
      transactionDate: transactionDate,
      transactionNominal: transactionNominal,
      transactionStatus: transactionStatus,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        transactionId,
        transactionType,
        transactionCode,
        transactionDate,
        transactionNominal,
        transactionStatus,
        createdAt,
        updatedAt
      ];
}
