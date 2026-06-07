import 'package:edtech/features/auth/data/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;

  AuthBloc(this.repository) : super(AuthInitial()) {
    on<Login>(_onLogin);
    on<Register>(_onRegister);
    on<Logout>(_onLogout);
    on<ForgotPassword>(_onForgotPassword);
    on<ResetPassword>(_onResetPassword);
  }

  Future<void> _onLogin(Login event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await repository.login(email: event.email, password: event.password);
      emit(AuthSuccess());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onRegister(Register event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await repository.register(
        email: event.email,
        firstName: event.firstName,
        lastName: event.lastName,
        password: event.password,
        phone: event.phone,
      );
      emit(AuthSuccess());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogout(Logout event, Emitter<AuthState> emit) async {
    await repository.logout();
    emit(AuthLoggedOut());
  }

  Future<void> _onForgotPassword(ForgotPassword event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final result = await repository.forgotPassword(event.email);
      emit(AuthPasswordResetSent(uid: result.uid, token: result.token));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onResetPassword(ResetPassword event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await repository.resetPassword(
        uid: event.uid,
        token: event.token,
        newPassword: event.newPassword,
      );
      emit(AuthPasswordResetSuccess());
      emit(AuthInitial());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
