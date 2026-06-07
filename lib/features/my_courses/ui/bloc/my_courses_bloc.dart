import 'package:edtech/features/courses/data/courses_repository.dart';
import 'package:edtech/features/courses/models/courses_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

part 'my_courses_event.dart';
part 'my_courses_state.dart';

class MyCoursesBloc extends Bloc<MyCoursesEvent, MyCoursesState> {
  final CoursesRepository repository;

  MyCoursesBloc(this.repository) : super(MyCoursesInitial()) {
    on<MyCoursesFetch>(_onFetch);
  }

  Future<void> _onFetch(
    MyCoursesFetch event,
    Emitter<MyCoursesState> emit,
  ) async {
    emit(MyCoursesLoading());
    try {
      final result = await repository.getMySubscriptions();
      emit(MyCoursesLoaded(result));
    } catch (e) {
      emit(MyCoursesError(e.toString()));
    }
  }
}
