import 'package:dartz/dartz.dart';
import 'package:komtim_partner/core/domain/entities/detail_shopping_model.dart';
import 'package:komtim_partner/core/domain/repositories/shopping_repository.dart';

import '../../../common/failure.dart';

class GetDetailShoppingUseCase {
  final ShoppingRepository _repository;

  const GetDetailShoppingUseCase(this._repository);

  Future<Either<Failure, DetailShoppingDataModel>> execute(int id) {
    return _repository.getDetailShopping(id);
  }
}
