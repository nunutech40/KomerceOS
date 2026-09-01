part of 'rate_talent_bloc.dart';

class RateTalentState extends Equatable {
  const RateTalentState({
    this.message = '',
    this.status = RequestStatus.empty,
    this.talentsData,
    this.operation = '',
  });

  final String message;
  final RequestStatus status;
  final TalentsModel? talentsData;
  final String operation;

  RateTalentState copyWith({
    RequestStatus? status,
    String? message,
    TalentsModel? talentsData,
    String? operation,
  }) {
    return RateTalentState(
      status: status ?? this.status,
      message: message ?? this.message,
      talentsData: talentsData ?? this.talentsData,
      operation: operation ?? this.operation,
    );
  }

  @override
  List<Object?> get props => [
        message,
        status,
        talentsData,
        operation,
      ];
}
