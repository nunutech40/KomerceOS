import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komtim_partner/core/domain/entities/talent_recomendation_model.dart';
import 'package:komtim_partner/core/domain/usecases/get_resource_talent_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/put_wishlist_talent_use_case.dart';
import 'package:komtim_partner/features/superapp/features/team/talentpool/widget/talent_filter.dart';

part 'talent_pool_event.dart';
part 'talent_pool_state.dart';

const int _kPageLimit = 18;

/// BLoC untuk halaman Talent Pool.
///
/// Filter sepenuhnya dikelola di sini (tidak ada filter state di View):
/// - [FetchTalentPoolEvent]          → fetch ulang dari offset 0 dengan filter baru
/// - [SelectRoleTalentPoolEvent]     → pilih/toggle role chip → fetch ulang
/// - [SearchTalentPoolEvent]         → update search query → fetch ulang
/// - [ApplyFilterTalentPoolEvent]    → apply hasil bottom sheet → fetch ulang
/// - [ResetFilterTalentPoolEvent]    → hapus semua filter → fetch ulang
/// - [LoadMoreTalentPoolEvent]       → tambah data berikutnya (pagination)
/// - [ToggleWishlistTalentPoolEvent] → ubah status wishlist pada talent
class TalentPoolBloc extends Bloc<TalentPoolEvent, TalentPoolState> {
  final GetResourceTalentUseCase getResourceTalentUseCase;
  final PutWishlistTalentUseCase putWishlistTalentUseCase;

  /// Filter aktif yang dipakai saat ini.
  TalentFilter _activeFilter = TalentFilter.empty;

  TalentPoolBloc({
    required this.getResourceTalentUseCase,
    required this.putWishlistTalentUseCase,
  }) : super(TalentPoolInitial()) {
    on<FetchTalentPoolEvent>(_onFetch);
    on<SelectRoleTalentPoolEvent>(_onSelectRole);
    on<SearchTalentPoolEvent>(_onSearch);
    on<ApplyFilterTalentPoolEvent>(_onApplyFilter);
    on<ResetFilterTalentPoolEvent>(_onResetFilter);
    on<LoadMoreTalentPoolEvent>(_onLoadMore);
    on<ToggleWishlistTalentPoolEvent>(_onToggleWishlist);
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Future<void> _fetchFromStart(Emitter<TalentPoolState> emit) async {
    emit(TalentPoolLoading(activeFilter: _activeFilter));

    final result = await getResourceTalentUseCase.call(
      ratings: _activeFilter.sortedRatings,
      experiences: _activeFilter.sortedExperiences,
      businessSectorIds: _activeFilter.selectedBusinessSectorIds.toList(),
      // skillName dikirim dari role chip ATAU search query.
      // Role chip mengisi selectedSkillName; search bar mengisi searchQuery.
      // Jika keduanya ada, prioritaskan role chip karena lebih spesifik;
      // searchQuery tetap dikirim terpisah via parameter yang sama di API.
      // Untuk saat ini API hanya menerima satu skill_name, sehingga:
      // - Jika selectedSkillName tidak kosong → pakai selectedSkillName
      // - Jika kosong → pakai searchQuery
      skillName: _activeFilter.selectedSkillName.isNotEmpty
          ? _activeFilter.selectedSkillName
          : _activeFilter.searchQuery,
      offset: 0,
      limit: _kPageLimit,
    );

    result.fold(
      (failure) => emit(TalentPoolError(failure.message)),
      (talents) {
        if (talents.isEmpty) {
          emit(TalentPoolEmpty(activeFilter: _activeFilter));
        } else {
          emit(TalentPoolLoaded(
            talents: talents,
            hasMore: talents.length >= _kPageLimit,
            currentOffset: talents.length,
            activeFilter: _activeFilter,
          ));
        }
      },
    );
  }

  // ── Event Handlers ────────────────────────────────────────────────────────

  Future<void> _onFetch(
    FetchTalentPoolEvent event,
    Emitter<TalentPoolState> emit,
  ) async {
    _activeFilter = event.filter;
    await _fetchFromStart(emit);
  }

  Future<void> _onSelectRole(
    SelectRoleTalentPoolEvent event,
    Emitter<TalentPoolState> emit,
  ) async {
    // Tap role yang sama (bukan '') → kembali ke '' (Semua)
    final newRole =
        (event.role == _activeFilter.selectedSkillName && event.role.isNotEmpty)
            ? ''
            : event.role;

    _activeFilter = _activeFilter.copyWith(selectedSkillName: newRole);
    await _fetchFromStart(emit);
  }

  Future<void> _onSearch(
    SearchTalentPoolEvent event,
    Emitter<TalentPoolState> emit,
  ) async {
    _activeFilter = _activeFilter.copyWith(searchQuery: event.query);
    await _fetchFromStart(emit);
  }

  Future<void> _onApplyFilter(
    ApplyFilterTalentPoolEvent event,
    Emitter<TalentPoolState> emit,
  ) async {
    _activeFilter = _activeFilter.copyWith(
      selectedRatings: event.selectedRatings,
      selectedExperiences: event.selectedExperiences,
      selectedBusinessSectorIds: event.selectedBusinessSectorIds,
    );
    await _fetchFromStart(emit);
  }

  Future<void> _onResetFilter(
    ResetFilterTalentPoolEvent event,
    Emitter<TalentPoolState> emit,
  ) async {
    _activeFilter = TalentFilter.empty;
    await _fetchFromStart(emit);
  }

  Future<void> _onLoadMore(
    LoadMoreTalentPoolEvent event,
    Emitter<TalentPoolState> emit,
  ) async {
    final currentState = state;
    if (currentState is! TalentPoolLoaded || !currentState.hasMore) return;

    emit(TalentPoolLoadingMore(
      talents: currentState.talents,
      activeFilter: _activeFilter,
    ));

    final result = await getResourceTalentUseCase.call(
      ratings: _activeFilter.sortedRatings,
      experiences: _activeFilter.sortedExperiences,
      businessSectorIds: _activeFilter.selectedBusinessSectorIds.toList(),
      skillName: _activeFilter.selectedSkillName.isNotEmpty
          ? _activeFilter.selectedSkillName
          : _activeFilter.searchQuery,
      offset: currentState.currentOffset,
      limit: _kPageLimit,
    );

    result.fold(
      (failure) => emit(TalentPoolError(failure.message)),
      (newTalents) {
        final all = [...currentState.talents, ...newTalents];
        emit(TalentPoolLoaded(
          talents: all,
          hasMore: newTalents.length >= _kPageLimit,
          currentOffset: all.length,
          activeFilter: _activeFilter,
        ));
      },
    );
  }

  Future<void> _onToggleWishlist(
    ToggleWishlistTalentPoolEvent event,
    Emitter<TalentPoolState> emit,
  ) async {
    final currentState = state;
    List<TalentRecommendationModel> currentTalents = [];
    bool hasMore = false;
    int currentOffset = 0;

    if (currentState is TalentPoolLoaded) {
      currentTalents = currentState.talents;
      hasMore = currentState.hasMore;
      currentOffset = currentState.currentOffset;
    } else if (currentState is TalentPoolLoadingMore) {
      currentTalents = currentState.talents;
      hasMore = true;
      currentOffset = currentTalents.length;
    } else {
      return;
    }

    final talentIndex =
        currentTalents.indexWhere((t) => t.id == event.talentId);
    if (talentIndex == -1) return;

    final talent = currentTalents[talentIndex];
    final originalWishlistStatus = talent.isWishlist;
    final originalWishlistCount = talent.wishlistCount;

    // Optimistic Update
    final updatedTalent = talent.copyWith(
      isWishlist: !originalWishlistStatus,
      wishlistCount: originalWishlistStatus
          ? originalWishlistCount - 1
          : originalWishlistCount + 1,
    );

    final newTalents = List<TalentRecommendationModel>.from(currentTalents);
    newTalents[talentIndex] = updatedTalent;

    emit(TalentPoolLoaded(
      talents: newTalents,
      hasMore: hasMore,
      currentOffset: currentOffset,
      activeFilter: _activeFilter,
    ));

    // Call API
    final result = await putWishlistTalentUseCase.call(event.talentId);

    result.fold(
      (failure) {
        final revertedTalents =
            List<TalentRecommendationModel>.from(newTalents);
        revertedTalents[talentIndex] = talent;
        emit(TalentPoolLoaded(
          talents: revertedTalents,
          hasMore: hasMore,
          currentOffset: currentOffset,
          activeFilter: _activeFilter,
        ));
        emit(TalentPoolWishlistFailed(
          message: failure.message,
          talents: revertedTalents,
          hasMore: hasMore,
          currentOffset: currentOffset,
          activeFilter: _activeFilter,
        ));
        emit(TalentPoolLoaded(
          talents: revertedTalents,
          hasMore: hasMore,
          currentOffset: currentOffset,
          activeFilter: _activeFilter,
        ));
      },
      (success) {
        if (success) {
          emit(TalentPoolWishlistSuccess(
            talents: newTalents,
            hasMore: hasMore,
            currentOffset: currentOffset,
            activeFilter: _activeFilter,
          ));
          emit(TalentPoolLoaded(
            talents: newTalents,
            hasMore: hasMore,
            currentOffset: currentOffset,
            activeFilter: _activeFilter,
          ));
        } else {
          final revertedTalents =
              List<TalentRecommendationModel>.from(newTalents);
          revertedTalents[talentIndex] = talent;
          emit(TalentPoolLoaded(
            talents: revertedTalents,
            hasMore: hasMore,
            currentOffset: currentOffset,
            activeFilter: _activeFilter,
          ));
        }
      },
    );
  }
}
