import 'package:edtech/features/quiz/data/quiz_repository.dart';
import 'package:edtech/features/quiz/models/quiz_model.dart';
import 'package:edtech/features/quiz/models/quiz_result_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

part 'quiz_event.dart';
part 'quiz_state.dart';

class QuizBloc extends Bloc<QuizEvent, QuizState> {
  final QuizRepository repository;

  QuizBloc(this.repository) : super(QuizInitial()) {
    on<QuizLoad>(_onLoad);
    on<QuizSelectAnswer>(_onSelectAnswer);
    on<QuizSubmit>(_onSubmit);
  }

  Future<void> _onLoad(QuizLoad event, Emitter<QuizState> emit) async {
    emit(QuizLoading());
    try {
      final quiz = await repository.getQuiz(event.lessonId);
      emit(QuizLoaded(quiz));
    } catch (e) {
      emit(QuizError(e.toString()));
    }
  }

  void _onSelectAnswer(QuizSelectAnswer event, Emitter<QuizState> emit) {
    if (state is! QuizLoaded) return;
    final current = state as QuizLoaded;
    final updated = Map<String, String>.from(current.selectedAnswers);
    updated[event.questionId] = event.optionId;
    emit(current.copyWith(selectedAnswers: updated));
  }

  Future<void> _onSubmit(QuizSubmit event, Emitter<QuizState> emit) async {
    if (state is! QuizLoaded) return;
    final current = state as QuizLoaded;
    emit(QuizSubmitting(current.quiz, current.selectedAnswers));

    try {
      final answers = current.selectedAnswers.entries
          .map((e) => {'question_id': e.key, 'option_id': e.value})
          .toList();

      final result = await repository.submitQuiz(event.quizId, answers);
      emit(QuizResult(result));
    } catch (e) {
      emit(QuizLoaded(current.quiz, selectedAnswers: current.selectedAnswers));
    }
  }
}
