import 'package:equatable/equatable.dart';

class RevenuePerformanceModel extends Equatable {
  final String? paymentMethod;
  final int? totalOrder;
  final num? totalProfit;
  final List<RevenuePerformanceDayModel>? dataDays;

  const RevenuePerformanceModel({
    required this.paymentMethod,
    required this.totalOrder,
    required this.totalProfit,
    required this.dataDays,
  });

  @override
  List<Object?> get props => [paymentMethod, totalOrder, totalProfit, dataDays];
}

class RevenuePerformanceDayModel extends Equatable {
  final String? day;
  final int? totalOrder;
  final num? totalProfit;

  const RevenuePerformanceDayModel({
    required this.day,
    required this.totalOrder,
    required this.totalProfit,
  });

  @override
  List<Object?> get props => [day, totalOrder, totalProfit];
}
