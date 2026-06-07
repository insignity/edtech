import 'package:edtech/core/router/observers/app_route_observer.dart';
import 'package:edtech/core/theme/app_themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/router/app_router.dart';
import 'core/sl/injection.dart';
import 'core/utils/app_bloc_observer.dart';
import 'core/utils/my_logger.dart';
import 'features/auth/ui/bloc/auth_bloc.dart';
import 'features/courses/ui/bloc/course_details/course_details_bloc.dart';
import 'features/courses/ui/bloc/courses/courses_bloc.dart';
import 'features/courses/ui/bloc/lesson/lesson_bloc.dart';
import 'features/my_courses/ui/bloc/my_courses_bloc.dart';
import 'features/quiz/bloc/quiz_bloc.dart';
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
        BlocProvider(create: (_) => sl<QuizBloc>()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  final _appRouter = AppRouter(sl());

  // This widget is the root of your application.
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
