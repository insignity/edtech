import 'package:edtech/core/api/api_client.dart';
import 'package:edtech/core/constants/constants.dart';
import 'package:edtech/core/router/guards/auth_guard.dart';
import 'package:edtech/core/services/crash/crash_reporter.dart';
import 'package:edtech/core/services/session/session_events.dart';
import 'package:edtech/core/services/token/token_service.dart';
import 'package:edtech/features/auth/data/auth_api.dart';
import 'package:edtech/features/courses/data/courses_api.dart';
import 'package:edtech/features/courses/data/courses_repository.dart';
import 'package:edtech/features/courses/data/services/lessons_store_service.dart';
import 'package:edtech/features/courses/ui/bloc/course_details/course_details_bloc.dart';
import 'package:edtech/features/profile/data/profile_api.dart';
import 'package:edtech/features/profile/data/profile_repository.dart';
import 'package:edtech/features/recording/data/recording_repository.dart';
import 'package:edtech/features/recording/data/services/audio_player_service.dart';
import 'package:edtech/features/recording/data/services/audio_recorder_service.dart';
import 'package:edtech/features/recording/data/services/audio_uploader.dart';
import 'package:edtech/features/recording/data/services/speaking_attempt_store.dart';
import 'package:edtech/features/recording/data/speaking_api.dart';
import 'package:edtech/features/recording/ui/bloc/recording_bloc.dart';
import 'package:edtech/features/speaking_history/data/speaking_history_repository.dart';
import 'package:edtech/features/speaking_history/ui/bloc/attempt_details_bloc.dart';
import 'package:edtech/features/speaking_history/ui/bloc/speaking_history_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/ui/bloc/auth_bloc.dart';
import '../../features/courses/ui/bloc/courses/courses_bloc.dart';
import '../../features/courses/ui/bloc/lesson/lesson_bloc.dart';
import '../../features/profile/ui/bloc/profile_bloc.dart';

final sl = GetIt.instance;

void injectServiceLocator(CrashReporter crashReporter) {
  // external
  sl.registerSingleton<CrashReporter>(crashReporter);
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  // router guards
  sl.registerLazySingleton<AuthGuard>(() => AuthGuard(sl()));

  //services
  sl.registerLazySingleton<TokenService>(() => TokenServiceImpl(sl()));
  sl.registerLazySingleton<SessionEvents>(() => SessionEvents());
  sl.registerLazySingleton<LessonsStoreService>(() => LessonsStoreService());

  // Graded attempts never change, so reopening one from history is served from
  // memory. Cleared on logout — it holds the learner's own transcripts.
  sl.registerLazySingleton<SpeakingAttemptStore>(() => SpeakingAttemptStore());

  // Recording owns native handles, so each screen gets its own instance and
  // disposes it when the bloc closes.
  sl.registerFactory<AudioRecorderService>(() => AudioRecorderServiceImpl());
  sl.registerFactory<AudioPlayerService>(() => AudioPlayerServiceImpl());

  // Uploads go straight to S3 on their own Dio — the app client would attach
  // the JWT and log the presigned URL.
  sl.registerLazySingleton<AudioUploader>(() => AudioUploaderImpl());

  //api
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(Constants.url, tokenService: sl(), sessionEvents: sl()),
  );

  //repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl(), sl(), sl()),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<CoursesRepository>(
    () => CoursesRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton<RecordingRepository>(
    () => RecordingRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton<SpeakingHistoryRepository>(
    () => SpeakingHistoryRepositoryImpl(sl(), sl()),
  );
  //bloc
  sl.registerFactory<AuthBloc>(() => AuthBloc(sl()));
  sl.registerFactory<ProfileBloc>(() => ProfileBloc(sl()));
  sl.registerFactory<CoursesBloc>(() => CoursesBloc(sl()));
  sl.registerFactory<CourseDetailsBloc>(() => CourseDetailsBloc(sl()));
  sl.registerFactory<LessonBloc>(() => LessonBloc(sl()));
  sl.registerFactory<RecordingBloc>(
    () => RecordingBloc(recorder: sl(), player: sl(), repository: sl()),
  );
  sl.registerFactory<SpeakingHistoryBloc>(() => SpeakingHistoryBloc(sl()));
  sl.registerFactory<AttemptDetailsBloc>(() => AttemptDetailsBloc(sl()));

  //api
  sl.registerLazySingleton<AuthApi>(() => AuthApi(sl()));
  sl.registerLazySingleton<ProfileApi>(() => ProfileApi(sl()));
  sl.registerLazySingleton<CoursesApi>(() => CoursesApi(sl()));
  sl.registerLazySingleton<SpeakingApi>(() => SpeakingApi(sl()));
}
