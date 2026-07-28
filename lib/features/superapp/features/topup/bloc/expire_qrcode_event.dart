part of 'expire_qrcode_bloc.dart';

abstract class ExpireQrcodeEvent extends Equatable {
  const ExpireQrcodeEvent();

  @override
  List<Object?> get props => [];
}

class FetchExpireQrcodeEvent extends ExpireQrcodeEvent {
  final String qrId;

  const FetchExpireQrcodeEvent(this.qrId);

  @override
  List<Object?> get props => [qrId];
}
