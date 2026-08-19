import 'package:dio/dio.dart';
import 'package:edtech/core/api/interceptors/rate_limit_interceptor.dart';
import 'package:edtech/core/api/interceptors/token_interceptor.dart';
import 'package:edtech/core/api/rate_limit.dart';
import 'package:edtech/core/services/session/session_events.dart';
import 'package:edtech/core/services/token/token_service.dart';

import '../utils/types.dart';
import 'interceptors/curl_interceptor.dart';

class ApiClient {
  final Dio _dio;
  final TokenService _tokenService;
  final SessionEvents _sessionEvents;
  final RateLimiter _rateLimiter;

  ApiClient(
    String baseUrl, {
    required TokenService tokenService,
    required SessionEvents sessionEvents,
    required RateLimiter rateLimiter,
  }) : _tokenService = tokenService,
       _sessionEvents = sessionEvents,
       _rateLimiter = rateLimiter,
       _dio = Dio(
         BaseOptions(
           baseUrl: baseUrl,
           connectTimeout: const Duration(seconds: 10),
           receiveTimeout: const Duration(seconds: 10),
           headers: {'Content-Type': 'application/json'},
         ),
       ) {
    _dio.interceptors.addAll([
      // First in line: a request the server has already rate-limited should
      // never reach the token refresh or the wire.
      RateLimitInterceptor(_rateLimiter),
      TokenInterceptor(
        _tokenService,
        baseUrl: baseUrl,
        sessionEvents: _sessionEvents,
      ),
      CurlInterceptor(),
    ]);
  }

  Future<Response> get(
    String path, {
    Json? params,
    Json? data,
    bool putToken = true,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: params,
        data: data,
        options: Options(extra: {'putToken': putToken}),
      );
    } on DioException catch (e) {
      throw _translate(e);
    }
  }

  Future<Response> post(
    String path, {
    Json? params,
    Json? data,
    bool putToken = true,
  }) async {
    try {
      return await _dio.post(
        path,
        queryParameters: params,
        data: data,
        options: Options(extra: {'putToken': putToken}),
      );
    } on DioException catch (e) {
      throw _translate(e);
    }
  }

  Future<Response> delete(
    String path, {
    Json? params,
    Json? data,
    bool putToken = true,
  }) async {
    try {
      return await _dio.delete(
        path,
        queryParameters: params,
        data: data,
        options: Options(extra: {'putToken': putToken}),
      );
    } on DioException catch (e) {
      throw _translate(e);
    }
  }
}

/// A rate-limit rejection already carries text meant for the learner, so it is
/// passed through instead of being flattened into a generic API error.
Object _translate(DioException e) {
  final error = e.error;
  if (error is RateLimitException) return error;
  return ApiException.fromDio(e);
}

class ApiException implements Exception {
  final String? message;

  ApiException(this.message);

  factory ApiException.fromDio(DioException e) {
    if (e.response != null) {
      return ApiException(
        'Error ${e.response?.statusCode}: ${e.response?.data}',
      );
    } else {
      return ApiException(e.message);
    }
  }

  @override
  String toString() => message ?? "Error: no message";
}
