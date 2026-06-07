import 'package:edtech/core/utils/types.dart';
import 'package:edtech/features/courses/models/subscribe_model.dart';

import '../../../core/api/api_client.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/utils/my_logger.dart';
import '../models/course_details_model.dart';
import '../models/courses_model.dart';

class CoursesApi {
  final ApiClient api;

  CoursesApi(this.api);

  Future<CoursesModel> getAllCourses() async {
    logger.i("API getAllCourses started");

    return guard<CoursesModel>(() async {
      logger.i("Before GET /courses/");

      final response = await api.get('/courses/');

      logger.i("After GET /courses/: ${response.statusCode}");
      logger.i("Response data: ${response.data}");

      final result = CoursesModel.fromJson(response.data as Json);

      logger.i("Parsed courses");

      return result;
    });
  }

  Future<CourseDetailsModel> getCourseById(String courseId) async {
    return guard<CourseDetailsModel>(() async {
      final response = await api.get('/courses/$courseId');

      final result = CourseDetailsModel.fromJson(response.data as Json);

      return result;
    });
  }

  Future<SubscribeModel> subscribe(String courseId) async {
    return guard<SubscribeModel>(() async {
      final response = await api.post(
        '/courses/subscribe/',
        data: {"course_id": courseId},
      );

      final result = SubscribeModel.fromJson(response.data as Json);

      return result;
    });
  }

  Future<SubscribeModel> unsubscribe(String courseId) async {
    return guard<SubscribeModel>(() async {
      final response = await api.post(
        '/courses/unsubscribe/',
        data: {"course_id": courseId},
      );

      final result = SubscribeModel.fromJson(response.data as Json);
      return result;
    });
  }
}
