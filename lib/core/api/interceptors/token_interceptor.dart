import 'package:dio/dio.dart';
import 'package:edtech/core/services/token/token_service.dart';

import '../../utils/my_logger.dart';

class TokenInterceptor implements Interceptor {
  final TokenService tokenService;

  // A separate bare Dio instance just for the refresh call — no interceptors
  // to avoid infinite loops if /token/refresh/ itself returns 401.
  final Dio _refreshDio;

  TokenInterceptor(this.tokenService, {required String baseUrl})
      : _refreshDio = Dio(BaseOptions(
          baseUrl: baseUrl,
          headers: {'Content-Type': 'application/json'},
        ));

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra['putToken'] == true) {
      final token = await tokenService.getAccess();
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    logger.w('401 received — attempting token refresh');

    final refreshToken = await tokenService.getRefresh();

    if (refreshToken == null || refreshToken.isEmpty) {
      logger.w('No refresh token — clearing session');
      await tokenService.deleteAll();
      handler.next(err);
      return;
    }

    try {
      final response = await _refreshDio.post(
        '/token/refresh/',
        data: {'refresh': refreshToken},
      );

      final newAccess = response.data['access'] as String;
      await tokenService.setAccess(newAccess);
      logger.i('Token refreshed successfully');

      // Retry the original request with the new access token
      final retryOptions = err.requestOptions;
      retryOptions.headers['Authorization'] = 'Bearer $newAccess';

      final retryResponse = await _refreshDio.fetch(retryOptions);
      handler.resolve(retryResponse);
    } catch (e) {
      logger.e('Token refresh failed — clearing session', error: e);
      await tokenService.deleteAll();
      handler.next(err);
    }
  }
}
