import 'package:equatable/equatable.dart';
import '../../domain/entities/balance_summary_model.dart';

class BalanceSummaryResponse extends Equatable {
  final num? balance;
  final num? pendingBalance;
  final num? pendingBalanceOnProblem;
  final num? totalEarnCashback;

  const BalanceSummaryResponse({
    this.balance,
    this.pendingBalance,
    this.pendingBalanceOnProblem,
    this.totalEarnCashback,
  });

  factory BalanceSummaryResponse.fromJson(Map<String, dynamic> json) {
    return BalanceSummaryResponse(
      balance: json['balance'] as num?,
      pendingBalance: json['pending_balance'] as num?,
      pendingBalanceOnProblem: json['pending_balance_on_problem'] as num?,
      totalEarnCashback: json['total_earn_cashback'] as num?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'balance': balance,
      'pending_balance': pendingBalance,
      'pending_balance_on_problem': pendingBalanceOnProblem,
      'total_earn_cashback': totalEarnCashback,
    };
  }

  BalanceSummaryModel toEntity() {
    return BalanceSummaryModel(
      balance: balance,
      pendingBalance: pendingBalance,
      pendingBalanceOnProblem: pendingBalanceOnProblem,
      totalEarnCashback: totalEarnCashback,
    );
  }

  @override
  List<Object?> get props => [
        balance,
        pendingBalance,
        pendingBalanceOnProblem,
        totalEarnCashback,
      ];
}
