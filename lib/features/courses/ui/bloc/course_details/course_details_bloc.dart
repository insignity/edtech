import 'package:edtech/features/courses/data/courses_repository.dart';
import 'package:edtech/features/courses/models/course_details_model.dart';
import 'package:edtech/features/courses/models/lesson_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

part 'course_details_event.dart';
part 'course_details_state.dart';

class CourseDetailsBloc extends Bloc<CourseDetailsEvent, CourseDetailsState> {
  final CoursesRepository repository;

  CourseDetailsBloc(this.repository) : super(CourseDetailsInitial()) {
    on<CourseDetailsFetch>(_onFetch);
  }

  Future<void> _onFetch(
    CourseDetailsFetch event,
    Emitter<CourseDetailsState> emit,
  ) async {
    emit(CourseDetailsLoading());
    try {
      final course = await repository.getCourseById(event.courseId);
      final lessons = await repository.getLessons(event.courseId);
      emit(CourseDetailsLoaded(course, lessons: lessons));
    } catch (e) {
      emit(CourseDetailsError(e.toString()));
    }
  }
}
