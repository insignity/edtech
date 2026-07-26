import 'dart:convert';

import 'package:edtech/core/services/token/jwt.dart';
import 'package:flutter_test/flutter_test.dart';

String tokenWith(Map<String, dynamic> payload) {
  String segment(Map<String, dynamic> value) =>
      base64Url.encode(utf8.encode(json.encode(value))).replaceAll('=', '');
  return '${segment({'alg': 'HS256'})}.${segment(payload)}.signature';
}

String tokenExpiringIn(Duration offset) => tokenWith({
  'exp': DateTime.now().toUtc().add(offset).millisecondsSinceEpoch ~/ 1000,
});

void main() {
  group('isExpired', () {
    test('reports a token past its exp claim', () {
      expect(Jwt.isExpired(tokenExpiringIn(const Duration(hours: -1))), isTrue);
    });

    test('accepts a token still within its lifetime', () {
      expect(Jwt.isExpired(tokenExpiringIn(const Duration(hours: 1))), isFalse);
    });

    test('treats a token expiring inside the leeway as already gone', () {
      expect(Jwt.isExpired(tokenExpiringIn(const Duration(seconds: 3))), isTrue);
    });

    // Unreadable tokens are the server's call, not ours — never log someone
    // out over a parsing quirk.
    test('does not report unreadable tokens as expired', () {
      expect(Jwt.isExpired(null), isFalse);
      expect(Jwt.isExpired(''), isFalse);
      expect(Jwt.isExpired('not-a-jwt'), isFalse);
      expect(Jwt.isExpired('a.b.c'), isFalse);
      expect(Jwt.isExpired(tokenWith({'sub': 'no-exp-claim'})), isFalse);
    });
  });

  group('expiryOf', () {
    test('reads the exp claim as UTC', () {
      final expiry = DateTime.utc(2030, 1, 1, 12);
      final token = tokenWith({
        'exp': expiry.millisecondsSinceEpoch ~/ 1000,
      });

      expect(Jwt.expiryOf(token), expiry);
    });

    test('returns null when there is nothing to read', () {
      expect(Jwt.expiryOf(null), isNull);
      expect(Jwt.expiryOf('garbage'), isNull);
      expect(Jwt.expiryOf(tokenWith({'exp': 'not-a-number'})), isNull);
    });
  });
}
