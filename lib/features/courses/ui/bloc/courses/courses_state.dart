part of 'courses_bloc.dart';

@immutable
sealed class CoursesState {}

final class CoursesInitial extends CoursesState {}

final class CoursesLoading extends CoursesState {}

final class CoursesError extends CoursesState {
  final String error;

  CoursesError(this.error);
}

final class CoursesLoaded extends CoursesState {
  final CoursesModel courses;

  CoursesLoaded(this.courses);

  @override
  String toString() {
    return "CoursesLoaded(${courses.toString()})";
  }
}
