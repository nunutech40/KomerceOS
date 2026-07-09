import 'package:equatable/equatable.dart';

class ReportPerformanceWeeklyModel extends Equatable {
  final int? producId;
  final String? talentName;
  final int? totalLeads;
  final int? totalTransaction;
  final num? cr;
  final int? totalCbt;
  final String? productName;
  final String? division;

  const ReportPerformanceWeeklyModel({
    this.producId,
    this.talentName,
    this.totalLeads,
    this.totalTransaction,
    this.cr,
    this.totalCbt,
    this.productName,
    this.division,
  });

  @override
  List<Object?> get props => [
        producId,
        talentName,
        totalLeads,
        totalTransaction,
        cr,
        totalCbt,
        productName,
        division,
      ];
}
