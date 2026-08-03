part of 'feed_bloc.dart';

class FeedState extends Equatable {
  const FeedState({
    this.message = '',
    this.status = RequestStatus.empty,
    this.operation = '',
    this.feedList = const [],
    this.feedDetail,
  });

  final String message;
  final RequestStatus status;
  final String operation;
  final List<ModelFeed> feedList;
  final ModelDetailFeed? feedDetail;

  FeedState copyWith({
    RequestStatus? status,
    String? message,
    String? operation,
    List<ModelFeed>? feedList,
    ModelDetailFeed? feedDetail,
  }) {
    return FeedState(
      status: status ?? this.status,
      message: message ?? this.message,
      operation: operation ?? this.operation,
      feedList: feedList ?? this.feedList,
      feedDetail: feedDetail ?? this.feedDetail,
    );
  }

  @override
  List<Object?> get props => [
        message,
        status,
        operation,
      ];
}
