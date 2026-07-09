import 'package:equatable/equatable.dart';

class IdealBalanceModel extends Equatable {
  final num? idealBalance;
  final num? shippingReturPotential;
  final num? inComeOrderPotential;
  final num? shippingReturOnFinished;
  final num? shippingRiskBecomeRetur;
  final num? onWithdrawl;

  const IdealBalanceModel({
    this.idealBalance,
    this.shippingReturPotential,
    this.inComeOrderPotential,
    this.shippingReturOnFinished,
    this.shippingRiskBecomeRetur,
    this.onWithdrawl,
  });

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
