/// Raised when the backend answers 429, and again — without touching the
/// network — for every call to the same endpoint until the cooldown runs out.
class RateLimitException implements Exception {
  final Duration retryAfter;

  const RateLimitException(this.retryAfter);

  /// Text meant for the learner, not the log.
  String get message {
    final seconds = retryAfter.inSeconds;
    if (seconds < 60) {
      return 'Too many requests. Please try again in $seconds '
          '${seconds == 1 ? 'second' : 'seconds'}.';
    }
    final minutes = retryAfter.inMinutes;
    if (minutes < 60) {
      return 'Too many requests. Please try again in $minutes '
          '${minutes == 1 ? 'minute' : 'minutes'}.';
    }
    final hours = retryAfter.inHours;
    return 'Too many requests. Please try again in $hours '
        '${hours == 1 ? 'hour' : 'hours'}.';
  }

  @override
  String toString() => message;
}

/// Remembers which endpoints are cooling down after a 429.
///
/// The backend caps several routes — registration, creating an attempt,
/// confirming an upload, polling status — so a rejection is recorded per
/// endpoint and every later call to it fails fast instead of spending another
/// request the server has already said it will refuse.
class RateLimiter {
  final DateTime Function() _now;
  final Map<String, DateTime> _blockedUntil = {};

  RateLimiter({DateTime Function()? now}) : _now = now ?? DateTime.now;

  /// Longest cooldown worth honouring; anything larger is almost certainly a
  /// misconfigured header and would otherwise wedge the app for hours.
  static const Duration maxCooldown = Duration(hours: 1);

  /// Used when the server says 429 without saying for how long.
  static const Duration fallbackCooldown = Duration(seconds: 60);

  /// How long the caller must wait, or null when the endpoint is free.
  Duration? remaining(String key) {
    final until = _blockedUntil[key];
    if (until == null) return null;

    final left = until.difference(_now());
    if (left <= Duration.zero) {
      _blockedUntil.remove(key);
      return null;
    }
    return left;
  }

  void record(String key, Duration retryAfter) {
    final capped = retryAfter > maxCooldown ? maxCooldown : retryAfter;
    if (capped <= Duration.zero) return;
    _blockedUntil[key] = _now().add(capped);
  }

  void clear() => _blockedUntil.clear();

  /// Groups requests by route rather than by URL.
  ///
  /// A limit on `/speaking-attempts/{id}/complete-upload/` applies to the
  /// endpoint, so identifiers in the path are collapsed — otherwise a fresh
  /// attempt id would look like an untouched endpoint and walk straight into
  /// the same rejection.
  static String keyFor(String method, String path) {
    final normalized = path
        .split('/')
        .map((segment) => _looksLikeId(segment) ? '*' : segment)
        .join('/');
    return '${method.toUpperCase()} $normalized';
  }

  static final RegExp _uuid = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-'
    r'[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  static bool _looksLikeId(String segment) {
    if (segment.isEmpty) return false;
    if (int.tryParse(segment) != null) return true;
    return _uuid.hasMatch(segment);
  }
}
