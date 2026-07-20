import 'package:equatable/equatable.dart';

class BalanceSummaryModel extends Equatable {
  final num? balance;
  final num? pendingBalance;
  final num? pendingBalanceOnProblem;
  final num? totalEarnCashback;

  const BalanceSummaryModel({
    this.balance,
    this.pendingBalance,
    this.pendingBalanceOnProblem,
    this.totalEarnCashback,
  });

  @override
  List<Object?> get props => [
        balance,
        pendingBalance,
        pendingBalanceOnProblem,
        totalEarnCashback,
      ];
}
