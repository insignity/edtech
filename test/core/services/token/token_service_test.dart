import 'package:edtech/core/services/token/token_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'jwt_test.dart' show tokenExpiringIn;

class MockSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockSecureStorage storage;
  late TokenServiceImpl service;

  final live = tokenExpiringIn(const Duration(hours: 1));
  final stale = tokenExpiringIn(const Duration(hours: -1));

  setUp(() {
    storage = MockSecureStorage();
    service = TokenServiceImpl(storage);
  });

  void stubTokens({String? access, String? refresh}) {
    when(() => storage.read(key: 'access')).thenAnswer((_) async => access);
    when(() => storage.read(key: 'refresh')).thenAnswer((_) async => refresh);
  }

  group('hasValidSession', () {
    test('accepts a live access token', () async {
      stubTokens(access: live, refresh: stale);
      expect(await service.hasValidSession(), isTrue);
    });

    // The interceptor can trade a live refresh token for a new access one.
    test('accepts a stale access token when refresh is still live', () async {
      stubTokens(access: stale, refresh: live);
      expect(await service.hasValidSession(), isTrue);
    });

    test('rejects when both tokens are stale', () async {
      stubTokens(access: stale, refresh: stale);
      expect(await service.hasValidSession(), isFalse);
    });

    test('rejects when there is nothing stored', () async {
      stubTokens();
      expect(await service.hasValidSession(), isFalse);
    });

    test('rejects empty strings', () async {
      stubTokens(access: '', refresh: '');
      expect(await service.hasValidSession(), isFalse);
    });
  });

  // Regression: the guard used to rely on this, letting expired sessions
  // through to Home where every request then 401s.
  test('hasAccessToken still only checks presence', () async {
    stubTokens(access: stale);
    expect(await service.hasAccessToken(), isTrue);
    expect(await service.hasValidSession(), isFalse);
  });
}
