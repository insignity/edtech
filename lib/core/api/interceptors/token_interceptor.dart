import 'package:dio/dio.dart';
import 'package:edtech/core/services/token/token_service.dart';

import '../../utils/my_logger.dart';

class TokenInterceptor implements Interceptor {
  final TokenService tokenService;

  TokenInterceptor(this.tokenService);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    logger.e("ERROR Token interceptor", error: err);

    handler.next(err);
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    RequestOptions newOptions = options;
    if (options.extra['putToken'] == true) {
      final token = await tokenService.getAccess();

      options.headers.addAll({"Authorization": "Bearer $token"});
    }
    handler.next(newOptions);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    logger.i("RESPONSE: $response");

    handler.next(response);
  }
}
