part of 'revenue_performance_bloc.dart';

abstract class RevenuePerformanceEvent extends Equatable {
  const RevenuePerformanceEvent();

  @override
  List<Object?> get props => [];
}

class FetchRevenuePerformanceEvent extends RevenuePerformanceEvent {
  final String startDate;
  final String endDate;
  final String? paymentMethod;

  const FetchRevenuePerformanceEvent({
    required this.startDate,
    required this.endDate,
    this.paymentMethod,
  });

  @override
  List<Object?> get props => [startDate, endDate, paymentMethod];
}
