
import 'package:edtech/core/constants/constants.dart';
import 'package:logger/logger.dart';

class AppPrinter extends LogPrinter {
  @override
  List<String> log(LogEvent event) {
    return ["[${Constants.myapp}] ${event.message}"];
  }
}

Logger logger = Logger(
  filter: DevelopmentFilter(),
  level: Level.debug,
  printer: AppPrinter(),
);