import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'lesson_state.dart';

class LessonCubit extends Cubit<LessonState> {
  LessonCubit() : super(LessonInitial());
}
