part of 'check_bill_bloc.dart';

abstract class CheckBillEvent extends Equatable {
  const CheckBillEvent();

  @override
  List<Object?> get props => [];
}

class FetchCheckBillEvent extends CheckBillEvent {
  final bool isFromKyc;

  const FetchCheckBillEvent({this.isFromKyc = false});

  @override
  List<Object?> get props => [isFromKyc];
}
