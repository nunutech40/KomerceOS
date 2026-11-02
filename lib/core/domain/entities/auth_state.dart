import 'package:equatable/equatable.dart';

import 'login_model.dart';

enum AuthStatus { initial, checking, authenticated, unauthenticated }

class AuthState extends Equatable {
  final AuthStatus status;
  final UserLoginModel? user;
  final bool sessionExpired;

  const AuthState._({
    required this.status,
    this.user,
    this.sessionExpired = false,
  });

  factory AuthState.initial() => const AuthState._(status: AuthStatus.initial);

  factory AuthState.checking() =>
      const AuthState._(status: AuthStatus.checking);

  factory AuthState.authenticated(UserLoginModel user) =>
      AuthState._(status: AuthStatus.authenticated, user: user);

  factory AuthState.unauthenticated({bool sessionExpired = false}) =>
      AuthState._(
          status: AuthStatus.unauthenticated, sessionExpired: sessionExpired);

  @override
  List<Object?> get props => [status, user, sessionExpired];
}
