import 'package:dio/dio.dart';

import '../utils/types.dart';

class ApiClient{
  final Dio _dio;

  ApiClient(String baseUrl) : _dio = Dio(BaseOptions(baseUrl: baseUrl));

  Future<Response> get(String path, {Json? params, Json? data}) async {
    try{
      return await _dio.get(path, queryParameters: params, data: data);

    }on DioException catch(e){
      throw ApiException.fromDio(e);

    }
  }

  Future<Response> post(String path, {Json? params, Json? data}) async {
    try{
      return await _dio.post(path, queryParameters: params, data: data);
    }on DioException catch(e){
      throw ApiException.fromDio(e);
    }
  }
}

class ApiException implements Exception{
  final String? message;
  ApiException(this.message);

  factory ApiException.fromDio(DioException e){
    if(e.response != null){
      return ApiException('Error ${e.response?.statusCode}: ${e.response?.data}');
    }else{
      return ApiException(e.message);
    }
  }

  @override
  String toString()=> message ?? "Error: no message";
}