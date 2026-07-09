import 'package:dartz/dartz.dart';
import 'package:komtim_partner/common/failure.dart';
import 'package:komtim_partner/core/domain/repositories/shopping_repository.dart';

class PayShoppingUseCase {
  final ShoppingRepository _repository;

  const PayShoppingUseCase(this._repository);
  Future<Either<Failure, bool>> execute(int id, bool usePoin) {
    return _repository.payShopping(id, usePoin);
  }
}
