import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/data/datasources/preferences/shared_pref.dart';
import '../../../../core/domain/entities/auth_state.dart';
import '../../../../core/domain/entities/login_model.dart';
import 'auth_event.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SharedPref sharedPref;

  AuthBloc({required this.sharedPref}) : super(AuthState.initial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
  }

  Future<void> _onAuthCheckRequested(
      AuthCheckRequested event, Emitter<AuthState> emit) async {
    emit(AuthState.checking());

    try {
      final isLoggedIn = await sharedPref.isLoggedIn();

      if (isLoggedIn) {
        emit(AuthState.authenticated(const UserLoginModel(
            id: 0,
            username: '',
            fullName: '',
            email: '')));
      } else {
        emit(AuthState.unauthenticated());
      }
    } catch (e) {
      emit(AuthState.unauthenticated());
    }
  }

  Future<void> _onAuthLoginRequested(
      AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthState.authenticated(event.user));
  }

  Future<void> _onAuthLogoutRequested(
      AuthLogoutRequested event, Emitter<AuthState> emit) async {
    await sharedPref.removeDataPref();
    emit(AuthState.unauthenticated());
  }
}
