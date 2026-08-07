part of 'talent_pool_bloc.dart';

@immutable
abstract class TalentPoolState extends Equatable {
  const TalentPoolState();

  @override
  List<Object?> get props => [];
}

class TalentPoolInitial extends TalentPoolState {}

class TalentPoolLoading extends TalentPoolState {}

class TalentPoolLoaded extends TalentPoolState {
  final List<TalentRecommendationModel> talents;
  final bool hasMore;
  final int currentOffset;

  const TalentPoolLoaded({
    required this.talents,
    required this.hasMore,
    required this.currentOffset,
  });

  @override
  List<Object?> get props => [talents, hasMore, currentOffset];
}

/// State saat load-more berjalan — tampilkan list lama + shimmer di bawah.
class TalentPoolLoadingMore extends TalentPoolState {
  final List<TalentRecommendationModel> talents;

  const TalentPoolLoadingMore({required this.talents});

  @override
  List<Object?> get props => [talents];
}

class TalentPoolError extends TalentPoolState {
  final String message;

  const TalentPoolError(this.message);

  @override
  List<Object?> get props => [message];
}

class TalentPoolEmpty extends TalentPoolState {}

class TalentPoolWishlistSuccess extends TalentPoolLoaded {
  const TalentPoolWishlistSuccess({
    required super.talents,
    required super.hasMore,
    required super.currentOffset,
  });
}

class TalentPoolWishlistFailed extends TalentPoolLoaded {
  final String message;

  const TalentPoolWishlistFailed({
    required this.message,
    required super.talents,
    required super.hasMore,
    required super.currentOffset,
  });

  @override
  List<Object?> get props => [message, talents, hasMore, currentOffset];
}
