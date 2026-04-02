import 'package:edtech/core/api/api_client.dart';
import 'package:edtech/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:edtech/features/auth/domain/repositories/auth_repository.dart';
import 'package:edtech/features/auth/domain/use_cases/login_use_case.dart';
import 'package:edtech/features/auth/domain/use_cases/register_use_case.dart';
import 'package:get_it/get_it.dart';

import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

final sl = GetIt.instance;

void injectServiceLocator() {
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient("http://45.12.231.230:8000/api"),
  );
  sl.registerFactory<AuthBloc>(() => AuthBloc(sl(), sl()));
  sl.registerLazySingleton<AuthRemoteDatasource>(
    () => AuthRemoteDatasourceImpl(sl()),
  );
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton<LoginUseCase>(() => LoginUseCase(sl()));
  sl.registerLazySingleton<RegisterUseCase>(() => RegisterUseCase(sl()));
}
