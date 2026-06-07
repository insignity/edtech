import 'package:edtech/features/courses/models/lesson_model.dart';

class LessonNavigation {
  final LessonModel current;
  final LessonModel? previous;
  final LessonModel? next;

  LessonNavigation({required this.current, this.previous, this.next});
}
