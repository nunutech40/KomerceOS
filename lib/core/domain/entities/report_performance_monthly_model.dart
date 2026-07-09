import 'package:equatable/equatable.dart';

class ReportPerformanceMonthlyModel extends Equatable {
  final int? leads;
  final int? transaction;
  final num? cr;
  final String? productName;
  final List<DetailModel?>? detail;

  const ReportPerformanceMonthlyModel({
    this.leads,
    this.transaction,
    this.cr,
    this.productName,
    this.detail,
  });

  @override
  List<Object?> get props => [
        leads,
        transaction,
        cr,
        productName,
        detail,
      ];
}

class DetailModel extends Equatable {
  final String? talentName;
  final String? division;
  final int? totalLeads;
  final int? totalTransactions;
  final num? closingRate;
  final int? totalCbt;

  const DetailModel({
    this.talentName,
    this.division,
    this.totalLeads,
    this.totalTransactions,
    this.closingRate,
    this.totalCbt,
  });

  @override
  List<Object?> get props => [
        talentName,
        division,
        totalLeads,
        totalTransactions,
        closingRate,
        totalCbt,
      ];
}
