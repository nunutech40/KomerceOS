import 'package:equatable/equatable.dart';

class BankAccountsModel extends Equatable {
  List<BankAccountsDataModel>? data;

  BankAccountsModel({this.data});

  @override
  List<Object?> get props => [data];
}

class BankAccountsDataModel extends Equatable {
  int? bankAccountsId;
  String? bankCode;
  String? bankName;
  String? bankOwnerName;
  String? bankOwnerNumber;
  String? createdAt;
  String? updatedAt;

  BankAccountsDataModel({
    this.bankAccountsId,
    this.bankCode,
    this.bankName,
    this.bankOwnerName,
    this.bankOwnerNumber,
    this.createdAt,
    this.updatedAt,
  });

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
