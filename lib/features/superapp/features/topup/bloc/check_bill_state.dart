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

  const CheckBillLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class CheckBillError extends CheckBillState {
  final Failure failure;

  const CheckBillError(this.failure);

  bool get isServerError => failure is ServerFailure;
  String get message => failure.message;

  @override
  List<Object?> get props => [failure];
}
