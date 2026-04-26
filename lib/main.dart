import 'package:edtech/core/router/observers/app_route_observer.dart';
import 'package:edtech/core/theme/app_themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/router/app_router.dart';
import 'core/sl/injection.dart';
import 'core/utils/app_bloc_observer.dart';
import 'core/utils/my_logger.dart';
import 'features/auth/bloc/auth_bloc.dart';

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
      providers: [BlocProvider(create: (_) => sl<AuthBloc>())],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  final _appRouter = AppRouter();

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
