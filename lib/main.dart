import 'package:edtech/core/router/observers/app_route_observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/constants.dart';
import 'core/router/app_router.dart';
import 'core/sl/injection.dart';
import 'core/utils/app_bloc_observer.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = AppBlocObserver();
  injectServiceLocator();

  l.i("data");
  l.t("data");
  l.d("data");
  l.e("data");
  l.f("data");
  l.w("data");

  runApp(
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (_)=>sl<AuthBloc>()),
        ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {

  final _appRouter = AppRouter();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      routerConfig: _appRouter.config(
        navigatorObservers: ()=>[AppRouteObserver()],
      ),
    );
  }
}
