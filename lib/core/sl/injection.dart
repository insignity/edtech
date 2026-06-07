import 'package:edtech/core/api/api_client.dart';
import 'package:edtech/core/router/guards/auth_guard.dart';
import 'package:edtech/core/services/token/token_service.dart';
import 'package:edtech/features/auth/data/auth_api.dart';
import 'package:edtech/features/courses/data/courses_api.dart';
import 'package:edtech/features/courses/data/courses_repository.dart';
import 'package:edtech/features/courses/data/services/lessons_store_service.dart';
import 'package:edtech/features/courses/ui/bloc/course_details/course_details_bloc.dart';
import 'package:edtech/features/profile/data/profile_api.dart';
import 'package:edtech/features/profile/data/profile_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/ui/bloc/auth_bloc.dart';
import '../../features/courses/ui/bloc/courses/courses_bloc.dart';
import '../../features/profile/ui/bloc/profile_bloc.dart';

final sl = GetIt.instance;

void injectServiceLocator() {
  // external
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  // router guards
  sl.registerLazySingleton<AuthGuard>(() => AuthGuard(sl()));

  //services
  sl.registerLazySingleton<TokenService>(() => TokenServiceImpl(sl()));
  sl.registerLazySingleton<LessonsStoreService>(() => LessonsStoreService());

  //api
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient("http://45.12.231.230:8000/api", tokenService: sl()),
  );

  //repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<CoursesRepository>(
    () => CoursesRepositoryImpl(sl(), sl(), sl()),
  );
  //bloc
  sl.registerFactory<AuthBloc>(() => AuthBloc(sl()));
  sl.registerFactory<ProfileBloc>(() => ProfileBloc(sl()));
  sl.registerFactory<CoursesBloc>(() => CoursesBloc(sl()));
  sl.registerFactory<CourseDetailsBloc>(() => CourseDetailsBloc(sl()));

  //api
  sl.registerLazySingleton<AuthApi>(() => AuthApi(sl()));
  sl.registerLazySingleton<ProfileApi>(() => ProfileApi(sl(), sl()));
  sl.registerLazySingleton<CoursesApi>(() => CoursesApi(sl()));
}
