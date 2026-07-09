import 'package:dartz/dartz.dart';
import 'package:komtim_partner/common/failure.dart';
import 'package:komtim_partner/core/domain/repositories/shopping_repository.dart';

class CancelShoppingUseCase {
  final ShoppingRepository _repository;

  const CancelShoppingUseCase(this._repository);
  Future<Either<Failure, bool>> execute(int id) {
    return _repository.cancelShopping(id);
  }
}
