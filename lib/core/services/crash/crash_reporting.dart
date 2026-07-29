import 'dart:async';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import '../../utils/my_logger.dart';
import 'crash_reporter.dart';

/// Brings crash reporting up and hands back the reporter the app should use.
///
/// Returns a [NoopCrashReporter] when Firebase cannot start — most often
/// because the native config files are not in place yet. Reporting is a
/// diagnostic, so its absence must never take the app down with it.
Future<CrashReporter> initCrashReporting() async {
  try {
    await Firebase.initializeApp();
  } catch (error) {
    logger.w('Crash reporting is off — Firebase did not start: $error');
    return const NoopCrashReporter();
  }

  final crashlytics = FirebaseCrashlytics.instance;

  // Debug runs would otherwise bury real crashes under development noise.
  await crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);

  // Framework errors: failed builds, layout overflows, bad assertions.
  final previousOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    previousOnError?.call(details);
    crashlytics.recordFlutterFatalError(details);
  };

  // Anything thrown outside the framework's own zone.
  PlatformDispatcher.instance.onError = (error, stackTrace) {
    crashlytics.recordError(error, stackTrace, fatal: true);
    return true;
  };

  logger.i('Crash reporting is on');
  return CrashlyticsReporter(crashlytics: crashlytics);
}
