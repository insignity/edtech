import 'package:edtech/core/api/api_client.dart';
import 'package:edtech/core/services/token/token_service.dart';
import 'package:edtech/features/auth/data/auth_api.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/data/auth_repository.dart';

final sl = GetIt.instance;

void injectServiceLocator() {
  // external
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  //services
  sl.registerLazySingleton<TokenService>(() => TokenServiceImpl(sl()));

  //api
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient("http://45.12.231.230:8000/api", tokenService: sl()),
  );


  //repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl(), sl()));

  //bloc
  sl.registerFactory<AuthBloc>(() => AuthBloc(sl()));

//api
  sl.registerLazySingleton<AuthApi>(()=>AuthApi(sl(), sl()));
}
