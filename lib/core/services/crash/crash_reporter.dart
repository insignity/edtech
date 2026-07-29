import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Where uncaught failures go.
///
/// Behind an interface for two reasons: tests must not need a live Firebase
/// app, and the whole thing degrades to [NoopCrashReporter] when the project
/// has no Firebase configuration yet.
abstract class CrashReporter {
  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  });

  /// Breadcrumb attached to the next crash report.
  Future<void> log(String message);

  /// Ties reports to a user so a single account's crashes can be followed.
  Future<void> setUserId(String? id);

  Future<void> setCustomKey(String key, Object value);
}

class CrashlyticsReporter implements CrashReporter {
  final FirebaseCrashlytics _crashlytics;

  CrashlyticsReporter({FirebaseCrashlytics? crashlytics})
    : _crashlytics = crashlytics ?? FirebaseCrashlytics.instance;

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  }) => _crashlytics.recordError(
    error,
    stackTrace,
    reason: reason,
    fatal: fatal,
  );

  @override
  Future<void> log(String message) => _crashlytics.log(message);

  @override
  Future<void> setUserId(String? id) =>
      _crashlytics.setUserIdentifier(id ?? '');

  @override
  Future<void> setCustomKey(String key, Object value) =>
      _crashlytics.setCustomKey(key, value);
}

/// Swallows everything. Used in tests, and whenever Firebase failed to start —
/// a missing crash reporter must never be the thing that crashes the app.
class NoopCrashReporter implements CrashReporter {
  const NoopCrashReporter();

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  }) async {
    if (kDebugMode) {
      debugPrint('[crash-reporter disabled] $error');
    }
  }

  @override
  Future<void> log(String message) async {}

  @override
  Future<void> setUserId(String? id) async {}

  @override
  Future<void> setCustomKey(String key, Object value) async {}
}
