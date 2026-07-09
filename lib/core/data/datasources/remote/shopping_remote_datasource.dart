import 'package:komtim_partner/core/data/models/detail_shopping_response.dart';
import 'package:komtim_partner/core/data/models/shopping_list_response.dart';

import '../../apiservice/constat_endpoint.dart';
import '../../apiservice/dio_client.dart';
import '../../apiservice/dio_response_parser.dart';

abstract class ShoppingRemoteDataSource {
  Future<List<ShoppingListResponseData>> getShoppingList(
      int? offset,
      int? limit,
      String? status,
      String? startDate,
      String? endDate,
      String? keyword);
  Future<DetailShoppingResponseData> getDetailShopping(int id);
  Future<bool> cancelShopping(int id);
  Future<bool> payShopping(int id, bool usePoin);
}

class ShoppingRemoteDataSourceImpl implements ShoppingRemoteDataSource {
  final DioClient client;
  final DioResponseParser responseParser;

  ShoppingRemoteDataSourceImpl(
      {required this.client, required this.responseParser});

  @override
  Future<List<ShoppingListResponseData>> getShoppingList(
      int? offset,
      int? limit,
      String? status,
      String? startDate,
      String? endDate,
      String? keyword) async {
    final Map<String, dynamic> queryParams = {
      'offset': offset,
      'limit': limit,
    };

    if (status != null && status.isNotEmpty) queryParams['status'] = status;
    if (startDate != null && startDate.isNotEmpty) {
      queryParams['start_date'] = startDate;
    }
    if (endDate != null && endDate.isNotEmpty) {
      queryParams['end_date'] = endDate;
    }
    if (keyword != null && keyword.isNotEmpty) queryParams['keyword'] = keyword;

    final response = await client.get(
      Endpoints.listShopping,
      queryParameters: queryParams,
    );

    return responseParser.parseResponse<List<ShoppingListResponseData>>(
        response,
        (json) => ((json as List?) ?? [])
            .map((item) => ShoppingListResponseData.fromJson(item))
            .toList());
  }

  @override
  Future<DetailShoppingResponseData> getDetailShopping(int id) async {
    final response = await client.get(
      Endpoints.detailShopping.replaceFirst('{id}', id.toString()),
    );

    return responseParser.parseResponse<DetailShoppingResponseData>(
      response,
      (json) => DetailShoppingResponseData.fromJson(json),
    );
  }

  @override
  Future<bool> cancelShopping(int id) async {
    final response = await client.post(
      Endpoints.cancelShopping.replaceFirst('{id}', id.toString()),
    );

    return responseParser.parseResponseMeta<bool>(response, (_) => true);
  }

  @override
  Future<bool> payShopping(int id, bool usePoin) async {
    final data = {"id": id, "is_use_kompoints": usePoin};

    final response = await client.post(
      Endpoints.payShopping,
      data: data,
    );

    return responseParser.parseResponseMeta<bool>(response, (_) => true);
  }
}
