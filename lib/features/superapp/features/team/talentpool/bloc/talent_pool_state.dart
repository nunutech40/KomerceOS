part of 'talent_pool_bloc.dart';

@immutable
abstract class TalentPoolState extends Equatable {
  const TalentPoolState();

  @override
  List<Object?> get props => [];
}

class TalentPoolInitial extends TalentPoolState {}

class TalentPoolLoading extends TalentPoolState {
  /// Filter aktif saat loading agar UI role chip tetap bisa dirender.
  final TalentFilter activeFilter;

  const TalentPoolLoading({this.activeFilter = TalentFilter.empty});

  @override
  List<Object?> get props => [activeFilter];
}

class TalentPoolLoaded extends TalentPoolState {
  final List<TalentRecommendationModel> talents;
  final bool hasMore;
  final int currentOffset;

  /// Filter yang sedang aktif — digunakan UI untuk sync chip & badge filter.
  final TalentFilter activeFilter;

  const TalentPoolLoaded({
    required this.talents,
    required this.hasMore,
    required this.currentOffset,
    this.activeFilter = TalentFilter.empty,
  });

  @override
  List<Object?> get props => [talents, hasMore, currentOffset, activeFilter];
}

/// State saat load-more berjalan — tampilkan list lama + shimmer di bawah.
class TalentPoolLoadingMore extends TalentPoolState {
  final List<TalentRecommendationModel> talents;
  final TalentFilter activeFilter;

  const TalentPoolLoadingMore({
    required this.talents,
    this.activeFilter = TalentFilter.empty,
  });

  @override
  List<Object?> get props => [talents, activeFilter];
}

class TalentPoolError extends TalentPoolState {
  final String message;

  const TalentPoolError(this.message);

  @override
  List<Object?> get props => [message];
}

class TalentPoolEmpty extends TalentPoolState {
  final TalentFilter activeFilter;

  const TalentPoolEmpty({this.activeFilter = TalentFilter.empty});

  @override
  List<Object?> get props => [activeFilter];
}

class TalentPoolWishlistSuccess extends TalentPoolLoaded {
  const TalentPoolWishlistSuccess({
    required super.talents,
    required super.hasMore,
    required super.currentOffset,
    super.activeFilter,
  });
}

class TalentPoolWishlistFailed extends TalentPoolLoaded {
  final String message;

  const TalentPoolWishlistFailed({
    required this.message,
    required super.talents,
    required super.hasMore,
    required super.currentOffset,
    super.activeFilter,
  });

  @override
  List<Object?> get props => [message, talents, hasMore, currentOffset, activeFilter];
}
