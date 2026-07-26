import 'dart:convert';

/// Minimal JWT reader — the app only ever needs the expiry claim.
abstract class Jwt {
  /// Whether [token] is past its `exp` claim.
  ///
  /// A token we cannot read — empty, malformed, or without an `exp` — is
  /// reported as *not* expired: let the server be the judge and answer 401
  /// rather than logging someone out on a parsing quirk.
  static bool isExpired(
    String? token, {
    Duration leeway = const Duration(seconds: 10),
  }) {
    final expiry = expiryOf(token);
    if (expiry == null) return false;
    return DateTime.now().toUtc().add(leeway).isAfter(expiry);
  }

  static DateTime? expiryOf(String? token) {
    if (token == null || token.isEmpty) return null;

    final parts = token.split('.');
    if (parts.length != 3) return null;

    try {
      final payload = json.decode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      final exp = payload is Map ? payload['exp'] : null;
      if (exp is! int) return null;
      return DateTime.fromMillisecondsSinceEpoch(exp * 1000, isUtc: true);
    } catch (_) {
      return null;
    }
  }
}
