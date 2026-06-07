part of 'lesson_bloc.dart';

@immutable
sealed class LessonEvent {}

class LessonLoad extends LessonEvent {
  final String lessonId;
  LessonLoad(this.lessonId);
}

class LessonComplete extends LessonEvent {
  final String lessonId;
  LessonComplete(this.lessonId);
}
