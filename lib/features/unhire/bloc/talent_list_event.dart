part of 'talent_list_bloc.dart';

@immutable
abstract class TalentListEvent extends Equatable {
  const TalentListEvent();

  @override
  List<Object?> get props => [];
}

class TalentListPageDidload extends TalentListEvent {
  const TalentListPageDidload();
}

class SaveTalentsSelected extends TalentListEvent {
  final List<TalentsSelectedData> talents;
  const SaveTalentsSelected(this.talents);
  @override
  List<Object?> get props => [talents];
}
