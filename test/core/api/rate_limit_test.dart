import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:edtech/core/api/interceptors/rate_limit_interceptor.dart';
import 'package:edtech/core/api/rate_limit.dart';
import 'package:flutter_test/flutter_test.dart';

/// Answers 429 once, then whatever the endpoint would normally return, and
/// counts how often it was actually reached.
class _LimitingAdapter implements HttpClientAdapter {
  final Object? body;
  final Map<String, List<String>> headers;
  int calls = 0;
  bool limited = true;

  _LimitingAdapter({this.body, this.headers = const {}});

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    if (!limited) return ResponseBody.fromString('{}', 200, headers: _json);
    return ResponseBody.fromString(
      body == null ? '{}' : '$body',
      429,
      headers: {..._json, ...headers},
    );
  }

  static const Map<String, List<String>> _json = {
    Headers.contentTypeHeader: ['application/json'],
  };

  @override
  void close({bool force = false}) {}
}

Dio _dioWith(RateLimiter limiter, HttpClientAdapter adapter) =>
    Dio(BaseOptions(baseUrl: 'https://api.example.com'))
      ..httpClientAdapter = adapter
      ..interceptors.add(RateLimitInterceptor(limiter));

void main() {
  group('RateLimiter', () {
    test('holds an endpoint for the recorded window, then frees it', () {
      var now = DateTime(2026, 1, 1, 12);
      final limiter = RateLimiter(now: () => now);

      limiter.record('POST /a/', const Duration(seconds: 30));
      expect(limiter.remaining('POST /a/'), const Duration(seconds: 30));

      now = now.add(const Duration(seconds: 29));
      expect(limiter.remaining('POST /a/'), const Duration(seconds: 1));

      now = now.add(const Duration(seconds: 2));
      expect(limiter.remaining('POST /a/'), isNull);
    });

    test('keeps endpoints apart', () {
      final limiter = RateLimiter();
      limiter.record('POST /a/', const Duration(seconds: 30));

      expect(limiter.remaining('POST /b/'), isNull);
    });

    // An hour-long block from a bad header would wedge the app.
    test('caps an absurd cooldown', () {
      final limiter = RateLimiter();
      limiter.record('POST /a/', const Duration(days: 1));

      expect(limiter.remaining('POST /a/'), lessThanOrEqualTo(RateLimiter.maxCooldown));
    });

    group('keyFor', () {
      test('collapses identifiers so the limit follows the route', () {
        expect(
          RateLimiter.keyFor(
            'post',
            '/speaking-attempts/3f7a1b2c-4d5e-6f70-8192-a3b4c5d6e7f8/'
                'complete-upload/',
          ),
          'POST /speaking-attempts/*/complete-upload/',
        );
        expect(
          RateLimiter.keyFor('GET', '/lessons/42/speaking-attempts/'),
          'GET /lessons/*/speaking-attempts/',
        );
      });

      test('leaves ordinary path segments alone', () {
        expect(
          RateLimiter.keyFor('GET', '/me/speaking-history/'),
          'GET /me/speaking-history/',
        );
      });
    });
  });

  group('RateLimitException', () {
    test('phrases the wait for the learner', () {
      expect(
        const RateLimitException(Duration(seconds: 1)).message,
        'Too many requests. Please try again in 1 second.',
      );
      expect(
        const RateLimitException(Duration(seconds: 45)).message,
        contains('45 seconds'),
      );
      expect(
        const RateLimitException(Duration(minutes: 2)).message,
        contains('2 minutes'),
      );
      expect(
        const RateLimitException(Duration(hours: 1)).message,
        contains('1 hour'),
      );
    });
  });

  group('RateLimitInterceptor', () {
    test('turns 429 into a typed failure carrying retry_after', () async {
      final limiter = RateLimiter();
      final dio = _dioWith(
        limiter,
        _LimitingAdapter(body: '{"retry_after": 45}'),
      );

      final error = await dio
          .post<void>('/lessons/1/speaking-attempts/')
          .then<Object?>((_) => null, onError: (Object e) => e);

      expect(
        (error as DioException).error,
        isA<RateLimitException>().having(
          (e) => e.retryAfter,
          'retryAfter',
          const Duration(seconds: 45),
        ),
      );
    });

    test('blocks the next call without touching the network', () async {
      final limiter = RateLimiter();
      final adapter = _LimitingAdapter(body: '{"retry_after": 45}');
      final dio = _dioWith(limiter, adapter);

      await dio.post<void>('/x/').catchError((Object e) => throw e).catchError(
        (Object _) => Response<void>(requestOptions: RequestOptions(path: '/x/')),
      );
      expect(adapter.calls, 1);

      // Even with the server ready to answer, the cooldown short-circuits.
      adapter.limited = false;
      final second = await dio
          .post<void>('/x/')
          .then<Object?>((_) => null, onError: (Object e) => e);

      expect(adapter.calls, 1, reason: 'request must not reach the server');
      expect((second as DioException).error, isA<RateLimitException>());
    });

    test('falls back to the Retry-After header', () async {
      final limiter = RateLimiter();
      final dio = _dioWith(
        limiter,
        _LimitingAdapter(headers: {'retry-after': ['20']}),
      );

      final error = await dio
          .post<void>('/y/')
          .then<Object?>((_) => null, onError: (Object e) => e);

      expect(
        ((error as DioException).error as RateLimitException).retryAfter,
        const Duration(seconds: 20),
      );
    });

    test('falls back to a fixed minute when the server says nothing', () async {
      final limiter = RateLimiter();
      final dio = _dioWith(limiter, _LimitingAdapter());

      final error = await dio
          .post<void>('/z/')
          .then<Object?>((_) => null, onError: (Object e) => e);

      expect(
        ((error as DioException).error as RateLimitException).retryAfter,
        RateLimiter.fallbackCooldown,
      );
    });

    test('leaves other failures alone', () async {
      final limiter = RateLimiter();
      final dio = _dioWith(limiter, _LimitingAdapter()..limited = false);

      await expectLater(dio.post<void>('/ok/'), completes);
      expect(limiter.remaining(RateLimiter.keyFor('POST', '/ok/')), isNull);
    });
  });
}
