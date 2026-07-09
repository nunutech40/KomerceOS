import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komtim_partner/common/enum_status.dart';
import 'package:komtim_partner/common/failure.dart';
import 'package:komtim_partner/core/domain/entities/detail_shopping_model.dart';
import 'package:komtim_partner/core/domain/entities/shopping_list_model.dart';
import 'package:komtim_partner/core/domain/usecases/cancel_shopping_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/get_detail_shopping_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/get_shopping_list_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/pay_shopping_use_case.dart';

part 'shopping_event.dart';
part 'shopping_state.dart';

class ShoppingBloc extends Bloc<ShoppingEvent, ShoppingState> {
  ShoppingBloc(
      {required this.getShoppingListUseCase,
      required this.getDetailShoppingUseCase,
      required this.cancelShoppingUseCase,
      required this.payShoppingUseCase})
      : super(const ShoppingState()) {
    on<GetShoppingListEvent>(_getShoppingList);
    on<RefreshDataEvent>(_refresStateAndEvent);
    on<GetDetailShoppingEvent>(_getDetailShopping);
    on<CancelShoppingEvent>(_cancelShopping);
    on<PayShoppingEvent>(_payShopping);
  }

  GetShoppingListUseCase getShoppingListUseCase;
  GetDetailShoppingUseCase getDetailShoppingUseCase;
  CancelShoppingUseCase cancelShoppingUseCase;
  PayShoppingUseCase payShoppingUseCase;

  Future<void> _refresStateAndEvent(
    RefreshDataEvent event,
    Emitter<ShoppingState> emit,
  ) async {
    emit(const ShoppingState());
  }

  Future<void> _getShoppingList(
    GetShoppingListEvent event,
    Emitter<ShoppingState> emit,
  ) async {
    emit(state.copyWith(
        status: RequestStatus.loading, operation: 'getShoppingList'));

    final shoppingResult = await getShoppingListUseCase.execute(
        event.offset,
        event.limit,
        event.status,
        event.startDate,
        event.endDate,
        event.keyword);

    shoppingResult.fold(
      (failure) {
        if (failure is ConnectionFailure || failure is ServerFailure) {
          emit(state.copyWith(
              message: failure.message, status: RequestStatus.failure));
        } else {
          emit(state.copyWith(
              message: failure.message, status: RequestStatus.failure));
        }
      },
      (shoppingList) {
        emit(state.copyWith(
            message: 'Success',
            status: RequestStatus.success,
            shoppingList: shoppingList));
      },
    );
  }

  Future<void> _getDetailShopping(
    GetDetailShoppingEvent event,
    Emitter<ShoppingState> emit,
  ) async {
    emit(state.copyWith(
        status: RequestStatus.loading, operation: 'getDetailShopping'));

    final shoppingResult = await getDetailShoppingUseCase.execute(event.id);

    shoppingResult.fold(
      (failure) {
        if (failure is ConnectionFailure || failure is ServerFailure) {
          emit(state.copyWith(
              message: failure.message, status: RequestStatus.failure));
        } else {
          emit(state.copyWith(
              message: failure.message, status: RequestStatus.failure));
        }
      },
      (detail) {
        emit(state.copyWith(
            message: 'Success',
            status: RequestStatus.success,
            detailShopping: detail));
      },
    );
  }

  Future<void> _cancelShopping(
    CancelShoppingEvent event,
    Emitter<ShoppingState> emit,
  ) async {
    emit(state.copyWith(
        status: RequestStatus.loading, operation: 'cancelShopping'));

    final shoppingResult = await cancelShoppingUseCase.execute(event.id);

    shoppingResult.fold(
      (failure) {
        if (failure is ConnectionFailure || failure is ServerFailure) {
          emit(state.copyWith(
              message: failure.message, status: RequestStatus.failure));
        } else {
          emit(state.copyWith(
              message: failure.message, status: RequestStatus.failure));
        }
      },
      (result) {
        emit(state.copyWith(
          message: 'Success',
          status: RequestStatus.success,
        ));
      },
    );
  }

  Future<void> _payShopping(
    PayShoppingEvent event,
    Emitter<ShoppingState> emit,
  ) async {
    emit(state.copyWith(
        status: RequestStatus.loading, operation: 'payShopping'));

    final shoppingResult =
        await payShoppingUseCase.execute(event.id, event.usePoin);

    shoppingResult.fold(
      (failure) {
        if (failure is ConnectionFailure || failure is ServerFailure) {
          emit(state.copyWith(
              message: failure.message, status: RequestStatus.failure));
        } else {
          emit(state.copyWith(
              message: failure.message, status: RequestStatus.failure));
        }
      },
      (result) {
        emit(state.copyWith(
          message: 'Success',
          status: RequestStatus.success,
        ));
      },
    );
  }
}
