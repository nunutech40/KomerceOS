import 'package:equatable/equatable.dart';

abstract class TopupEvent extends Equatable {
  const TopupEvent();
  @override
  List<Object?> get props => [];
}

class TopUpButtonPressedEvent extends TopupEvent {
  final String nominal;
  final String jenisTf;
  const TopUpButtonPressedEvent({required this.nominal, required this.jenisTf});

  @override
  List<Object> get props => [nominal];
}

class TopUpButtonPressedQrisEvent extends TopupEvent {
  final String nominal;
  const TopUpButtonPressedQrisEvent({required this.nominal});

  @override
  List<Object> get props => [nominal];
}

class LoadDataDetailTopUpEvent extends TopupEvent {
  const LoadDataDetailTopUpEvent({required this.id});

  final int id;

  @override
  List<Object> get props => [id];
}

class LoadDataCecktransactionTopUpEvent extends TopupEvent {
  final String typeCheckTrasaction;
  const LoadDataCecktransactionTopUpEvent({required this.typeCheckTrasaction});

  @override
  List<Object> get props => [typeCheckTrasaction];
}

class CancelTopUpEvent extends TopupEvent {
  const CancelTopUpEvent({required this.id});

  final int id;

  @override
  List<Object> get props => [id];
}
