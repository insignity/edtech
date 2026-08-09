import 'package:edtech/features/courses/data/services/lessons_store_service.dart';
import 'package:edtech/features/courses/models/courses_model.dart';
import 'package:edtech/features/courses/models/lesson_model.dart';
import 'package:edtech/features/courses/models/lesson_navigation.dart';

import '../models/course_details_model.dart';
import 'courses_api.dart';

abstract class CoursesRepository {
  Future<CoursesModel> getAllCourses();

  Future<CourseDetailsModel> getCourseById(String courseId);

  Future<List<LessonModel>> getLessons(String courseId);

  Future<void> completeLesson(String lessonId);

  LessonNavigation getLessonNavigation(String currentLessonId);
}

class CoursesRepositoryImpl implements CoursesRepository {
  final CoursesApi api;
  final LessonsStoreService lessonsStore;

  CoursesRepositoryImpl(this.api, this.lessonsStore);

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
  Future<List<LessonModel>> getLessons(String courseId) async {
    final lessons = await api.getLessons(courseId);
    lessonsStore.setLessons(lessons);
    return lessons;
  }

  @override
  Future<void> completeLesson(String lessonId) async {
    await api.completeLesson(lessonId);
    lessonsStore.markCompleted(lessonId);
  }

  @override
  LessonNavigation getLessonNavigation(String currentLessonId) {
    return lessonsStore.getLessonNavigation(currentLessonId);
  }
}
