import 'package:dio/dio.dart';
import 'package:edtech/core/api/interceptors/token_interceptor.dart';
import 'package:edtech/core/services/token/token_service.dart';

import '../utils/types.dart';

class ApiClient {
  final Dio _dio;
  final TokenService _tokenService;

  ApiClient(String baseUrl, {required TokenService tokenService})
    : _tokenService = tokenService,
      _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {'Content-Type': 'application/json'},
        ),
      ) {
    _dio.interceptors.addAll([TokenInterceptor(_tokenService)]);
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
      throw ApiException.fromDio(e);
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
      throw ApiException.fromDio(e);
    }
  }
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
