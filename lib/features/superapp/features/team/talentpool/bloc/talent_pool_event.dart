part of 'talent_pool_bloc.dart';

@immutable
abstract class TalentPoolEvent extends Equatable {
  const TalentPoolEvent();

  @override
  List<Object?> get props => [];
}

/// Fetch pertama kali atau refresh (reset offset ke 0).
class FetchTalentPoolEvent extends TalentPoolEvent {
  final List<int> ratings;
  final List<String> experiences;
  final List<int> businessSectorIds;
  final String skillName;

  const FetchTalentPoolEvent({
    this.ratings = const [],
    this.experiences = const [],
    this.businessSectorIds = const [],
    this.skillName = '',
  });

  @override
  List<Object?> get props =>
      [ratings, experiences, businessSectorIds, skillName];
}

/// Load halaman berikutnya (pagination).
class LoadMoreTalentPoolEvent extends TalentPoolEvent {
  const LoadMoreTalentPoolEvent();
}
