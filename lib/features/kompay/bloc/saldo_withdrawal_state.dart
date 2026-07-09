part of 'saldo_withdrawal_bloc.dart';

class SaldoWitdrawalState extends Equatable {
  const SaldoWitdrawalState({
    this.message = '',
    this.status = RequestStatus.empty,
    this.bankList,
    this.operation = '',
    this.pinData,
    this.idealBalance,
  });

  final String message;
  final RequestStatus status;
  final List<BankAccountsDataModel>? bankList;
  final String operation;
  final ChekPinModel? pinData;
  final IdealBalanceModel? idealBalance;

  SaldoWitdrawalState copyWith({
    RequestStatus? status,
    String? message,
    List<BankAccountsDataModel>? bankList,
    String? operation,
    ChekPinModel? pinData,
    IdealBalanceModel? idealBalance,
  }) {
    return SaldoWitdrawalState(
      status: status ?? this.status,
      message: message ?? this.message,
      bankList: bankList ?? this.bankList,
      operation: operation ?? this.operation,
      pinData: pinData ?? this.pinData,
      idealBalance: idealBalance ?? this.idealBalance,
    );
  }

  @override
  List<Object?> get props => [
        message,
        status,
        bankList,
        operation,
        pinData,
        idealBalance,
      ];
}
