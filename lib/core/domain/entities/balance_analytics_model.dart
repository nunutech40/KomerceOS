import 'package:equatable/equatable.dart';
import 'package:komtim_partner/core/data/models/basic_meta_data_response.dart';

class DashboardBalanceModel extends Equatable {
  final MetaResponses meta;
  final DashboardBalanceDataModel data;

  const DashboardBalanceModel({
    required this.meta,
    required this.data,
  });

  @override
  List<Object?> get props => [meta, data];
}

class DashboardBalanceDataModel extends Equatable {
  final num idealBalance;
  final num ongkirReturPotential;
  final num incomeOrderPotential;
  final num ongkirReturOnFinished;
  final num ongkirRiskBecomeRetur;
  final num onWithdrawl;

  const DashboardBalanceDataModel({
    required this.idealBalance,
    required this.ongkirReturPotential,
    required this.incomeOrderPotential,
    required this.ongkirReturOnFinished,
    required this.ongkirRiskBecomeRetur,
    required this.onWithdrawl,
  });

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
