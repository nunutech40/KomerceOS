import 'package:equatable/equatable.dart';
import '../../domain/entities/revenue_performance_model.dart';

class RevenuePerformanceResponse extends Equatable {
  final String? paymentMethod;
  final int? totalOrder;
  final num? totalProfit;
  final List<RevenuePerformanceDayResponse>? dataDays;

  const RevenuePerformanceResponse({
    required this.paymentMethod,
    required this.totalOrder,
    required this.totalProfit,
    required this.dataDays,
  });

  factory RevenuePerformanceResponse.fromJson(Map<String, dynamic> json) {
    return RevenuePerformanceResponse(
      paymentMethod: json['payment_method'],
      totalOrder: json['total_order'],
      totalProfit: json['total_profit'],
      dataDays: json['data_days'] != null
          ? (json['data_days'] as List)
              .map((i) => RevenuePerformanceDayResponse.fromJson(i))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'payment_method': paymentMethod,
      'total_order': totalOrder,
      'total_profit': totalProfit,
      'data_days': dataDays?.map((i) => i.toJson()).toList(),
    };
  }

  RevenuePerformanceModel toEntity() {
    return RevenuePerformanceModel(
      paymentMethod: paymentMethod,
      totalOrder: totalOrder,
      totalProfit: totalProfit,
      dataDays: dataDays?.map((i) => i.toEntity()).toList(),
    );
  }

  @override
  List<Object?> get props => [paymentMethod, totalOrder, totalProfit, dataDays];
}

class RevenuePerformanceDayResponse extends Equatable {
  final String? day;
  final int? totalOrder;
  final num? totalProfit;

  const RevenuePerformanceDayResponse({
    required this.day,
    required this.totalOrder,
    required this.totalProfit,
  });

  factory RevenuePerformanceDayResponse.fromJson(Map<String, dynamic> json) {
    return RevenuePerformanceDayResponse(
      day: json['day'],
      totalOrder: json['total_order'],
      totalProfit: json['total_profit'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'total_order': totalOrder,
      'total_profit': totalProfit,
    };
  }

  RevenuePerformanceDayModel toEntity() {
    return RevenuePerformanceDayModel(
      day: day,
      totalOrder: totalOrder,
      totalProfit: totalProfit,
    );
  }

  @override
  List<Object?> get props => [day, totalOrder, totalProfit];
}
