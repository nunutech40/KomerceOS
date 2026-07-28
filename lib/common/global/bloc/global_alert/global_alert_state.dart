import 'package:equatable/equatable.dart';

abstract class GlobalAlertState extends Equatable {
  const GlobalAlertState();

  @override
  List<Object?> get props => [];
}

class GlobalAlertInitial extends GlobalAlertState {}

class GlobalAlertShowServerError extends GlobalAlertState {
  final int timestamp; // To ensure state changes even if triggered multiple times

  const GlobalAlertShowServerError({required this.timestamp});

  @override
  List<Object?> get props => [timestamp];
}
