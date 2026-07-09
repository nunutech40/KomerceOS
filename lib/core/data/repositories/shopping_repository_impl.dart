import 'package:komtim_partner/core/data/datasources/remote/shopping_remote_datasource.dart';
import 'package:komtim_partner/core/domain/entities/detail_shopping_model.dart';
import 'package:komtim_partner/core/domain/entities/shopping_list_model.dart';
import 'package:komtim_partner/core/domain/repositories/shopping_repository.dart';

import '../../../common/failure.dart';
import '../datasources/preferences/shared_pref.dart';
import 'base_repository.dart';

import 'package:dartz/dartz.dart';

class ShoppingRepositoryImpl extends BaseRepository implements ShoppingRepository {
  final ShoppingRemoteDataSource remoteDataSource;
  final SharedPref sharedPref;

  ShoppingRepositoryImpl(
      {required this.remoteDataSource, required this.sharedPref});

  @override
  Future<Either<Failure, List<ShoppingListDataModel>>> getListShopping(int? offset, int? limit, String? status, String? startDate, String? endDate, String? keyword) async {
       return executeEither(() async {
      final result = await remoteDataSource.getShoppingList(offset, limit, status, startDate, endDate, keyword);
      final shoppingResult = result.map((item) => item.toEntity()).toList();
      return shoppingResult;
    });
  }

  @override
  Future<Either<Failure, DetailShoppingDataModel>> getDetailShopping(int id) async {
     return executeEither(() async {
      final result = await remoteDataSource.getDetailShopping(id);
      final invoiceDetailModel = result.toEntity();
      return invoiceDetailModel;
    });
  }
  
  @override
  Future<Either<Failure, bool>> cancelShopping(int id) async {
   return executeEither(() async {
      final result = await remoteDataSource.cancelShopping(id);
      return result;
    });
  }
  
  @override
  Future<Either<Failure, bool>> payShopping(int id, bool usePoin) {
    return executeEither(() async {
      final result = await remoteDataSource.payShopping(id, usePoin);
      return result;
    });
  }

}
