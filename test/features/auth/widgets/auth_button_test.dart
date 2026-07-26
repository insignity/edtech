import 'package:bloc_test/bloc_test.dart';
import 'package:edtech/features/auth/ui/bloc/auth_bloc.dart';
import 'package:edtech/features/auth/ui/widgets/auth_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockAuthBloc bloc;

  setUp(() => bloc = MockAuthBloc());

  Future<void> pump(WidgetTester tester, AuthState state) {
    when(() => bloc.state).thenReturn(state);
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider<AuthBloc>.value(
            value: bloc,
            child: AuthButton(text: 'SIGN IN', onPressed: () {}),
          ),
        ),
      ),
    );
  }

  // Regression: the button used to collapse to SizedBox.shrink() on any state
  // outside {initial, loading, error}, leaving no way to sign in after logout.
  final statesThatMustRender = <String, AuthState>{
    'initial': AuthInitial(),
    'error': AuthError('boom'),
    'logged out': AuthLoggedOut(),
    'success': AuthSuccess(),
    'password reset sent': AuthPasswordResetSent(uid: 'u', token: 't'),
    'password reset success': AuthPasswordResetSuccess(),
  };

  statesThatMustRender.forEach((name, state) {
    testWidgets('stays tappable when state is $name', (tester) async {
      await pump(tester, state);

      expect(find.text('SIGN IN'), findsOneWidget);
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNotNull);
    });
  });

  testWidgets('shows a spinner and blocks taps while loading', (tester) async {
    await pump(tester, AuthLoading());

    expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
    expect(find.text('SIGN IN'), findsNothing);
    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);
  });
}
