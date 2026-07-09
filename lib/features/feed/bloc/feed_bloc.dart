import 'package:equatable/equatable.dart';
import 'package:komtim_partner/core/domain/entities/feed_detail_mode.dart';
import 'package:komtim_partner/core/domain/entities/feed_model.dart';
import 'package:komtim_partner/core/domain/usecases/get_feed_detail_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/get_feed_use_case.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import '../../../common/enum_status.dart';
import '../../../common/failure.dart';

part 'feed_state.dart';
part 'feed_event.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  FeedBloc({
    required this.getFeedUseCase,
    required this.getFeedDetailUseCase,
  }) : super(const FeedState()) {
    on<GetFeedEvent>(_handleFeed);
    on<GetFeedDetailEvent>(_handleFeedDetail);
  }
  final GetFeedUseCase getFeedUseCase;
  final GetFeedDetailUseCase getFeedDetailUseCase;

  Future<void> _handleFeed(
    GetFeedEvent event,
    Emitter<FeedState> emit,
  ) async {
    emit(state.copyWith(status: RequestStatus.loading, operation: 'feedList'));

    final feedResult = await getFeedUseCase.execute(
      event.search,
      event.limit,
      event.offset,
    );

    feedResult.fold(
      (failure) {
        if (failure is ConnectionFailure || failure is ServerFailure) {
          emit(state.copyWith(
              message: failure.message, status: RequestStatus.failure));
        } else {
          emit(state.copyWith(
              message: failure.message, status: RequestStatus.failure));
        }
      },
      (feedList) {
        emit(state.copyWith(
            message: 'Success',
            status: RequestStatus.success,
            feedList: feedList));
      },
    );
  }

  Future<void> _handleFeedDetail(
    GetFeedDetailEvent event,
    Emitter<FeedState> emit,
  ) async {
    emit(
        state.copyWith(status: RequestStatus.loading, operation: 'feedDetail'));

    final feedDetailResult = await getFeedDetailUseCase.execute(
      event.id,
    );

    feedDetailResult.fold(
      (failure) {
        if (failure is ConnectionFailure || failure is ServerFailure) {
          emit(state.copyWith(
              message: failure.message, status: RequestStatus.failure));
        } else {
          emit(state.copyWith(
              message: failure.message, status: RequestStatus.failure));
        }
      },
      (feedDetail) {
        emit(state.copyWith(
            message: 'Success',
            status: RequestStatus.success,
            feedDetail: feedDetail));
      },
    );
  }
}
