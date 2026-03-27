import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repository;

  AuthBloc(this._repository) : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthSignupRequested>(_onSignupRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onCheckRequested(
      AuthCheckRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final user = await _repository.checkAuth();
      if (user != null) {
        emit(AuthAuthenticated(
          userId: user.userId,
          email: user.email,
          hasKingdom: user.hasKingdom,
        ));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (_) {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(
      AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final user = await _repository.login(event.email, event.password);
      emit(AuthAuthenticated(
        userId: user.userId,
        email: user.email,
        hasKingdom: user.hasKingdom,
      ));
    } on Exception catch (e) {
      emit(AuthFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onSignupRequested(
      AuthSignupRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final user = await _repository.signup(event.email, event.password);
      emit(AuthAuthenticated(
        userId: user.userId,
        email: user.email,
        hasKingdom: user.hasKingdom,
      ));
    } on Exception catch (e) {
      emit(AuthFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onLogoutRequested(
      AuthLogoutRequested event, Emitter<AuthState> emit) async {
    await _repository.logout();
    emit(const AuthUnauthenticated());
  }
}
