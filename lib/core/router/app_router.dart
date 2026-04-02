import 'package:auto_route/auto_route.dart';

import '../../features/auth/presentation/pages/register_page.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter{

  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: RegisterRoute.page, initial: true)
  ];
}