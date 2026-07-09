import 'package:equatable/equatable.dart';
import 'package:komtim_partner/core/domain/entities/talents_model.dart';
import 'package:komtim_partner/core/domain/usecases/get_talent_selected_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/send_unhire_talents_use_case.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:komtim_partner/common/enum_status.dart';

import '../../../core/domain/usecases/update_selected_talent_use_case.dart';

part 'talent_list_selected_event.dart';
part 'talent_list_selected_state.dart';

class TalentListSelectedBloc
    extends Bloc<TalentListSelectedEvent, TalentListSelectedState> {
  TalentListSelectedBloc(
      {required this.getSelectedTalensUseCase,
      required this.updateSelectedTalentsUseCase,
      required this.sendUnhireTalentsUseCase})
      : super(const TalentListSelectedState()) {
    on<TalentListSelectedPageDidload>(_handleDidLoadPage);
    on<UpdateSelectedTalentPageDidload>(_updateTalent);
    on<SubmitUnhireTalents>(_submitUnhireTalents);
  }

  final GetSelectedTalensUseCase getSelectedTalensUseCase;
  final UpdateSelectedTalensUseCase updateSelectedTalentsUseCase;
  final SendUnhireTalentsUseCase sendUnhireTalentsUseCase;

  Future<void> _updateTalent(
    UpdateSelectedTalentPageDidload event,
    Emitter<TalentListSelectedState> emit,
  ) async {
    emit(state.copyWith(status: RequestStatus.loading));

    final talentsResult =
        await updateSelectedTalentsUseCase.execute(event.talent);

    talentsResult.fold(
      (failure) {
        emit(state.copyWith(
            message: failure.message,
            status: RequestStatus.failure,
            operation: 'updateTalent'));
      },
      (isSelected) {
        emit(state.copyWith(
          message: 'Success',
          status: RequestStatus.success,
        ));
      },
    );
  }

  Future<void> _submitUnhireTalents(
    SubmitUnhireTalents event,
    Emitter<TalentListSelectedState> emit,
  ) async {
    emit(state.copyWith(status: RequestStatus.loading));
    
    List<TalentsUnhireDataModel> talents = [];
    List<TalentsSelectedDataModel> selectedTalents = [];

    talents = event.talents;
    selectedTalents = event.selectedTalents;

    talents = selectedTalents.map((e) {
      return TalentsUnhireDataModel(
        jobAssigneeId: e.jobAssigneeId!,
        talentId: e.talentId!,
        reasonQuit: e.reason!,
      );
    }).toList();
    final talentsResult = await sendUnhireTalentsUseCase.execute(talents);

    talentsResult.fold(
      (failure) {
        emit(state.copyWith(
            message: failure.message,
            status: RequestStatus.failure,
            operation: 'submitUnhire'));
      },
      (isSelected) {
        emit(state.copyWith(
          message: 'Success Unhire',
          status: RequestStatus.success,
        ));
      },
    );
  }

  Future<void> _handleDidLoadPage(
    TalentListSelectedPageDidload event,
    Emitter<TalentListSelectedState> emit,
  ) async {
    emit(state.copyWith(status: RequestStatus.loading));

    final talentsResult = await getSelectedTalensUseCase.execute();

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
            status: RequestStatus.success,
            talentData: talentsData));
      },
    );
  }
}
