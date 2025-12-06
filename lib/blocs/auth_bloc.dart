import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/auth_repository.dart';

abstract class AuthEvent {}

class LoginEvent extends AuthEvent {
  final String username;
  final String password;
  LoginEvent(this.username, this.password);
}

class RegisterEvent extends AuthEvent {
  final String username;
  final String password;
  RegisterEvent(this.username, this.password);
}

class LogoutEvent extends AuthEvent {}

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {}

class RegisterSuccess extends AuthState {}

class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repo;

  AuthBloc(this.repo) : super(AuthInitial()) {
    on<LoginEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        await repo.login(event.username, event.password);
        emit(AuthSuccess());
      } catch (e) {
        emit(AuthFailure(e.toString().replaceAll("Exception: ", "")));
      }
    });

    on<RegisterEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        await repo.register(event.username, event.password);
        emit(RegisterSuccess());
      } catch (e) {
        emit(AuthFailure(e.toString().replaceAll("Exception: ", "")));
      }
    });

    on<LogoutEvent>((event, emit) => emit(AuthInitial()));
  }
}
