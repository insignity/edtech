import 'package:edtech/features/auth/data/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;

  AuthBloc(this.repository) : super(AuthInitial()) {
    on<AuthEvent>((event, emit) async {
      if (event is Register) {
        emit(AuthLoading());
        try {
          final response = await repository.register(
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
          final response = await repository.login(
            email: event.email,
            password: event.password,
          );
          if (response.access.isNotEmpty) {
            emit(AuthSuccess());
            emit(AuthInitial());
          } else {
            await repository.logout();
            emit(AuthInitial());
          }
        } catch (e) {
          emit(AuthError(e.toString()));
        }
      }
    });
  }
}
