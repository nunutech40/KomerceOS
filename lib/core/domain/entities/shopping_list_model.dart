import 'package:equatable/equatable.dart';

class ShoppingListModel extends Equatable {
  List<ShoppingListDataModel>? data;

  ShoppingListModel({this.data});

  @override
  List<Object?> get props => [data];
}

class ShoppingListDataModel extends Equatable {
  int? id;
  int? userRequestId;
  String? userRequestName;
  String? status;
  int? total;
  String? createdAt;
  String? updatedAt;

  ShoppingListDataModel({
    this.id,
    this.userRequestId,
    this.userRequestName,
    this.status,
    this.total,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        userRequestId,
        userRequestName,
        status,
        total,
        createdAt,
        updatedAt,
      ];
}
