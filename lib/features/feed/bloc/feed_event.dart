part of 'feed_bloc.dart';

@immutable
abstract class FeedEvent extends Equatable {
  const FeedEvent();

  @override
  List<Object?> get props => [];
}

class RefreshDataEvent extends FeedEvent {
  const RefreshDataEvent();
}

class GetFeedEvent extends FeedEvent {
  final String search;
  final int offset;
  final int limit;

  const GetFeedEvent({
    required this.search,
    required this.offset,
    required this.limit,
  });
  @override
  List<Object?> get props => [search, offset, limit];
}

class GetFeedDetailEvent extends FeedEvent {
  final int id;

  const GetFeedDetailEvent({
    required this.id,
  });
  @override
  List<Object?> get props => [id];
}
