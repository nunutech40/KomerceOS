import 'package:dartz/dartz.dart';
import 'package:komtim_partner/core/domain/entities/feed_detail_mode.dart';
import 'package:komtim_partner/core/domain/entities/feed_model.dart';

import '../../../common/failure.dart';

abstract class FeedReporsitory {
  Future<Either<Failure, List<ModelFeed>>> getFeed(
      String search, int limit, int offset);
  Future<Either<Failure, ModelDetailFeed>> getFeedDetail(int id);
}
