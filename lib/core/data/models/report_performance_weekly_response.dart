import 'package:equatable/equatable.dart';
import 'package:komtim_partner/core/domain/entities/report_performance_weekly_model.dart';

class ReportPerformanceWeeklyResponse extends Equatable {
  final int? producId;
  final String? talentName;
  final int? totalLeads;
  final int? totalTransaction;
  final num? cr;
  final int? totalCbt;
  final String? productName;
  final String? division;

  const ReportPerformanceWeeklyResponse({
    this.producId,
    this.talentName,
    this.totalLeads,
    this.totalTransaction,
    this.cr,
    this.totalCbt,
    this.productName,
    this.division,
  });

  factory ReportPerformanceWeeklyResponse.fromJson(Map<String, dynamic> json) {
    return ReportPerformanceWeeklyResponse(
      producId: json['product_id'] as int?,
      talentName: json['talent_name'] as String?,
      totalLeads: json['total_leads'] as int?,
      totalTransaction: json['total_transactions'] as int?,
      cr: json['cr'] as num?,
      totalCbt: json['total_cbt'] as int?,
      productName: json['product_name'] as String?,
      division: json['division'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': producId,
      'talent_name': talentName,
      'total_leads': totalLeads,
      'total_transactions': totalTransaction,
      'total_cbt': totalCbt,
      'cr': cr,
      'product_name': productName,
      'division': division,
    };
  }

  ReportPerformanceWeeklyModel toEntity() {
    return ReportPerformanceWeeklyModel(
      producId: producId,
      talentName: talentName,
      totalLeads: totalLeads,
      totalTransaction: totalTransaction,
      cr: cr,
      totalCbt: totalCbt,
      productName: productName,
      division: division,
    );
  }

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
