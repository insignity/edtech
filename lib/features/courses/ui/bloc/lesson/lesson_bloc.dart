import 'package:edtech/features/courses/data/courses_repository.dart';
import 'package:edtech/features/courses/models/lesson_navigation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

part 'lesson_event.dart';
part 'lesson_state.dart';

class LessonBloc extends Bloc<LessonEvent, LessonState> {
  final CoursesRepository repository;

  LessonBloc(this.repository) : super(LessonInitial()) {
    on<LessonLoad>(_onLoad);
    on<LessonComplete>(_onComplete);
  }

  Future<void> _onLoad(
    LessonLoad event,
    Emitter<LessonState> emit,
  ) async {
    try {
      final navigation = repository.getLessonNavigation(event.lessonId);
      emit(LessonLoaded(navigation));
    } catch (e) {
      emit(LessonError(e.toString()));
    }
  }

  Future<void> _onComplete(
    LessonComplete event,
    Emitter<LessonState> emit,
  ) async {
    if (state is! LessonLoaded) return;
    final current = state as LessonLoaded;

    // Show spinner on the button
    emit(LessonLoaded(current.navigation, isCompleting: true));

    try {
      await repository.completeLesson(event.lessonId);

      // Re-read from store — store is now updated with isCompleted: true
      final updatedNavigation = repository.getLessonNavigation(event.lessonId);
      emit(LessonLoaded(updatedNavigation));
    } catch (e) {
      // Revert spinner, keep original state
      emit(LessonLoaded(current.navigation));
    }
  }
}
