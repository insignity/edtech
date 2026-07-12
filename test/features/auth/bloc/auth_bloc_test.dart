import 'package:bloc_test/bloc_test.dart';
import 'package:edtech/features/auth/data/auth_repository.dart';
import 'package:edtech/features/auth/models/password_reset_model.dart';
import 'package:edtech/features/auth/models/token_model.dart';
import 'package:edtech/features/auth/ui/bloc/auth_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;

  setUp(() {
    repository = MockAuthRepository();
  });

  group('Login', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthSuccess] when login succeeds',
      build: () {
        when(() => repository.login(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => TokenModel(access: 'a', refresh: 'r'));
        return AuthBloc(repository);
      },
      act: (bloc) => bloc.add(Login(email: 'test@test.com', password: '123')),
      expect: () => [isA<AuthLoading>(), isA<AuthSuccess>()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when login fails',
      build: () {
        when(() => repository.login(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenThrow(Exception('Invalid credentials'));
        return AuthBloc(repository);
      },
      act: (bloc) => bloc.add(Login(email: 'test@test.com', password: 'bad')),
      expect: () => [isA<AuthLoading>(), isA<AuthError>()],
    );
  });

  group('Logout', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoggedOut] and calls repository.logout',
      build: () {
        when(() => repository.logout()).thenAnswer((_) async {});
        return AuthBloc(repository);
      },
      act: (bloc) => bloc.add(Logout()),
      expect: () => [isA<AuthLoggedOut>()],
      verify: (_) => verify(() => repository.logout()).called(1),
    );
  });

  group('ForgotPassword', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthPasswordResetSent] with uid and token from response',
      build: () {
        when(() => repository.forgotPassword(any())).thenAnswer(
          (_) async => PasswordResetModel(
            detail: 'sent',
            uid: 'uid-1',
            token: 'token-1',
          ),
        );
        return AuthBloc(repository);
      },
      act: (bloc) => bloc.add(ForgotPassword(email: 'test@test.com')),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthPasswordResetSent>()
            .having((s) => s.uid, 'uid', 'uid-1')
            .having((s) => s.token, 'token', 'token-1'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when request fails',
      build: () {
        when(() => repository.forgotPassword(any()))
            .thenThrow(Exception('user not found'));
        return AuthBloc(repository);
      },
      act: (bloc) => bloc.add(ForgotPassword(email: 'unknown@test.com')),
      expect: () => [isA<AuthLoading>(), isA<AuthError>()],
    );
  });

  group('ResetPassword', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthPasswordResetSuccess, AuthInitial] on success',
      build: () {
        when(() => repository.resetPassword(
              uid: any(named: 'uid'),
              token: any(named: 'token'),
              newPassword: any(named: 'newPassword'),
            )).thenAnswer((_) async {});
        return AuthBloc(repository);
      },
      act: (bloc) => bloc.add(
        ResetPassword(uid: 'uid-1', token: 'token-1', newPassword: 'newpass'),
      ),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthPasswordResetSuccess>(),
        isA<AuthInitial>(),
      ],
    );
  });
}
