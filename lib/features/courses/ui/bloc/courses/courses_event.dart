part of 'courses_bloc.dart';

@immutable
sealed class CoursesEvent {}

class CoursesFetchAll extends CoursesEvent {}
