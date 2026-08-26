part of 'talent_pool_bloc.dart';

@immutable
abstract class TalentPoolEvent extends Equatable {
  const TalentPoolEvent();

  @override
  List<Object?> get props => [];
}

/// Fetch pertama kali atau refresh (reset offset ke 0).
/// Jika [filter] null, gunakan [TalentFilter.empty].
class FetchTalentPoolEvent extends TalentPoolEvent {
  final TalentFilter filter;

  const FetchTalentPoolEvent({this.filter = TalentFilter.empty});

  @override
  List<Object?> get props => [filter];
}

/// Pilih role dari quick-filter chip (single-select).
/// Memilih role yang sama (bukan '') → kembali ke ''.
class SelectRoleTalentPoolEvent extends TalentPoolEvent {
  final String role;

  const SelectRoleTalentPoolEvent(this.role);

  @override
  List<Object?> get props => [role];
}

/// Update query pencarian dari search bar.
class SearchTalentPoolEvent extends TalentPoolEvent {
  final String query;

  const SearchTalentPoolEvent(this.query);

  @override
  List<Object?> get props => [query];
}

/// Apply filter dari bottom sheet.
class ApplyFilterTalentPoolEvent extends TalentPoolEvent {
  final Set<int> selectedRatings;
  final Set<String> selectedExperiences;
  final Set<int> selectedBusinessSectorIds;

  const ApplyFilterTalentPoolEvent({
    required this.selectedRatings,
    required this.selectedExperiences,
    required this.selectedBusinessSectorIds,
  });

  @override
  List<Object?> get props =>
      [selectedRatings, selectedExperiences, selectedBusinessSectorIds];
}

/// Reset semua filter (pull-to-refresh / hapus semua).
class ResetFilterTalentPoolEvent extends TalentPoolEvent {
  const ResetFilterTalentPoolEvent();
}

/// Load halaman berikutnya (pagination).
class LoadMoreTalentPoolEvent extends TalentPoolEvent {
  const LoadMoreTalentPoolEvent();
}

/// Toggle wishlist status on a talent
class ToggleWishlistTalentPoolEvent extends TalentPoolEvent {
  final int talentId;

  const ToggleWishlistTalentPoolEvent(this.talentId);

  @override
  List<Object?> get props => [talentId];
}
