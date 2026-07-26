import 'dart:async';

import 'package:edtech/core/router/observers/app_route_observer.dart';
import 'package:edtech/core/theme/app_themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/router/app_router.dart';
import 'core/services/session/session_events.dart';
import 'core/sl/injection.dart';
import 'core/utils/app_bloc_observer.dart';
import 'core/utils/my_logger.dart';
import 'features/auth/ui/bloc/auth_bloc.dart';
import 'features/courses/ui/bloc/course_details/course_details_bloc.dart';
import 'features/courses/ui/bloc/courses/courses_bloc.dart';
import 'features/courses/ui/bloc/lesson/lesson_bloc.dart';
import 'features/my_courses/ui/bloc/my_courses_bloc.dart';
import 'features/profile/ui/bloc/profile_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = AppBlocObserver();
  injectServiceLocator();

  logger.i("data");
  logger.d("data");
  logger.f("data");
  logger.t("data");
  logger.e("data");
  logger.w("data");

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<AuthBloc>()),
        BlocProvider(create: (_) => sl<ProfileBloc>()),
        BlocProvider(create: (_) => sl<CoursesBloc>()),
        BlocProvider(create: (_) => sl<CourseDetailsBloc>()),
        BlocProvider(create: (_) => sl<MyCoursesBloc>()),
        BlocProvider(create: (_) => sl<LessonBloc>()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _appRouter = AppRouter(sl());
  late final StreamSubscription<void> _sessionSubscription;

  @override
  void initState() {
    super.initState();
    // The route guard only runs on navigation, so a session that dies while the
    // user is already inside the app has to be handled from here — otherwise
    // they sit on a screen where every request 401s.
    _sessionSubscription = sl<SessionEvents>().onExpired.listen((_) {
      _appRouter.replaceAll([const LoginRoute()]);
    });
  }

  @override
  void dispose() {
    _sessionSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: AppThemes.mobile,
      routerConfig: _appRouter.config(
        navigatorObservers: () => [AppRouteObserver()],
      ),
    );
  }
}
