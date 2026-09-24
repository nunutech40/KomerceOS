part of 'rate_talent_bloc.dart';

@immutable
abstract class RateTalentEvent extends Equatable {
  const RateTalentEvent();

  @override
  List<Object?> get props => [];
}

class RateTalentPageDidload extends RateTalentEvent {
  const RateTalentPageDidload();
}

class SetTalentRateReq extends RateTalentEvent {
  final List<TalentsDataModel> talents;
  final List<TalentLeaderModel> leaders;
  final int invoiceId;
  final int amount;

  const SetTalentRateReq(
    this.talents,
    this.leaders,
    this.invoiceId,
    this.amount,
  );

  @override
  List<Object?> get props => [talents, leaders, invoiceId, amount];
}

class RateTalentEvaluationPageDidload extends RateTalentEvent {
  final int invoiceId;
  const RateTalentEvaluationPageDidload({required this.invoiceId});
}

class ResetRateTalentOperation extends RateTalentEvent {}
