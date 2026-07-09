import 'package:komtim_partner/core/data/models/feed_detail_response.dart';
import 'package:komtim_partner/core/data/models/feed_model_response.dart';

import '../../apiservice/constat_endpoint.dart';
import '../../apiservice/dio_client.dart';
import '../../apiservice/dio_response_parser.dart';

abstract class FeedRemoteDataSource {
  Future<List<ModelFeedResponse>> getFeed(String search, int limit, int offset);
  Future<ModelFeedDetailResponse> getFeedDetail(int id);
}

class FeedRemoteDataSourceImpl implements FeedRemoteDataSource {
  final DioClient client;
  final DioResponseParser responseParser;

  FeedRemoteDataSourceImpl(
      {required this.client, required this.responseParser});

  @override
  Future<List<ModelFeedResponse>> getFeed(
      String search, int limit, int offset) async {
    final queryParams = {
      'search': search,
      'limit': limit,
      'offset': offset,
    };

    final response = await client.get(
      Endpoints.listFeed,
      queryParameters: queryParams,
    );

    return responseParser.parseResponse<List<ModelFeedResponse>>(
        response,
        (json) => ((json as List?) ?? [])
            .map((item) => ModelFeedResponse.fromJson(item))
            .toList());
  }

  @override
  Future<ModelFeedDetailResponse> getFeedDetail(int id) async {
    final response = await client.get(
      '${Endpoints.listFeedDetail}/$id',
    );

    return responseParser.parseResponse<ModelFeedDetailResponse>(
        response, (json) => ModelFeedDetailResponse.fromJson(json));
  }
}
