import 'package:equatable/equatable.dart';

import '../../domain/entities/bank_accounts_model.dart';

class BankAccountsResponse extends Equatable {
  final List<BankAccountsResponeData>? data;

  const BankAccountsResponse({required this.data});

  Map<String, dynamic> toJson() => {
        "data": data?.map((item) => item.toJson()).toList(),
      };

  factory BankAccountsResponse.fromJson(Map<String, dynamic> json) {
    return BankAccountsResponse(
      data: (json['data'] as List<dynamic>)
          .map((item) => BankAccountsResponeData.fromJson(item))
          .toList(),
    );
  }

  BankAccountsModel toEntity() {
    return BankAccountsModel(
      data: data
          ?.map((item) => item.toEntity())
          .toList(), // Map each item to entity
    );
  }

  @override
  List<Object?> get props => [data];
}

class BankAccountsResponeData extends Equatable {
  final int? bankAccountsId;
  final String? bankCode;
  final String? bankName;
  final String? bankOwnerName;
  final String? bankOwnerNumber;
  final String? createdAt;
  final String? updatedAt;

  const BankAccountsResponeData(
      {required this.bankAccountsId,
      required this.bankCode,
      required this.bankName,
      required this.bankOwnerName,
      required this.bankOwnerNumber,
      required this.createdAt,
      required this.updatedAt});

  Map<String, dynamic> toJson() => {
        "bank_account_id": bankAccountsId,
        "bank_code": bankCode,
        "bank_name": bankName,
        "bank_owner_name": bankOwnerName,
        "bank_owner_number": bankOwnerNumber,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };

  factory BankAccountsResponeData.fromJson(Map<String, dynamic> json) {
    return BankAccountsResponeData(
      bankAccountsId: json['bank_account_id'],
      bankCode: json['bank_code'],
      bankName: json['bank_name'],
      bankOwnerName: json['bank_owner_name'],
      bankOwnerNumber: json['bank_owner_number'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  BankAccountsDataModel toEntity() {
    return BankAccountsDataModel(
      bankAccountsId: bankAccountsId,
      bankCode: bankCode,
      bankName: bankName,
      bankOwnerName: bankOwnerName,
      bankOwnerNumber: bankOwnerNumber,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        bankAccountsId,
        bankCode,
        bankName,
        bankOwnerName,
        bankOwnerNumber,
        createdAt,
        updatedAt,
      ];
}
