import 'package:equatable/equatable.dart';

abstract class CreateQrcodeEvent extends Equatable {
  const CreateQrcodeEvent();

  @override
  List<Object?> get props => [];
}

class DoCreateQrcode extends CreateQrcodeEvent {
  final String channelPay;
  final String description;
  final int amount;
  final int duration;

  const DoCreateQrcode({
    required this.channelPay,
    required this.description,
    required this.amount,
    required this.duration,
  });

  @override
  List<Object?> get props => [channelPay, description, amount, duration];
}
