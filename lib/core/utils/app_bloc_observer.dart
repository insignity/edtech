import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/crash/crash_reporter.dart';
import 'my_logger.dart';

class AppBlocObserver extends BlocObserver {
  final CrashReporter crashReporter;

  const AppBlocObserver([this.crashReporter = const NoopCrashReporter()]);

  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    logger.i('+ ${bloc.runtimeType}');
  }

  // Transition already carries the event, so a Bloc only needs this one line.
  // A Cubit has no events and never fires onTransition, so onChange covers it.
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    if (bloc is! Bloc) {
      logger.i(
        '${bloc.runtimeType}: ${change.currentState.runtimeType} -> '
        '${change.nextState.runtimeType}',
      );
    }
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    logger.i(
      '${bloc.runtimeType}: ${transition.event.runtimeType} -> '
      '${transition.currentState.runtimeType} -> '
      '${transition.nextState.runtimeType}',
    );
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    // Non-fatal: the bloc caught it, but it still points at a real defect.
    logger.e('${bloc.runtimeType} error', error: error, stackTrace: stackTrace);
    crashReporter.recordError(
      error,
      stackTrace,
      reason: 'Unhandled error in ${bloc.runtimeType}',
    );
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    logger.i('- ${bloc.runtimeType}');
    super.onClose(bloc);
  }
}
