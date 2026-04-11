import 'package:edtech/features/auth/domain/use_cases/login_use_case.dart';
import 'package:edtech/features/auth/domain/use_cases/register_use_case.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase login;
  final RegisterUseCase register;

  AuthBloc(this.login, this.register) : super(AuthInitial()) {
    on<AuthEvent>((event, emit) async {
      if (event is Register) {
        emit(AuthLoading());
        try {
          final response = await register.execute(
            email: event.email,
            firstName: event.firstName,
            lastName: event.lastName,
            password: event.password,
            phone: event.phone,
          );
          if (response.email.isNotEmpty) {
            emit(AuthSuccess());
          }
        } catch (e) {
          emit(AuthError(e.toString()));
        }
      } else if (event is Login) {
        emit(AuthLoading());
        try {
          final response = await login.execute(
            email: event.email,
            password: event.password,
          );
          if (response.access.isNotEmpty) {
            emit(AuthSuccess());
          }
        } catch (e) {
          emit(AuthError(e.toString()));
        }
      }
    });
  }
}
