
import 'package:edtech/core/constants/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class AppPrinter extends LogPrinter {
  @override
  List<String> log(LogEvent event) {
    return ["[${Constants.myapp}] ${event.message}"];
  }
}

// debugPrint chunks long strings instead of letting the platform console
// (Android logcat in particular) silently truncate them — needed since HTTP
// logs can carry a full, untruncated JSON body.
class _DebugPrintOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    for (final line in event.lines) {
      debugPrint(line);
    }
  }
}

Logger logger = Logger(
  filter: DevelopmentFilter(),
  level: Level.debug,
  printer: AppPrinter(),
  output: _DebugPrintOutput(),
);