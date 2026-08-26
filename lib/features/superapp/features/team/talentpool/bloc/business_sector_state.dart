part of 'business_sector_bloc.dart';

@immutable
abstract class BusinessSectorState extends Equatable {
  const BusinessSectorState();

  @override
  List<Object?> get props => [];
}

class BusinessSectorInitial extends BusinessSectorState {}

class BusinessSectorLoading extends BusinessSectorState {}

class BusinessSectorLoaded extends BusinessSectorState {
  final List<BusinessSectorModel> sectors;

  const BusinessSectorLoaded(this.sectors);

  @override
  List<Object?> get props => [sectors];
}

class BusinessSectorError extends BusinessSectorState {
  final String message;

  const BusinessSectorError(this.message);

  @override
  List<Object?> get props => [message];
}
