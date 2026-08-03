import 'package:equatable/equatable.dart';
import 'package:komtim_partner/common/enum_status.dart';
import 'package:komtim_partner/core/domain/entities/report_performance_model.dart';
import 'package:komtim_partner/core/domain/entities/report_performance_monthly_model.dart';
import 'package:komtim_partner/core/domain/entities/report_performance_product_model.dart';
import 'package:komtim_partner/core/domain/entities/report_performance_weekly_model.dart';

class ReportPerformanceState extends Equatable {
  final RequestStatus? status;
  final String message;
  final List<ReportPerformanceModel>? reportPerformance;
  final List<ReportPerformanceWeeklyModel>? reportPerformanceWeekly;
  final List<ReportPerformanceMonthlyModel> reportPerformanceMonthly;
  final List<ReportPerformanceProductModel> reportPerformanceProduct;
  const ReportPerformanceState({
    this.status = RequestStatus.dataExhausted,
    this.reportPerformance = const [],
    this.reportPerformanceWeekly = const [],
    this.reportPerformanceMonthly = const [],
    this.reportPerformanceProduct = const [],
    this.message = '',
  });

  copyWith({
    RequestStatus? status,
    List<ReportPerformanceModel>? reportPerformance,
    List<ReportPerformanceWeeklyModel>? reportPerformanceWeekly,
    List<ReportPerformanceMonthlyModel>? reportPerformanceMonthly,
    List<ReportPerformanceProductModel>? reportPerformanceProduct,
    String? message,
  }) {
    return ReportPerformanceState(
      status: status ?? this.status,
      reportPerformance: reportPerformance ?? this.reportPerformance,
      reportPerformanceWeekly:
          reportPerformanceWeekly ?? this.reportPerformanceWeekly,
      reportPerformanceMonthly:
          reportPerformanceMonthly ?? this.reportPerformanceMonthly,
      reportPerformanceProduct:
          reportPerformanceProduct ?? this.reportPerformanceProduct,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [
        status,
        reportPerformance,
        reportPerformanceWeekly,
        reportPerformanceMonthly,
        reportPerformanceProduct,
        message,
      ];
}
