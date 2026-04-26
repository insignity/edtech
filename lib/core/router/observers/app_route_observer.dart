import 'package:flutter/material.dart';

import '../../utils/logger.dart';

class AppRouteObserver extends NavigatorObserver {
  void _log(String message) {
    logger.i('ROUTE: $message');
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    _log(
      'PUSH -> ${route.settings.name} '
      'from ${previousRoute?.settings.name}',
    );
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    _log(
      'POP <- ${route.settings.name} '
      'back to ${previousRoute?.settings.name}',
    );
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    _log(
      'REPLACE ${oldRoute?.settings.name} '
      '-> ${newRoute?.settings.name}',
    );
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    _log('REMOVE ${route.settings.name}');
  }
}
