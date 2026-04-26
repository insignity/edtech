import 'package:dio/dio.dart';
import 'package:edtech/core/services/token/token_service.dart';

import '../../constants/constants.dart';
import '../../utils/logger.dart';

class TokenInterceptor implements Interceptor {
  final TokenService tokenService;

  TokenInterceptor(this.tokenService);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    logger.e("Token interceptor error: $err");
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra['putToken'] == true) {
      final token = await tokenService.getAccess();
      logger.i("token: $token");
      handler.next(options..headers.addAll({"Authorization": "Bearer $token"}));
    }
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    logger.i("Api response: $response");
  }
}
