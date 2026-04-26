import 'my_logger.dart';

abstract class ErrorHandler {
  static String _extractRoot(StackTrace stackTrace) {
    final lines = stackTrace.toString().split('\n');
    return lines.isNotEmpty ? lines.first : 'No stack trace';
  }
}

Future<T> guard<T>(Future<T> Function() action, {String? context}) async {
  try {
    return await action();
  } catch (error, stackTrace) {
    final root = ErrorHandler._extractRoot(stackTrace);

    logger.e("[ERROR] Root: $root", error: error, stackTrace: stackTrace);
    rethrow;
  }
}
