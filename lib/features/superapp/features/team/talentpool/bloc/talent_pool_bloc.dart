import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komtim_partner/core/domain/entities/talent_recomendation_model.dart';
import 'package:komtim_partner/core/domain/usecases/get_resource_talent_use_case.dart';

import 'package:komtim_partner/core/domain/usecases/put_wishlist_talent_use_case.dart';

part 'talent_pool_event.dart';
part 'talent_pool_state.dart';

const int _kPageLimit = 18;

/// BLoC untuk halaman Talent Pool.
/// - [FetchTalentPoolEvent] → fetch ulang dari offset 0 (pakai filter aktif)
/// - [LoadMoreTalentPoolEvent] → tambah data berikutnya (pagination)
/// - [ToggleWishlistTalentPoolEvent] → ubah status wishlist pada talent
class TalentPoolBloc extends Bloc<TalentPoolEvent, TalentPoolState> {
  final GetResourceTalentUseCase getResourceTalentUseCase;
  final PutWishlistTalentUseCase putWishlistTalentUseCase;

  List<int> _activeRatings = [];
  List<String> _activeExperiences = [];
  List<int> _activeBusinessSectorIds = [];
  String _activeSkillName = '';

  TalentPoolBloc({
    required this.getResourceTalentUseCase,
    required this.putWishlistTalentUseCase,
  }) : super(TalentPoolInitial()) {
    on<FetchTalentPoolEvent>(_onFetch);
    on<LoadMoreTalentPoolEvent>(_onLoadMore);
    on<ToggleWishlistTalentPoolEvent>(_onToggleWishlist);
  }

  Future<void> _onFetch(
    FetchTalentPoolEvent event,
    Emitter<TalentPoolState> emit,
  ) async {
    _activeRatings = event.ratings;
    _activeExperiences = event.experiences;
    _activeBusinessSectorIds = event.businessSectorIds;
    _activeSkillName = event.skillName;

    emit(TalentPoolLoading());

    final result = await getResourceTalentUseCase.call(
      ratings: _activeRatings,
      experiences: _activeExperiences,
      businessSectorIds: _activeBusinessSectorIds,
      skillName: _activeSkillName,
      offset: 0,
      limit: _kPageLimit,
    );

    result.fold(
      (failure) => emit(TalentPoolError(failure.message)),
      (talents) {
        if (talents.isEmpty) {
          emit(TalentPoolEmpty());
        } else {
          emit(TalentPoolLoaded(
            talents: talents,
            hasMore: talents.length >= _kPageLimit,
            currentOffset: talents.length,
          ));
        }
      },
    );
  }

  Future<void> _onLoadMore(
    LoadMoreTalentPoolEvent event,
    Emitter<TalentPoolState> emit,
  ) async {
    final currentState = state;
    if (currentState is! TalentPoolLoaded || !currentState.hasMore) return;

    emit(TalentPoolLoadingMore(talents: currentState.talents));

    final result = await getResourceTalentUseCase.call(
      ratings: _activeRatings,
      experiences: _activeExperiences,
      businessSectorIds: _activeBusinessSectorIds,
      skillName: _activeSkillName,
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
        ));
      },
    );
  }

  Future<void> _onToggleWishlist(
    ToggleWishlistTalentPoolEvent event,
    Emitter<TalentPoolState> emit,
  ) async {
    // Only proceed if we have a loaded state (can be TalentPoolLoaded or TalentPoolLoadingMore)
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
      hasMore = true; // Assume true since we are loading more
      currentOffset = currentTalents.length;
    } else {
      return;
    }

    final talentIndex = currentTalents.indexWhere((t) => t.id == event.talentId);
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
    ));

    // Call API
    final result = await putWishlistTalentUseCase.call(event.talentId);

    result.fold(
      (failure) {
        // Revert on failure
        final revertedTalents = List<TalentRecommendationModel>.from(newTalents);
        revertedTalents[talentIndex] = talent; // Back to original
        emit(TalentPoolLoaded(
          talents: revertedTalents,
          hasMore: hasMore,
          currentOffset: currentOffset,
        ));
        // We emit a special state to show failure snackbar, then immediately back to loaded
        emit(TalentPoolWishlistFailed(
          message: failure.message,
          talents: revertedTalents,
          hasMore: hasMore,
          currentOffset: currentOffset,
        ));
        emit(TalentPoolLoaded(
          talents: revertedTalents,
          hasMore: hasMore,
          currentOffset: currentOffset,
        ));
      },
      (success) {
        if (success) {
          // Send success state to show snackbar, then immediately back to loaded
          emit(TalentPoolWishlistSuccess(
            talents: newTalents,
            hasMore: hasMore,
            currentOffset: currentOffset,
          ));
          emit(TalentPoolLoaded(
            talents: newTalents,
            hasMore: hasMore,
            currentOffset: currentOffset,
          ));
        } else {
          // Revert if somehow success is false
          final revertedTalents = List<TalentRecommendationModel>.from(newTalents);
          revertedTalents[talentIndex] = talent;
          emit(TalentPoolLoaded(
            talents: revertedTalents,
            hasMore: hasMore,
            currentOffset: currentOffset,
          ));
        }
      },
    );
  }
}
