part of 'talent_list_selected_bloc.dart';

@immutable
abstract class TalentListSelectedEvent extends Equatable {
  const TalentListSelectedEvent();

  @override
  List<Object?> get props => [];
}

class TalentListSelectedPageDidload extends TalentListSelectedEvent {
  const TalentListSelectedPageDidload();
}

class UpdateSelectedTalentPageDidload extends TalentListSelectedEvent {
  final TalentsSelectedDataModel talent;
  const UpdateSelectedTalentPageDidload(this.talent);
  @override
  List<Object?> get props => [talent];
}

class SubmitUnhireTalents extends TalentListSelectedEvent {
  final List<TalentsUnhireDataModel> talents;
  final List<TalentsSelectedDataModel> selectedTalents;
  const SubmitUnhireTalents(this.talents, this.selectedTalents);
  @override
  List<Object?> get props => [talents, selectedTalents];
}
