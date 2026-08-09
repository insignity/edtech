import 'package:edtech/features/courses/models/course_details_model.dart';
import 'package:edtech/features/courses/models/lesson_model.dart';

LessonModel makeLesson({
  String id = 'lesson-1',
  String name = 'Lesson',
  bool isCompleted = false,
}) {
  return LessonModel(
    id: id,
    name: name,
    description: 'description',
    video: 'https://www.youtube.com/watch?v=abc12345678',
    previewUrl: null,
    course: 1,
    owner: 1,
    isCompleted: isCompleted,
  );
}

CourseDetailsModel makeCourse({String id = 'course-1'}) {
  return CourseDetailsModel(
    id: id,
    name: 'Course',
    description: 'description',
    previewUrl: null,
    lessonsCount: 0,
    lessons: const [],
  );
}
