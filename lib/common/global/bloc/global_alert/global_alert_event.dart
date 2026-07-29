import 'package:equatable/equatable.dart';

abstract class GlobalAlertEvent extends Equatable {
  const GlobalAlertEvent();

  @override
  List<Object?> get props => [];
}

class ShowServerErrorEvent extends GlobalAlertEvent {}
