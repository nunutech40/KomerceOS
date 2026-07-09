import 'package:dartz/dartz.dart';
import 'package:komtim_partner/core/domain/entities/detail_shopping_model.dart';
import 'package:komtim_partner/core/domain/entities/shopping_list_model.dart';
import '../../../common/failure.dart';

abstract class ShoppingRepository {
  Future<Either<Failure, List<ShoppingListDataModel>>> getListShopping(int? offset, int? limit, String? status, String? startDate, String? endDate, String? keyword);
  Future<Either<Failure, DetailShoppingDataModel>> getDetailShopping(int id);
  Future<Either<Failure, bool>> cancelShopping(int id);
  Future<Either<Failure, bool>> payShopping(int id, bool usePoin);
}
