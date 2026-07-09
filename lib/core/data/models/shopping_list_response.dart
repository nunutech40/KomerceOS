import 'package:equatable/equatable.dart';
import 'package:komtim_partner/core/domain/entities/shopping_list_model.dart';

class ShoppingListResponse extends Equatable {
  final List<ShoppingListResponseData>? data;

  const ShoppingListResponse({required this.data});

  Map<String, dynamic> toJson() => {
        "data": data?.map((item) => item.toJson()).toList(),
      };

  factory ShoppingListResponse.fromJson(Map<String, dynamic> json) {
    return ShoppingListResponse(
      data: (json['data'] as List<dynamic>)
          .map((item) => ShoppingListResponseData.fromJson(item))
          .toList(),
    );
  }

  ShoppingListModel toEntity() {
    return ShoppingListModel(
      data: data
          ?.map((item) => item.toEntity())
          .toList(),
    );
  }

  @override
  List<Object?> get props => [data];
}

class ShoppingListResponseData extends Equatable {
  final int id;
  final int userRequestId;
  final String userRequestName;
  final String status;
  final int total;
  final String createdAt;
  final String updatedAt;

  const ShoppingListResponseData(
      {required this.id,
      required this.userRequestId,
      required this.userRequestName,
      required this.status,
      required this.total,
      required this.createdAt,
      required this.updatedAt});

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_requester_id": userRequestId,
        "user_requester_name": userRequestName,
        "status": status,
        "total": total,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };

  factory ShoppingListResponseData.fromJson(Map<String, dynamic> json) {
    return ShoppingListResponseData(
      id: json['id'],
      userRequestId: json['user_requester_id'],
      userRequestName: json['user_requester_name'],
      status: json['status'],
      total: json['total'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  ShoppingListDataModel toEntity() {
    return ShoppingListDataModel(
      id: id,
      userRequestId: userRequestId,
      userRequestName: userRequestName,
      status: status,
      total: total,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userRequestId,
        userRequestName,
        status,
        total,
        createdAt,
        updatedAt
      ];
}
