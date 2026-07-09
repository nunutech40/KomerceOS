import 'package:equatable/equatable.dart';

class ReportPerformanceEvent extends Equatable {
  const ReportPerformanceEvent();

  @override
  List<Object?> get props => [];
}

class GetReportPerformanceEvent extends ReportPerformanceEvent {
  final String search;
  final String limit;
  final String offset;
  final String startDate;
  final String endDate;

  const GetReportPerformanceEvent({
    required this.search,
    required this.limit,
    required this.offset,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [search, limit, offset, startDate, endDate];
}

class GetReportPerformanceWeekEvent extends ReportPerformanceEvent {
  final int limit;
  final int offset;
  final int week;
  final String keyword;
  final String productId;
  final String month;

  const GetReportPerformanceWeekEvent({
    required this.limit,
    required this.offset,
    required this.week,
    required this.keyword,
    required this.productId,
    required this.month,
  });

  @override
  List<Object?> get props => [
        limit,
        offset,
        week,
        keyword,
        productId,
        month,
      ];
}

class GetReportPerformanceMonthEvent extends ReportPerformanceEvent {
  final int limit;
  final int offset;
  final int month;
  const GetReportPerformanceMonthEvent({
    required this.limit,
    required this.offset,
    required this.month,
  });

  @override
  List<Object?> get props => [
        limit,
        offset,
        month,
      ];
}

class GetReportPerformanceProductEvent extends ReportPerformanceEvent {
  final String keyword;
  final String parentId;

  const GetReportPerformanceProductEvent({
    required this.keyword,
    required this.parentId,
  });

  @override
  List<Object?> get props => [keyword, parentId];
}
