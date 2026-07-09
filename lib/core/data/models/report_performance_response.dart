import 'package:equatable/equatable.dart';
import 'package:komtim_partner/core/domain/entities/report_performance_model.dart';

class ReportPerformanceResponse extends Equatable {
  final String? talentName;
  final int? leads;
  final int? transaction;
  final num? cr;
  final int? cb;
  final String? description;
  final int? id;
  final int? productId;
  final String? productName;
  final String? division;
  final String? reportDate;
  final BounceReasonResponse? bounceReason;

  const ReportPerformanceResponse({
    this.talentName,
    this.leads,
    this.transaction,
    this.cr,
    this.cb,
    this.description,
    this.id,
    this.productId,
    this.productName,
    this.division,
    this.reportDate,
    this.bounceReason,
  });

  factory ReportPerformanceResponse.fromJson(Map<String, dynamic> json) {
    return ReportPerformanceResponse(
      id: json['id'] as int?,
      productId: json['product_id'] as int?,
      talentName: json['talent_name'] as String?,
      leads: json['total_leads'] as int?,
      transaction: json['total_transactions'] as int?,
      cr: json['cr'] as num?,
      cb: json['total_cbt'] as int?,
      description: json['description'] as String?,
      productName: json['product_name'] as String?,
      division: json['division'] as String?,
      reportDate: json['report_date'] as String?,
      bounceReason: json['bounce_reason'] != null
          ? BounceReasonResponse.fromJson(json['bounce_reason'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'talent_name': talentName,
      'total_leads': leads,
      'total_transactions': transaction,
      'cr': cr,
      'total_cbt': cb,
      'description': description,
      'product_name': productName,
      'division': division,
      'report_date': reportDate,
      'bounce_reason': bounceReason?.toJson(),
    };
  }

  ReportPerformanceModel toEntity() {
    return ReportPerformanceModel(
      id: id,
      talentName: talentName,
      description: description,
      division: division,
      reportDate: reportDate,
      productName: productName,
      leads: leads,
      transaction: transaction,
      cr: cr,
      cb: cb,
      bounceReason: bounceReason?.toEntity(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        productId,
        talentName,
        description,
        division,
        reportDate,
        productName,
        leads,
        transaction,
        cr,
        cb,
        bounceReason,
      ];
}

class BounceReasonResponse extends Equatable {
  final int? noReason;
  final int? stoppedAtPrice;
  final int? stoppedFromSelling;
  final int? stoppedShippingCost;
  final int? stoppedPaymentOption;
  final int? stoppedProductExplaination;
  final int? other;

  const BounceReasonResponse({
    this.noReason,
    this.stoppedAtPrice,
    this.stoppedFromSelling,
    this.stoppedShippingCost,
    this.stoppedPaymentOption,
    this.stoppedProductExplaination,
    this.other,
  });

  factory BounceReasonResponse.fromJson(Map<String, dynamic> json) {
    return BounceReasonResponse(
      noReason: json['no_reason'] as int?,
      stoppedAtPrice: json['stopped_at_price'] as int?,
      stoppedFromSelling: json['stopped_from_selling'] as int?,
      stoppedShippingCost: json['stopped_shipping_cost'] as int?,
      stoppedPaymentOption: json['stopped_payment_option'] as int?,
      stoppedProductExplaination: json['stopped_product_explaination'] as int?,
      other: json['other'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'no_reason': noReason,
      'stopped_at_price': stoppedAtPrice,
      'stopped_from_selling': stoppedFromSelling,
      'stopped_shipping_cost': stoppedShippingCost,
      'stopped_payment_option': stoppedPaymentOption,
      'stopped_product_explaination': stoppedProductExplaination,
      'other': other,
    };
  }

  BounceReason toEntity() {
    return BounceReason(
      noReason: noReason,
      stoppedAtPrice: stoppedAtPrice,
      stoppedFromSelling: stoppedFromSelling,
      stoppedShippingCost: stoppedShippingCost,
      stoppedPaymentOption: stoppedPaymentOption,
      stoppedProductExplaination: stoppedProductExplaination,
      other: other,
    );
  }

  @override
  List<Object?> get props => [
        noReason,
        stoppedAtPrice,
        stoppedFromSelling,
        stoppedShippingCost,
        stoppedPaymentOption,
        stoppedProductExplaination,
        other,
      ];
}
