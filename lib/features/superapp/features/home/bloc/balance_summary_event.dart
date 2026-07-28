part of 'balance_summary_bloc.dart';

abstract class BalanceSummaryEvent extends Equatable {
  const BalanceSummaryEvent();

  @override
  List<Object?> get props => [];
}

class FetchBalanceSummaryEvent extends BalanceSummaryEvent {
  final String partnerId;

  const FetchBalanceSummaryEvent(this.partnerId);

  @override
  List<Object?> get props => [partnerId];
}
