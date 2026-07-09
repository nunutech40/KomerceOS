part of 'talent_list_selected_bloc.dart';

class TalentListSelectedState extends Equatable {
  const TalentListSelectedState({
    this.message = '',
    this.status = RequestStatus.empty,
    this.talentData,
    this.operation = '',
  });

  final String message;
  final RequestStatus status;
  final List<TalentsSelectedDataModel>? talentData;
  final String operation;

  TalentListSelectedState copyWith({
    RequestStatus? status,
    String? message,
    List<TalentsSelectedDataModel>? talentData,
    String? operation,
  }) {
    return TalentListSelectedState(
        status: status ?? this.status,
        message: message ?? this.message,
        talentData: talentData ?? this.talentData,
        operation: operation ?? this.operation);
  }

  @override
  List<Object?> get props => [
        message,
        status,
        talentData,
        operation,
      ];
}
