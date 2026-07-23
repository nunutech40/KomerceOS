part of 'revenue_performance_bloc.dart';

abstract class RevenuePerformanceState extends Equatable {
  const RevenuePerformanceState();

  @override
  List<Object?> get props => [];
}

class RevenuePerformanceInitial extends RevenuePerformanceState {}

class RevenuePerformanceLoading extends RevenuePerformanceState {}

class RevenuePerformanceLoaded extends RevenuePerformanceState {
  final RevenuePerformanceModel data;

  const RevenuePerformanceLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class RevenuePerformanceError extends RevenuePerformanceState {
  final String message;

  const RevenuePerformanceError(this.message);

  @override
  List<Object?> get props => [message];
}
