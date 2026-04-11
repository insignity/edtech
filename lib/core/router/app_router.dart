import 'package:auto_route/auto_route.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: RegisterRoute.page, path: '/register'),
    AutoRoute(page: LoginRoute.page, path: '/login', initial: true),
    AutoRoute(page: ProfileRoute.page, path: '/profile'),
  ];
}
