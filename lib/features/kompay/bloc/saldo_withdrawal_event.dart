part of 'saldo_withdrawal_bloc.dart';

abstract class SaldoWithdrawalEvent extends Equatable {
  const SaldoWithdrawalEvent();

  @override
  List<Object?> get props => [];
}

class BankDataLoad extends SaldoWithdrawalEvent {
  const BankDataLoad();
}

class RefreshDataEvent extends SaldoWithdrawalEvent {
  const RefreshDataEvent();
}

class NextPressedButtonEvent extends SaldoWithdrawalEvent {
  const NextPressedButtonEvent();
}

class IdealBalanceEvent extends SaldoWithdrawalEvent {
  final int partnerId;
  const IdealBalanceEvent({required this.partnerId});
  @override
  List<Object?> get props => [partnerId];
}
