import 'package:auto_route/auto_route.dart';
import 'package:edtech/core/services/token/token_service.dart';

import '../app_router.dart';

class AuthGuard extends AutoRouteGuard {
  final TokenService tokenService;

  AuthGuard(this.tokenService);

  @override
  Future<void> onNavigation(
    NavigationResolver resolver,
    StackRouter router,
  ) async {
    // Presence of a token proves nothing — an expired one is still a string.
    final hasSession = await tokenService.hasValidSession();
    if (hasSession) {
      resolver.next();
    } else {
      await router.push(const LoginRoute());
      resolver.next(false);
    }
  }
}
