part of 'talent_list_bloc.dart';

class TalentListState extends Equatable {
  const TalentListState({
    this.message = '',
    this.status = RequestStatus.empty,
    this.talentData,
    this.operation = '',
  });

  final String message;
  final RequestStatus status;
  final TalentsModel? talentData;
  final String operation;

  TalentListState copyWith({
    RequestStatus? status,
    String? message,
    TalentsModel? talentData,
    String? operation,
  }) {
    return TalentListState(
      status: status ?? this.status,
      message: message ?? this.message,
      talentData: talentData ?? this.talentData,
      operation: operation ?? this.operation
    );
  }

  @override 
  List<Object?> get props => [
        message,
        status,
        talentData,
        operation,
      ];
}
