import 'package:equatable/equatable.dart';

class ReportPerformanceModel extends Equatable {
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
  final BounceReason? bounceReason;
  final bool? isExpanded;

  const ReportPerformanceModel({
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
    this.isExpanded,
  });

  @override
  List<Object?> get props => [
        talentName,
        leads,
        transaction,
        cr,
        cb,
        description,
        id,
        productName,
        division,
        reportDate,
        bounceReason,
        isExpanded
      ];
}

class BounceReason extends Equatable {
  final int? noReason;
  final int? stoppedAtPrice;
  final int? stoppedFromSelling;
  final int? stoppedShippingCost;
  final int? stoppedPaymentOption;
  final int? stoppedProductExplaination;
  final int? other;

  const BounceReason({
    this.noReason,
    this.stoppedAtPrice,
    this.stoppedFromSelling,
    this.stoppedShippingCost,
    this.stoppedPaymentOption,
    this.stoppedProductExplaination,
    this.other,
  });

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
