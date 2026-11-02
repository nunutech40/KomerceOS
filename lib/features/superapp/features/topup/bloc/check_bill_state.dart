part of 'check_bill_bloc.dart';

abstract class CheckBillState extends Equatable {
  const CheckBillState();
  
  @override
  List<Object?> get props => [];
}

class CheckBillInitial extends CheckBillState {}

class CheckBillLoading extends CheckBillState {}

class CheckBillLoaded extends CheckBillState {
  final CheckBillModel data;
  final bool isFromKyc;

  const CheckBillLoaded(this.data, {this.isFromKyc = false});

  @override
  List<Object?> get props => [data, isFromKyc];
}

class CheckBillError extends CheckBillState {
  final Failure failure;

  const CheckBillError(this.failure);

  bool get isServerError => failure is ServerFailure;
  String get message => failure.message;

  @override
  List<Object?> get props => [failure];
}
