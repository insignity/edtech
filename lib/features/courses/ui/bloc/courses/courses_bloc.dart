import 'package:edtech/features/courses/data/courses_repository.dart';
import 'package:edtech/features/courses/models/courses_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

import '../../../../../core/utils/my_logger.dart';

part 'courses_event.dart';
part 'courses_state.dart';

class CoursesBloc extends Bloc<CoursesEvent, CoursesState> {
  final CoursesRepository repository;

  CoursesBloc(this.repository) : super(CoursesInitial()) {
    on<CoursesFetchAll>(_onFetchAll);
  }

  Future<void> _onFetchAll(
    CoursesFetchAll event,
    Emitter<CoursesState> emit,
  ) async {
    emit(CoursesLoading());
    logger.i("CoursesFetchAll started");

    try {
      final result = await repository.getAllCourses();

      emit(CoursesLoaded(result));
    } catch (e, st) {
      emit(CoursesError(e.toString()));
    }
  }
}
