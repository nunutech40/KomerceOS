import 'package:equatable/equatable.dart';
import 'package:komtim_partner/core/data/models/basic_meta_data_response.dart';
import 'package:komtim_partner/core/domain/entities/balance_analytics_model.dart';

class DashboardBalanceResponse extends Equatable {
  final MetaResponses meta;
  final DashboardBalanceData data;

  const DashboardBalanceResponse({
    required this.meta,
    required this.data,
  });

  factory DashboardBalanceResponse.fromJson(Map<String, dynamic> json) {
    return DashboardBalanceResponse(
      meta: MetaResponses.fromJson(json['meta']),
      data: DashboardBalanceData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'meta': meta.toJson(),
      'data': data.toJson(),
    };
  }

  DashboardBalanceModel toEntity() {
    return DashboardBalanceModel(meta: meta, data: data.toEntity());
  }

  @override
  List<Object?> get props => [meta, data];
}

class DashboardBalanceData extends Equatable {
  final num idealBalance;
  final num ongkirReturPotential;
  final num incomeOrderPotential;
  final num ongkirReturOnFinished;
  final num ongkirRiskBecomeRetur;
  final num onWithdrawl;

  const DashboardBalanceData({
    required this.idealBalance,
    required this.ongkirReturPotential,
    required this.incomeOrderPotential,
    required this.ongkirReturOnFinished,
    required this.ongkirRiskBecomeRetur,
    required this.onWithdrawl,
  });

  factory DashboardBalanceData.fromJson(Map<String, dynamic> json) {
    return DashboardBalanceData(
      idealBalance: json['ideal_balance'],
      ongkirReturPotential: json['ongkir_retur_potential'],
      incomeOrderPotential: json['income_order_potential'],
      ongkirReturOnFinished: json['ongkir_retur_on_finished'],
      ongkirRiskBecomeRetur: json['ongkir_risk_become_retur'],
      onWithdrawl: json['on_withdrawl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ideal_balance': idealBalance,
      'ongkir_retur_potential': ongkirReturPotential,
      'income_order_potential': incomeOrderPotential,
      'ongkir_retur_on_finished': ongkirReturOnFinished,
      'ongkir_risk_become_retur': ongkirRiskBecomeRetur,
      'on_withdrawl': onWithdrawl,
    };
  }

  DashboardBalanceDataModel toEntity() {
    return DashboardBalanceDataModel(
        idealBalance: idealBalance,
        ongkirReturPotential: ongkirReturPotential,
        incomeOrderPotential: incomeOrderPotential,
        ongkirReturOnFinished: ongkirReturOnFinished,
        ongkirRiskBecomeRetur: ongkirRiskBecomeRetur,
        onWithdrawl: onWithdrawl);
  }

  @override
  List<Object?> get props => [
        idealBalance,
        ongkirReturPotential,
        incomeOrderPotential,
        ongkirReturOnFinished,
        ongkirRiskBecomeRetur,
        onWithdrawl,
      ];
}
