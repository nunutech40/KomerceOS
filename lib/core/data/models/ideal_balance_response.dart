import 'package:equatable/equatable.dart';
import 'package:komtim_partner/core/domain/entities/ideal_balance_model.dart';

class IdealBalanceResponse extends Equatable {
  final num? idealBalance;
  final num? shippingReturPotential;
  final num? inComeOrderPotential;
  final num? shippingReturOnFinished;
  final num? shippingRiskBecomeRetur;
  final num? onWithdrawl;

  const IdealBalanceResponse({
    this.idealBalance,
    this.shippingReturPotential,
    this.inComeOrderPotential,
    this.shippingReturOnFinished,
    this.shippingRiskBecomeRetur,
    this.onWithdrawl,
  });

  factory IdealBalanceResponse.fromJson(Map<String, dynamic> json) {
    return IdealBalanceResponse(
      idealBalance: json['ideal_balance'],
      shippingReturPotential: json['ongkir_retur_potential'],
      shippingReturOnFinished: json['ongkir_retur_on_finished'],
      inComeOrderPotential: json['income_order_potential'],
      shippingRiskBecomeRetur: json['ongkir_risk_become_retur'],
      onWithdrawl: json['on_withdrawl'],
    );
  }

  Map<String, dynamic> toJson() => {
        'ideal_balance': idealBalance,
        'ongkir_retur_potential': shippingReturPotential,
        'ongkir_retur_on_finished': shippingReturOnFinished,
        'inComeOrderPotential': inComeOrderPotential,
        'ongkir_risk_become_retur': shippingRiskBecomeRetur,
        'on_withdrawl': onWithdrawl
      };

  IdealBalanceModel toEntity() {
    return IdealBalanceModel(
      idealBalance: idealBalance,
      shippingReturPotential: shippingReturPotential,
      shippingReturOnFinished: shippingReturOnFinished,
      inComeOrderPotential: inComeOrderPotential,
      shippingRiskBecomeRetur: shippingRiskBecomeRetur,
      onWithdrawl: onWithdrawl,
    );
  }

  @override
  List<Object?> get props => [
        idealBalance,
        shippingReturPotential,
        inComeOrderPotential,
        shippingReturOnFinished,
        shippingRiskBecomeRetur,
        onWithdrawl,
      ];
}
