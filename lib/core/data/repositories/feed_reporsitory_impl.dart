import 'package:dartz/dartz.dart';
import 'package:komtim_partner/common/failure.dart';
import 'package:komtim_partner/core/data/datasources/remote/feed_remote_datasource.dart';
import 'package:komtim_partner/core/data/repositories/base_repository.dart';
import 'package:komtim_partner/core/domain/entities/feed_detail_mode.dart';
import 'package:komtim_partner/core/domain/entities/feed_model.dart';
import 'package:komtim_partner/core/domain/repositories/feed_reporsitory.dart';

class FeedReporsitoryImpl extends BaseRepository implements FeedReporsitory {
  final FeedRemoteDataSource remoteDataSource;

  FeedReporsitoryImpl({required this.remoteDataSource});
  @override
  Future<Either<Failure, List<ModelFeed>>> getFeed(
      String search, int limit, int offset) {
    return executeEither(() async {
      final result = await remoteDataSource.getFeed(search, limit, offset);
      final feedData = result.map((item) => item.toEntity()).toList();
      return feedData;
    });
  }

  @override
  Future<Either<Failure, ModelDetailFeed>> getFeedDetail(int id) {
    return executeEither(() async {
      final result = await remoteDataSource.getFeedDetail(id);
      final feedData = result.toEntity();
      return feedData;
    });
  }
}
