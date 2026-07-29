import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/crash/crash_reporter.dart';
import 'my_logger.dart';

class AppBlocObserver extends BlocObserver {
  final CrashReporter crashReporter;

  const AppBlocObserver([this.crashReporter = const NoopCrashReporter()]);

  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    logger.i('BLOC CREATED -> ${bloc.runtimeType}');
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    logger.i('EVENT -> ${bloc.runtimeType} $event');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    logger.i(
      'CHANGE -> ${bloc.runtimeType} '
      '${change.currentState} -> ${change.nextState}',
    );
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    logger.i(
      'TRANSITION -> ${bloc.runtimeType} '
      '$transition',
    );
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    debugPrint('ERROR -> ${bloc.runtimeType} $error');
    // Non-fatal: the bloc caught it, but it still points at a real defect.
    crashReporter.recordError(
      error,
      stackTrace,
      reason: 'Unhandled error in ${bloc.runtimeType}',
    );
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    debugPrint('BLOC CLOSED -> ${bloc.runtimeType}');
    super.onClose(bloc);
  }
}
