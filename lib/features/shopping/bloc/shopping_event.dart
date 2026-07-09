part of 'shopping_bloc.dart';

abstract class ShoppingEvent extends Equatable {
  const ShoppingEvent();

  @override
  List<Object?> get props => [];
}

class GetShoppingListEvent extends ShoppingEvent {
  final int? offset;
  final int? limit;
  final String? keyword;
  final String? status;
  final String? startDate;
  final String? endDate;

  const GetShoppingListEvent({
    this.offset,
    this.limit,
    this.keyword,
    this.status,
    this.startDate,
    this.endDate,
  });
  @override
  List<Object?> get props => [offset, limit, status, startDate, endDate];
}

class RefreshDataEvent extends ShoppingEvent {
  const RefreshDataEvent();
}

class GetDetailShoppingEvent extends ShoppingEvent {
  final int id;
  const GetDetailShoppingEvent(this.id);
  @override
  List<Object?> get props => [id];
}

class CancelShoppingEvent extends ShoppingEvent {
  final int id;
  const CancelShoppingEvent(this.id);
  @override
  List<Object?> get props => [id];
}

class PayShoppingEvent extends ShoppingEvent {
  final int id;
  final bool usePoin;
  const PayShoppingEvent(this.id, this.usePoin);
  @override
  List<Object?> get props => [id, usePoin];
}
