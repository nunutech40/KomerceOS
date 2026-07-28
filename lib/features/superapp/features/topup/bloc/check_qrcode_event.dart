import 'package:equatable/equatable.dart';

abstract class CheckQrcodeEvent extends Equatable {
  const CheckQrcodeEvent();

  @override
  List<Object?> get props => [];
}

class DoCheckQrcode extends CheckQrcodeEvent {
  final String qrId;

  const DoCheckQrcode(this.qrId);

  @override
  List<Object?> get props => [qrId];
}
