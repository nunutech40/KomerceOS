import 'package:equatable/equatable.dart';
import 'package:komtim_partner/core/domain/entities/report_performance_monthly_model.dart';

class ReportPerformanceMonthlyResponse extends Equatable {
  final int? leads;
  final int? transaction;
  final num? cr;
  final String? productName;
  final List<DetailResponse>? detail;

  const ReportPerformanceMonthlyResponse({
    this.leads,
    this.transaction,
    this.cr,
    this.productName,
    this.detail,
  });

  factory ReportPerformanceMonthlyResponse.fromJson(Map<String, dynamic> json) {
    return ReportPerformanceMonthlyResponse(
      leads: json['leads'] as int?,
      transaction: json['transactions'] as int?,
      cr: json['cr'] as num?,
      productName: json['product_name'] as String?,
      detail: json['talent_performance'] != null
          ? List<DetailResponse>.from((json['talent_performance']
                  as List<dynamic>)
              .map((x) => DetailResponse.fromJson(x as Map<String, dynamic>)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'leads': leads,
      'transactions': transaction,
      'cr': cr,
      'product_name': productName,
      'talent_performance': detail?.map((x) => x.toJson()).toList(),
    };
  }

  ReportPerformanceMonthlyModel toEntity() {
    return ReportPerformanceMonthlyModel(
      leads: leads,
      transaction: transaction,
      cr: cr,
      productName: productName,
      detail: detail?.map((x) => x.toEntity()).toList(),
    );
  }

  @override
  List<Object?> get props => [
        leads,
        transaction,
        cr,
        productName,
        detail,
      ];
}

class DetailResponse extends Equatable {
  final String? talentName;
  final String? division;
  final int? totalLeads;
  final int? totalTransactions;
  final num? closingRate;
  final int? totalCbt;

  const DetailResponse({
    this.talentName,
    this.division,
    this.totalLeads,
    this.totalTransactions,
    this.closingRate,
    this.totalCbt,
  });

  factory DetailResponse.fromJson(Map<String, dynamic> json) {
    return DetailResponse(
      talentName: json['talent_name'] as String?,
      division: json['division'] as String?,
      totalLeads: json['total_leads'] as int?,
      totalTransactions: json['total_transactions'] as int?,
      closingRate: json['closing_rate'] as num?,
      totalCbt: json['total_cbt'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'talent_name': talentName,
      'division': division,
      'total_leads': totalLeads,
      'total_transactions': totalTransactions,
      'closing_rate': closingRate,
      'total_cbt': totalCbt,
    };
  }

  DetailModel toEntity() {
    return DetailModel(
      talentName: talentName,
      division: division,
      totalLeads: totalLeads,
      totalTransactions: totalTransactions,
      closingRate: closingRate,
      totalCbt: totalCbt,
    );
  }

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
