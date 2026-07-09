import 'package:equatable/equatable.dart';
import 'package:komtim_partner/core/domain/entities/talents_model.dart';
import 'package:komtim_partner/core/domain/usecases/get_talent_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/save_talent_selected_use_case.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:komtim_partner/common/enum_status.dart';

import '../../../core/data/models/talents_response.dart';

part 'talent_list_event.dart';
part 'talent_list_state.dart';

class TalentListBloc extends Bloc<TalentListEvent, TalentListState> {
  TalentListBloc({required this.getTalensUseCase, required this.saveSelectedTalentUseCase})
      : super(const TalentListState()) {
    on<TalentListPageDidload>(_handleDidLoadPage);
    on<SaveTalentsSelected>(_saveTalents);
  }

  final GetTalensUseCase getTalensUseCase;
  final SaveSelectedTalensUseCase saveSelectedTalentUseCase;

  Future<void> _saveTalents(
    SaveTalentsSelected event,
    Emitter<TalentListState> emit,
  ) async {
    emit(state.copyWith(status: RequestStatus.loading));

    final talentsResult = await saveSelectedTalentUseCase.execute(event.talents);

    talentsResult.fold(
      (failure) {
        emit(state.copyWith(
            message: failure.message,
            status: RequestStatus.failure,
            operation: 'getTalents'));
      },
      (talentsData) {
        emit(state.copyWith(
            message: 'Success',
            status: RequestStatus.success));
      },
    );
  }

  Future<void> _handleDidLoadPage(
    TalentListPageDidload event,
    Emitter<TalentListState> emit,
  ) async {
    emit(state.copyWith(status: RequestStatus.loading));

    final talentsResult = await getTalensUseCase.execute();

    talentsResult.fold(
      (failure) {
        emit(state.copyWith(
            message: failure.message,
            status: RequestStatus.failure,
            operation: 'getTalents'));
      },
      (talentsData) {
        emit(state.copyWith(
            message: 'Success',
            operation: 'getTalents',
            status: RequestStatus.success,
            talentData: talentsData));
      },
    );
  }
}
