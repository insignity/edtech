import 'package:edtech/core/api/api_client.dart';
import 'package:edtech/core/constants/constants.dart';
import 'package:edtech/core/router/guards/auth_guard.dart';
import 'package:edtech/core/services/session/session_events.dart';
import 'package:edtech/core/services/token/token_service.dart';
import 'package:edtech/features/auth/data/auth_api.dart';
import 'package:edtech/features/courses/data/courses_api.dart';
import 'package:edtech/features/courses/data/courses_repository.dart';
import 'package:edtech/features/courses/data/services/lessons_store_service.dart';
import 'package:edtech/features/courses/ui/bloc/course_details/course_details_bloc.dart';
import 'package:edtech/features/profile/data/profile_api.dart';
import 'package:edtech/features/profile/data/profile_repository.dart';
import 'package:edtech/features/recording/data/fake_recording_repository.dart';
import 'package:edtech/features/recording/data/recording_repository.dart';
import 'package:edtech/features/recording/data/services/audio_player_service.dart';
import 'package:edtech/features/recording/data/services/audio_recorder_service.dart';
import 'package:edtech/features/recording/ui/bloc/recording_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/ui/bloc/auth_bloc.dart';
import '../../features/courses/ui/bloc/courses/courses_bloc.dart';
import '../../features/courses/ui/bloc/lesson/lesson_bloc.dart';
import '../../features/my_courses/ui/bloc/my_courses_bloc.dart';
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
  sl.registerLazySingleton<SessionEvents>(() => SessionEvents());
  sl.registerLazySingleton<LessonsStoreService>(() => LessonsStoreService());

  // Recording owns native handles, so each screen gets its own instance and
  // disposes it when the bloc closes.
  sl.registerFactory<AudioRecorderService>(() => AudioRecorderServiceImpl());
  sl.registerFactory<AudioPlayerService>(() => AudioPlayerServiceImpl());

  //api
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(Constants.url, tokenService: sl(), sessionEvents: sl()),
  );

  //repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<CoursesRepository>(
    () => CoursesRepositoryImpl(sl(), sl()),
  );
  // Simulated analysis — swap for RecordingRepositoryImpl once the API has an
  // endpoint for uploading a recording.
  sl.registerLazySingleton<RecordingRepository>(
    () => const FakeRecordingRepository(),
  );
  //bloc
  sl.registerFactory<AuthBloc>(() => AuthBloc(sl()));
  sl.registerFactory<ProfileBloc>(() => ProfileBloc(sl()));
  sl.registerFactory<CoursesBloc>(() => CoursesBloc(sl()));
  sl.registerFactory<CourseDetailsBloc>(() => CourseDetailsBloc(sl()));
  sl.registerFactory<MyCoursesBloc>(() => MyCoursesBloc(sl()));
  sl.registerFactory<LessonBloc>(() => LessonBloc(sl()));
  sl.registerFactory<RecordingBloc>(
    () => RecordingBloc(recorder: sl(), player: sl(), repository: sl()),
  );

  //api
  sl.registerLazySingleton<AuthApi>(() => AuthApi(sl()));
  sl.registerLazySingleton<ProfileApi>(() => ProfileApi(sl()));
  sl.registerLazySingleton<CoursesApi>(() => CoursesApi(sl()));
}
