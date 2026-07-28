import 'package:equatable/equatable.dart';
import '../../../../../../core/domain/entities/check_qrcode_model.dart';

abstract class CheckQrcodeState extends Equatable {
  const CheckQrcodeState();

  @override
  List<Object?> get props => [];
}

class CheckQrcodeInitial extends CheckQrcodeState {}

class CheckQrcodeLoading extends CheckQrcodeState {}

class CheckQrcodeSuccess extends CheckQrcodeState {
  final CheckQrcodeModel data;

  const CheckQrcodeSuccess(this.data);

  @override
  List<Object?> get props => [data];
}

class CheckQrcodeFailed extends CheckQrcodeState {
  final String message;

  const CheckQrcodeFailed(this.message);

  @override
  List<Object?> get props => [message];
}
