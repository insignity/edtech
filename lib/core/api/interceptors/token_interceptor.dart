import 'package:dio/dio.dart';
import 'package:edtech/core/services/session/session_events.dart';
import 'package:edtech/core/services/token/token_service.dart';

import '../../utils/my_logger.dart';

class TokenInterceptor implements Interceptor {
  final TokenService tokenService;
  final SessionEvents sessionEvents;

  // A separate bare Dio instance just for the refresh call — no interceptors
  // to avoid infinite loops if /token/refresh/ itself returns 401.
  final Dio _refreshDio;

  TokenInterceptor(
    this.tokenService, {
    required String baseUrl,
    required this.sessionEvents,
  }) : _refreshDio = Dio(BaseOptions(
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
      // With no token stored, send no header at all: 'Bearer null' is parsed
      // as an invalid token and answered with 401 even on public endpoints.
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
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

    // A 401 on a request that carried no token — login, register — is a verdict
    // on the credentials, not on an expired session. Don't refresh, and don't
    // kick the user to the login screen they are already standing on.
    if (err.requestOptions.extra['putToken'] != true ||
        err.requestOptions.headers['Authorization'] == null) {
      handler.next(err);
      return;
    }

    logger.w('401 received — attempting token refresh');

    final refreshToken = await tokenService.getRefresh();

    if (refreshToken == null || refreshToken.isEmpty) {
      logger.w('No refresh token — clearing session');
      await tokenService.deleteAll();
      sessionEvents.notifyExpired();
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
      sessionEvents.notifyExpired();
      handler.next(err);
    }
  }
}
