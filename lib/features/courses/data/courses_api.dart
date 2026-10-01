import 'package:edtech/core/utils/types.dart';
import 'package:edtech/features/courses/models/lesson_model.dart';

import '../../../core/api/api_client.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/utils/my_logger.dart';
import '../models/course_details_model.dart';
import '../models/courses_model.dart';
import '../models/lesson_playback_model.dart';

class CoursesApi {
  final ApiClient api;

  CoursesApi(this.api);

  Future<CoursesModel> getAllCourses() async {
    return guard<CoursesModel>(() async {
      final response = await api.get('/courses/');
      final result = CoursesModel.fromJson(response.data as Json);
      logger.i('-> $result');
      return result;
    });
  }

  Future<CourseDetailsModel> getCourseById(String courseId) async {
    return guard<CourseDetailsModel>(() async {
      final response = await api.get('/courses/$courseId');
      final result = CourseDetailsModel.fromJson(response.data as Json);
      logger.i('-> $result');
      return result;
    });
  }

  /// Must be called fresh every time a lesson's video is opened — the signed
  /// URL it returns expires (900s by default) and is never cached or reused.
  Future<LessonPlaybackModel> getPlayback(String lessonId) async {
    return guard<LessonPlaybackModel>(() async {
      final response = await api.get('/lessons/$lessonId/playback/');
      final result = LessonPlaybackModel.fromJson(response.data as Json);
      logger.i('-> $result');
      return result;
    });
  }

  Future<void> completeLesson(String lessonId) async {
    return guard<void>(() async {
      await api.post('/lessons/$lessonId/complete/');
    });
  }

  Future<List<LessonModel>> getLessons(String courseId) async {
    return guard<List<LessonModel>>(() async {
      final response = await api.get('/lessons/', params: {'course': courseId});
      final data = response.data as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>;
      final result = results
          .map((e) => LessonModel.fromJson(e as Map<String, dynamic>))
          .toList();
      logger.i('-> ${result.length} lessons');
      return result;
    });
  }
}
