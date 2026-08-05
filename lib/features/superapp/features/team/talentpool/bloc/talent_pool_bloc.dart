import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komtim_partner/core/domain/entities/talent_recomendation_model.dart';
import 'package:komtim_partner/core/domain/usecases/get_resource_talent_use_case.dart';

part 'talent_pool_event.dart';
part 'talent_pool_state.dart';

const int _kPageLimit = 18;

/// BLoC untuk halaman Talent Pool.
/// - [FetchTalentPoolEvent] → fetch ulang dari offset 0 (pakai filter aktif)
/// - [LoadMoreTalentPoolEvent] → tambah data berikutnya (pagination)
class TalentPoolBloc extends Bloc<TalentPoolEvent, TalentPoolState> {
  final GetResourceTalentUseCase getResourceTalentUseCase;

  List<int> _activeRatings = [];
  List<String> _activeExperiences = [];
  List<int> _activeBusinessSectorIds = [];
  String _activeSkillName = '';

  TalentPoolBloc({required this.getResourceTalentUseCase})
      : super(TalentPoolInitial()) {
    on<FetchTalentPoolEvent>(_onFetch);
    on<LoadMoreTalentPoolEvent>(_onLoadMore);
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
}
