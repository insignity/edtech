import 'package:auto_route/auto_route.dart';
import 'package:edtech/core/router/guards/auth_guard.dart';
import 'package:flutter/material.dart';

import '../../features/auth/ui/forgot_password_page.dart';
import '../../features/auth/ui/login_page.dart';
import '../../features/auth/ui/register_page.dart';
import '../../features/auth/ui/reset_password_page.dart';
import '../../features/courses/ui/pages/course_detail_page.dart';
import '../../features/courses/ui/pages/courses_page.dart';
import '../../features/courses/ui/pages/lesson_page.dart';
import '../../features/recording/models/retelling_result.dart';
import '../../features/recording/ui/pages/recording_page.dart';
import '../../features/recording/ui/pages/results_page.dart';
import '../../features/nav_bar/pages/nav_bar_page.dart';
import '../../features/profile/ui/pages/profile_page.dart';
import '../../features/speaking_history/ui/pages/attempt_details_page.dart';
import '../../features/speaking_history/ui/pages/speaking_history_page.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  final AuthGuard authGuard;

  AppRouter(this.authGuard);

  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: RegisterRoute.page, path: '/register'),
    AutoRoute(page: LoginRoute.page, path: '/login'),
    AutoRoute(page: ForgotPasswordRoute.page, path: '/forgot-password'),
    AutoRoute(page: ResetPasswordRoute.page, path: '/reset-password'),
    AutoRoute(page: CourseDetailsRoute.page, path: '/courses/:id'),
    AutoRoute(page: LessonRoute.page, path: '/lessons/:lessonId'),
    AutoRoute(page: RecordingRoute.page, path: '/lessons/:lessonId/recording'),
    AutoRoute(page: ResultsRoute.page, path: '/lessons/:lessonId/results'),
    AutoRoute(page: AttemptDetailsRoute.page, path: '/attempts/:attemptId'),
    AutoRoute(
      page: NavBarRoute.page,
      path: '/',
      guards: [authGuard],
      children: [
        AutoRoute(page: CoursesRoute.page, path: 'courses'),
        AutoRoute(page: SpeakingHistoryRoute.page, path: 'speaking-history'),
        AutoRoute(page: ProfileRoute.page, path: 'profile'),
      ],
    ),
  ];
}
