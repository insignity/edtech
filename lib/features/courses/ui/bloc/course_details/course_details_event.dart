part of 'course_details_bloc.dart';

@immutable
sealed class CourseDetailsEvent {}

class CourseDetailsFetch extends CourseDetailsEvent {
  final String courseId;

  CourseDetailsFetch(this.courseId);
}
