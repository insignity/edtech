import 'package:dio/dio.dart';
import 'package:edtech/core/services/token/token_service.dart';

import '../../utils/my_logger.dart';

class TokenInterceptor implements Interceptor {
  final TokenService tokenService;

  TokenInterceptor(this.tokenService);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    logger.e("Token interceptor error: $err, $handler");
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra['putToken'] == true) {
      final token = await tokenService.getAccess();

      final newOptions = options
        ..headers.addAll({"Authorization": "Bearer $token"});

      logger.i("API request: $options");

      handler.next(newOptions);
    }
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    logger.i("API response: $response");

    handler.next(response);
  }
}
