import 'package:edtech/features/auth/data/auth_repository.dart';
import 'package:edtech/features/courses/data/services/lessons_store_service.dart';
import 'package:edtech/features/courses/models/courses_model.dart';
import 'package:edtech/features/courses/models/lesson_navigation.dart';
import 'package:edtech/features/courses/models/subscribe_model.dart';

import '../models/course_details_model.dart';
import 'courses_api.dart';

abstract class CoursesRepository {
  Future<CoursesModel> getAllCourses();

  Future<CourseDetailsModel> getCourseById(String courseId);

  LessonNavigation getLessonNavigation(String currentLessonId);

  Future<SubscribeModel> subscribe(String courseId);

  Future<SubscribeModel> unsubscribe(String courseId);

  Future logout();
}

class CoursesRepositoryImpl implements CoursesRepository {
  final CoursesApi api;
  final LessonsStoreService lessonsStore;
  final AuthRepository authRepository;

  CoursesRepositoryImpl(this.api, this.lessonsStore, this.authRepository);

  @override
  Future<CoursesModel> getAllCourses() async {
    final result = await api.getAllCourses();
    return result;
  }

  @override
  Future<CourseDetailsModel> getCourseById(String courseId) async {
    final result = await api.getCourseById(courseId);
    return result;
  }

  @override
  LessonNavigation getLessonNavigation(String currentLessonId) {
    return lessonsStore.getLessonNavigation(currentLessonId);
  }

  @override
  Future<SubscribeModel> subscribe(String courseId) async {
    final result = await api.subscribe(courseId);

    return result;
  }

  @override
  Future<SubscribeModel> unsubscribe(String courseId) async {
    final result = await api.unsubscribe(courseId);

    return result;
  }

  @override
  Future<dynamic> logout() async {
    await authRepository.logout();
  }
}
