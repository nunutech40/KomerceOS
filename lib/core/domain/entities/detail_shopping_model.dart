import 'package:equatable/equatable.dart';
import 'package:komtim_partner/core/data/models/detail_shopping_response.dart';

class DetailShoppingModel extends Equatable {
  DetailShoppingDataModel? data;

  DetailShoppingModel({this.data});

  @override
  List<Object?> get props => [data];
}

class DetailShoppingDataModel extends Equatable {
  int? id;
  String? transactionNo;
  int? userRequesterId;
  String? userRequesterName;
  String? userRequesterPosition;
  String? status;
  int? total;
  String? notes;
  List<TalentRequest>? talents;
  List<ShoppingItem>? shoppingItems;
  int? kmpoin;
  int? kompoints;
  List<Payment>? payments;
  String? createdAt;
  String? updatedAt;

  DetailShoppingDataModel({
    this.id,
    this.transactionNo,
    this.userRequesterId,
    this.userRequesterName,
    this.userRequesterPosition,
    this.status,
    this.total,
    this.notes,
    this.talents,
    this.shoppingItems,
    this.kmpoin,
    this.kompoints,
    this.payments,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        transactionNo,
        userRequesterId,
        userRequesterName,
        userRequesterPosition,
        status,
        total,
        notes,
        talents,
        shoppingItems,
        kmpoin,
        kompoints,
        payments,
        createdAt,
        updatedAt,
      ];
}
