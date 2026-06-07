part of 'lesson_bloc.dart';

@immutable
sealed class LessonState {}

final class LessonInitial extends LessonState {}

final class LessonLoaded extends LessonState {
  final LessonNavigation navigation;
  final bool isCompleting;

  LessonLoaded(this.navigation, {this.isCompleting = false});
}

final class LessonError extends LessonState {
  final String error;
  LessonError(this.error);
}
