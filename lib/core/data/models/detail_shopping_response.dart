import 'package:equatable/equatable.dart';
import 'package:komtim_partner/core/domain/entities/detail_shopping_model.dart';

class DetailShoppingResponse extends Equatable {
  final DetailShoppingResponseData? data;

  const DetailShoppingResponse({ this.data});

  factory DetailShoppingResponse.fromJson(Map<String, dynamic> json) {
    return DetailShoppingResponse(
      data: DetailShoppingResponseData.fromJson(json['data']),
    );
  }

  @override
  List<Object?> get props => [data];
}

class DetailShoppingResponseData extends Equatable {
  final int? id;
  final String? transactionNo;
  final int? userRequesterId;
  final String? userRequesterName;
  final String? userRequesterPosition;
  final String? status;
  final int? total;
  final String? notes;
  final List<TalentRequest>? talents;
  final List<ShoppingItem>? shoppingItems;
  final int? kmpoin;
  final int? kompoints;
  final List<Payment>? payments;
  final String? createdAt;
  final String? updatedAt;

  const DetailShoppingResponseData({
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

  factory DetailShoppingResponseData.fromJson(Map<String, dynamic> json) {
    return DetailShoppingResponseData(
      id: json['id'],
      transactionNo: json['transaction_no'],
      userRequesterId: json['user_requester_id'],
      userRequesterName: json['user_requester_name'],
      userRequesterPosition: json['user_requester_position'],
      status: json['status'],
      total: json['total'],
      notes: json['notes'],
      talents: (json['talents'] as List<dynamic>?)
          ?.map((item) => TalentRequest.fromJson(item))
          .toList(),
      shoppingItems: (json['shopping_items'] as List<dynamic>?)
          ?.map((item) => ShoppingItem.fromJson(item))
          .toList(),
      kmpoin: json['kmpoin'],
      kompoints: json['kompoints'],
      payments: (json['payments'] as List<dynamic>?)
          ?.map((item) => Payment.fromJson(item))
          .toList(),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  DetailShoppingDataModel toEntity() {
    return DetailShoppingDataModel(
        id: id,
        transactionNo: transactionNo,
        userRequesterId: userRequesterId,
        userRequesterName: userRequesterName,
        userRequesterPosition: userRequesterPosition,
        status: status,
        total: total,
        notes: notes,
        talents: talents,
        shoppingItems: shoppingItems,
        kmpoin: kmpoin,
        kompoints: kompoints,
        payments: payments,
        createdAt: createdAt,
        updatedAt: updatedAt);
  }

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

class TalentRequest extends Equatable {
  final int? talentId;
  final String? talentName;
  final String? talentSkill;

  const TalentRequest({
     this.talentId,
     this.talentName,
     this.talentSkill,
  });

  factory TalentRequest.fromJson(Map<String, dynamic> json) {
    return TalentRequest(
      talentId: json['talent_id'],
      talentName: json['talent_name'],
      talentSkill: json['talent_skill'],
    );
  }

  @override
  List<Object?> get props => [talentId, talentName, talentSkill];
}

class ShoppingItem extends Equatable {
  final int? itemId;
  final String? itemName;
  final int? itemTotal;

  const ShoppingItem({
     this.itemId,
     this.itemName,
     this.itemTotal,
  });

  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      itemId: json['item_id'],
      itemName: json['item_name'],
      itemTotal: json['item_total'],
    );
  }

  @override
  List<Object?> get props => [itemId, itemName, itemTotal];
}

class Payment extends Equatable {
  final String? paymentName;
  final int? nominal;

  const Payment({
     this.paymentName,
     this.nominal,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      paymentName: json['payment_name'],
      nominal: json['nominal'],
    );
  }

  @override
  List<Object?> get props => [paymentName, nominal];
}
