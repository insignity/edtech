import 'package:dio/dio.dart';

import '../../utils/my_logger.dart';

class CurlInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final curl = StringBuffer();

    curl.write('curl -X ${options.method} ');

    options.headers.forEach((key, value) {
      curl.write("-H '$key: $value' ");
    });

    if (options.data != null) {
      curl.write("-d '${options.data}' ");
    }

    curl.write("'${options.uri}'");

    logger.i(curl.toString());

    super.onRequest(options, handler);
  }
}
