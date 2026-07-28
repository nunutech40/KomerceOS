part of 'balance_summary_bloc.dart';

abstract class BalanceSummaryState extends Equatable {
  const BalanceSummaryState();

  @override
  List<Object?> get props => [];
}

class BalanceSummaryInitial extends BalanceSummaryState {}

class BalanceSummaryLoading extends BalanceSummaryState {}

class BalanceSummaryLoaded extends BalanceSummaryState {
  final BalanceSummaryModel data;

  const BalanceSummaryLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class BalanceSummaryError extends BalanceSummaryState {
  final String message;

  const BalanceSummaryError(this.message);

  @override
  List<Object?> get props => [message];
}
