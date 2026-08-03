part of 'shopping_bloc.dart';

class ShoppingState extends Equatable {
  const ShoppingState(
      {this.message = '',
      this.status = RequestStatus.empty,
      this.operation = '',
      this.shoppingList = const [],
      this.detailShopping});

  final String message;
  final RequestStatus status;
  final String operation;
  final List<ShoppingListDataModel> shoppingList;
  final DetailShoppingDataModel? detailShopping;

  ShoppingState copyWith({
    RequestStatus? status,
    String? message,
    String? operation,
    List<ShoppingListDataModel>? shoppingList,
    DetailShoppingDataModel? detailShopping,
  }) {
    return ShoppingState(
        status: status ?? this.status,
        message: message ?? this.message,
        operation: operation ?? this.operation,
        shoppingList: shoppingList ?? this.shoppingList,
        detailShopping: detailShopping ?? this.detailShopping);
  }

  @override
  List<Object?> get props => [
        message,
        status,
        operation,
        shoppingList,
        detailShopping,
      ];
}
