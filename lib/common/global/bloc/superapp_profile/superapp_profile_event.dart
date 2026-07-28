part of 'superapp_profile_bloc.dart';

abstract class SuperappProfileEvent extends Equatable {
  const SuperappProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Trigger fetch profile dari API
class FetchSuperappProfileEvent extends SuperappProfileEvent {
  const FetchSuperappProfileEvent();
}

/// Clear data saat logout (mencegah data user A terlihat oleh user B)
class ClearSuperappProfileEvent extends SuperappProfileEvent {
  const ClearSuperappProfileEvent();
}
