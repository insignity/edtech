import 'package:auto_route/auto_route.dart';
import 'package:edtech/core/router/guards/auth_guard.dart';
import 'package:flutter/material.dart';

import '../../features/auth/ui/login_page.dart';
import '../../features/auth/ui/register_page.dart';
import '../../features/courses/ui/pages/course_detail_page.dart';
import '../../features/courses/ui/pages/courses_page.dart';
import '../../features/my_courses/ui/pages/my_courses_page.dart';
import '../../features/nav_bar/pages/nav_bar_page.dart';
import '../../features/profile/ui/pages/profile_page.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  final AuthGuard authGuard;

  AppRouter(this.authGuard);

  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: RegisterRoute.page, path: '/register'),
    AutoRoute(page: LoginRoute.page, path: '/login'),
    AutoRoute(
      page: NavBarRoute.page,
      path: '/',
      guards: [authGuard],
      children: [
        AutoRoute(page: CoursesRoute.page, path: 'courses'),
        AutoRoute(page: CourseDetailsRoute.page, path: 'courses/:id'),
        AutoRoute(page: MyCoursesRoute.page, path: 'my_courses'),
        AutoRoute(page: ProfileRoute.page, path: 'profile'),
      ],
    ),
  ];
}
