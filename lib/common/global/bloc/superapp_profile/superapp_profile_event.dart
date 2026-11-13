part of 'superapp_profile_bloc.dart';

abstract class SuperappProfileEvent extends Equatable {
  const SuperappProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Trigger fetch profile dari API
class FetchSuperappProfileEvent extends SuperappProfileEvent {
  /// Jika true, BLoC akan memeriksa apakah ada profile yang sudah di-seed
  /// (misal dari post-verify 2FA) sebelum melakukan network call.
  final bool usePreloaded;

  const FetchSuperappProfileEvent({this.usePreloaded = false});

  @override
  List<Object?> get props => [usePreloaded];
}

/// Clear data saat logout (mencegah data user A terlihat oleh user B)
class ClearSuperappProfileEvent extends SuperappProfileEvent {
  const ClearSuperappProfileEvent();
}
