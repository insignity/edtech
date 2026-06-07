import 'package:edtech/features/courses/models/lesson_navigation.dart';

import '../../models/lesson_model.dart';

class LessonsStoreService {
  List<LessonModel> _lessons = [];

  void setLessons(List<LessonModel> lessons) {
    _lessons = lessons;
  }

  LessonNavigation getLessonNavigation(String currentLessonId) {
    final index = _lessons.indexWhere((e) => e.id == currentLessonId);

    if (index == -1) {
      throw Exception('Lesson not found');
    }

    return LessonNavigation(
      current: _lessons[index],
      previous: index > 0 ? _lessons[index - 1] : null,
      next: index < _lessons.length - 1 ? _lessons[index + 1] : null,
    );
  }
}
