import 'package:dartz/dartz.dart';
import 'package:komtim_partner/core/domain/entities/feed_model.dart';
import 'package:komtim_partner/core/domain/repositories/feed_reporsitory.dart';

import '../../../common/failure.dart';

class GetFeedUseCase {
  final FeedReporsitory _repository;

  const GetFeedUseCase(this._repository);

  Future<Either<Failure, List<ModelFeed>>> execute(
    String search,
    int limit,
    int offset,
  ) {
    return _repository.getFeed(search, limit, offset);
  }
}
