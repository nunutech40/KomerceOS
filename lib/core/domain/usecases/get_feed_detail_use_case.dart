import 'package:dartz/dartz.dart';
import 'package:komtim_partner/core/domain/entities/feed_detail_mode.dart';
import 'package:komtim_partner/core/domain/repositories/feed_reporsitory.dart';

import '../../../common/failure.dart';

class GetFeedDetailUseCase {
  final FeedReporsitory _repository;

  const GetFeedDetailUseCase(this._repository);

  Future<Either<Failure, ModelDetailFeed>> execute(
    int id,
  ) {
    return _repository.getFeedDetail(id);
  }
}
