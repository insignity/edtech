import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/router/app_router.dart';
import 'core/sl/injection.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

void main() {
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
      routerConfig: _appRouter.config(),
    );
  }
}
