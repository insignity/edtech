import 'package:edtech/features/courses/data/courses_repository.dart';
import 'package:edtech/features/courses/models/course_details_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

part 'course_details_event.dart';
part 'course_details_state.dart';

class CourseDetailsBloc extends Bloc<CourseDetailsEvent, CourseDetailsState> {
  final CoursesRepository repository;

  CourseDetailsBloc(this.repository) : super(CourseDetailsInitial()) {
    on<CourseDetailsEvent>((event, emit) async {
      if (event is CourseDetailsFetch) {
        emit(CourseDetailsLoading());
        try {
          final response = await repository.getCourseById(event.courseId);
          emit(CourseDetailsLoaded(response));
        } catch (e) {
          emit(CourseDetailsError(e.toString()));
        }
      } else if (event is CourseDetailsSubscribe) {
        if (state is CourseDetailsLoaded) {
          final oldState = state as CourseDetailsLoaded;
          emit(CourseDetailsLoading());
          try {
            final response = await repository.subscribe(oldState.course.id);
            emit(
              CourseDetailsLoaded(
                oldState.course.copyWith(isSubscribed: response.isSubscribed),
              ),
            );
          } catch (e) {
            emit(CourseDetailsError(e.toString()));
          }
        }
      } else if (event is CourseDetailsUnsubscribe) {
        if (state is CourseDetailsLoaded) {
          final oldState = state as CourseDetailsLoaded;
          emit(CourseDetailsLoading());
          try {
            final response = await repository.unsubscribe(oldState.course.id);
            emit(
              CourseDetailsLoaded(
                oldState.course.copyWith(isSubscribed: response.isSubscribed),
              ),
            );
          } catch (e) {
            emit(CourseDetailsError(e.toString()));
          }
        }
      }
    });
  }
}
