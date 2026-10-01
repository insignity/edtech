import 'dart:convert';

import 'package:dio/dio.dart';

import '../../utils/my_logger.dart';

/// One line per request, response or error — method, path, status and the
/// redacted body in full (however long — never truncated). Headers are never
/// logged, since that is where the bearer token lives.
class HttpLogInterceptor extends Interceptor {
  static const _sensitiveKeys = {
    'password',
    'new_password',
    'access',
    'refresh',
    'authorization',
    'token',
  };

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    logger.i('→ ${options.method} ${options.uri.path}${_preview(options.data)}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final options = response.requestOptions;
    logger.i(
      '← ${options.method} ${options.uri.path} ${response.statusCode}'
      '${_preview(response.data)}',
    );
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final options = err.requestOptions;
    logger.e(
      '✗ ${options.method} ${options.uri.path} '
      '${err.response?.statusCode ?? err.type}${_preview(err.response?.data)}',
    );
    super.onError(err, handler);
  }

  String _preview(Object? data) {
    if (data == null) return '';
    final redacted = _redact(data);
    final text = redacted is String ? redacted : jsonEncode(redacted);
    return ' $text';
  }

  Object? _redact(Object? value) {
    if (value is Map) {
      return value.map(
        (key, v) => MapEntry(
          key,
          _sensitiveKeys.contains(key.toString().toLowerCase())
              ? '***'
              : _redact(v),
        ),
      );
    }
    if (value is List) return value.map(_redact).toList();
    return value;
  }
}
