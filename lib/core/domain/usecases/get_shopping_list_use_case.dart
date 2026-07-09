import 'package:dartz/dartz.dart';
import 'package:komtim_partner/core/domain/entities/shopping_list_model.dart';
import 'package:komtim_partner/core/domain/repositories/shopping_repository.dart';

import '../../../common/failure.dart';

class GetShoppingListUseCase {
  final ShoppingRepository _repository;

  const GetShoppingListUseCase(this._repository);

  Future<Either<Failure, List<ShoppingListDataModel>>> execute(int? offset, int? limit, String? status, String? startDate, String? endDate, String? keyword) {
    return _repository.getListShopping(offset, limit, status, startDate, endDate, keyword);

  }
}