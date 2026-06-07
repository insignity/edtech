part of 'course_details_bloc.dart';

@immutable
sealed class CourseDetailsState {}

class CourseDetailsInitial extends CourseDetailsState {}

class CourseDetailsLoading extends CourseDetailsState {}

class CourseDetailsError extends CourseDetailsState {
  final String error;

  CourseDetailsError(this.error);
}

class CourseDetailsLoaded extends CourseDetailsState {
  final CourseDetailsModel course;

  CourseDetailsLoaded(this.course);
}
