part of 'aplikasiku_bloc.dart';

abstract class AplikasikuEvent extends Equatable {
  const AplikasikuEvent();

  @override
  List<Object?> get props => [];
}

class FetchAplikasikuEvent extends AplikasikuEvent {}

class ResendVerificationAplikasiEvent extends AplikasikuEvent {
  final String productName;

  const ResendVerificationAplikasiEvent(this.productName);

  @override
  List<Object?> get props => [productName];
}
