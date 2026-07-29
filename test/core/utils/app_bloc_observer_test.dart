import 'package:bloc_test/bloc_test.dart';
import 'package:edtech/core/services/crash/crash_reporter.dart';
import 'package:edtech/core/utils/app_bloc_observer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCrashReporter extends Mock implements CrashReporter {}

class _CounterCubit extends Cubit<int> {
  _CounterCubit() : super(0);
}

class MockCubit extends MockBloc<int, int> implements _CounterCubit {}

void main() {
  late MockCrashReporter reporter;
  late AppBlocObserver observer;

  setUpAll(() => registerFallbackValue(StackTrace.empty));

  setUp(() {
    reporter = MockCrashReporter();
    observer = AppBlocObserver(reporter);

    when(
      () => reporter.recordError(
        any(),
        any(),
        reason: any(named: 'reason'),
        fatal: any(named: 'fatal'),
      ),
    ).thenAnswer((_) async {});
  });

  test('forwards bloc errors to the crash reporter', () {
    final error = Exception('boom');
    final stackTrace = StackTrace.current;

    observer.onError(MockCubit(), error, stackTrace);

    verify(
      () => reporter.recordError(
        error,
        stackTrace,
        reason: any(named: 'reason', that: contains('MockCubit')),
      ),
    ).called(1);
  });

  // Reporting is a diagnostic — without one wired up the app must still run.
  test('defaults to a reporter that swallows everything', () {
    const noop = NoopCrashReporter();

    expect(
      () => const AppBlocObserver().onError(
        MockCubit(),
        Exception('boom'),
        StackTrace.current,
      ),
      returnsNormally,
    );
    expect(noop.recordError(Exception('boom'), null), completes);
    expect(noop.log('breadcrumb'), completes);
    expect(noop.setUserId('user-1'), completes);
    expect(noop.setCustomKey('key', 'value'), completes);
  });
}
