import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../viewmodels/auth_repository.dart';


// Events
abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthStarted extends AuthEvent {}
class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  AuthLoginRequested(this.email, this.password);
}
class AuthSignupRequested extends AuthEvent {
  final String email;
  final String password;
  AuthSignupRequested(this.email, this.password);
}
class AuthLogoutRequested extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class Authenticated extends AuthState {
  final String token;
  final Map<String, dynamic> user;
  Authenticated(this.token, this.user);
  @override
  List<Object?> get props => [token, user];
}
class Unauthenticated extends AuthState {}
class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repo;
  AuthBloc(this.repo) : super(AuthInitial()) {
    on<AuthStarted>((event, emit) async {
      emit(AuthLoading());
      final t = await repo.token();
      if (t != null) {
        emit(Authenticated(t, {}));
      } else {
        emit(Unauthenticated());
      }
    });

    on<AuthLoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final res = await repo.login(event.email, event.password);
        emit(Authenticated(res['token'], res['user'] ?? {}));
      } catch (e) {
        emit(AuthFailure(e.toString()));
        emit(Unauthenticated());
      }
    });

    on<AuthSignupRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await repo.signup(event.email, event.password);
        // After signup, direct to login
        emit(Unauthenticated());
      } catch (e) {
        emit(AuthFailure(e.toString()));
        emit(Unauthenticated());
      }
    });

    on<AuthLogoutRequested>((event, emit) async {
      await repo.logout();
      emit(Unauthenticated());
    });
  }
}
