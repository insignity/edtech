part of 'my_courses_bloc.dart';

@immutable
sealed class MyCoursesState {}

final class MyCoursesInitial extends MyCoursesState {}

final class MyCoursesLoading extends MyCoursesState {}

final class MyCoursesError extends MyCoursesState {
  final String error;
  MyCoursesError(this.error);
}

final class MyCoursesLoaded extends MyCoursesState {
  final CoursesModel courses;
  MyCoursesLoaded(this.courses);
}
