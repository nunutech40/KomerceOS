part of 'expire_qrcode_bloc.dart';

abstract class ExpireQrcodeState extends Equatable {
  const ExpireQrcodeState();
  
  @override
  List<Object?> get props => [];
}

class ExpireQrcodeInitial extends ExpireQrcodeState {}

class ExpireQrcodeLoading extends ExpireQrcodeState {}

class ExpireQrcodeSuccess extends ExpireQrcodeState {}

class ExpireQrcodeError extends ExpireQrcodeState {
  final Failure failure;

  const ExpireQrcodeError(this.failure);

  bool get isServerError => failure is ServerFailure;
  String get message => failure.message;

  @override
  List<Object?> get props => [failure];
}
