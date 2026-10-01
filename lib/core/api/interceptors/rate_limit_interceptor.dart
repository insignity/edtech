import 'package:dio/dio.dart';
import 'package:edtech/core/api/rate_limit.dart';

import '../../utils/my_logger.dart';

/// Turns 429 into a typed failure and keeps the app off an endpoint the server
/// has already refused.
class RateLimitInterceptor extends Interceptor {
  final RateLimiter limiter;

  RateLimitInterceptor(this.limiter);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final key = RateLimiter.keyFor(options.method, options.path);
    final wait = limiter.remaining(key);
    if (wait == null) {
      handler.next(options);
      return;
    }

    // Rejected here, before the token interceptor spends a refresh on a call
    // that cannot succeed anyway.
    handler.reject(
      DioException(
        requestOptions: options,
        error: RateLimitException(wait),
        type: DioExceptionType.cancel,
      ),
    );
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final response = err.response;
    if (response?.statusCode != 429) {
      handler.next(err);
      return;
    }

    final retryAfter = _retryAfter(response!);
    final key = RateLimiter.keyFor(
      err.requestOptions.method,
      err.requestOptions.path,
    );
    limiter.record(key, retryAfter);
    logger.w('429 on $key — holding off for ${retryAfter.inSeconds}s');

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: response,
        error: RateLimitException(retryAfter),
        type: DioExceptionType.badResponse,
      ),
    );
  }

  /// `retry_after` in the body is the contract; the standard `Retry-After`
  /// header is honoured as a fallback, and a fixed minute when neither is
  /// readable.
  static Duration _retryAfter(Response response) {
    final data = response.data;
    final fromBody = data is Map ? data['retry_after'] : null;
    final seconds =
        _seconds(fromBody) ?? _seconds(response.headers.value('retry-after'));
    return seconds == null
        ? RateLimiter.fallbackCooldown
        : Duration(seconds: seconds);
  }

  static int? _seconds(Object? value) => switch (value) {
    int() => value > 0 ? value : null,
    num() => value > 0 ? value.round() : null,
    String() => _seconds(num.tryParse(value.trim())),
    _ => null,
  };
}
