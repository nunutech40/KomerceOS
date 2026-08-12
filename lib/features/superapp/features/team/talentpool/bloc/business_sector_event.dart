part of 'business_sector_bloc.dart';

@immutable
abstract class BusinessSectorEvent extends Equatable {
  const BusinessSectorEvent();

  @override
  List<Object?> get props => [];
}

/// Memuat daftar business sector dari API.
class FetchBusinessSectorEvent extends BusinessSectorEvent {
  const FetchBusinessSectorEvent();
}
