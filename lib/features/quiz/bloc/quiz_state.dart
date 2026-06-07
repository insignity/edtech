part of 'quiz_bloc.dart';

@immutable
sealed class QuizState {}

final class QuizInitial extends QuizState {}

final class QuizLoading extends QuizState {}

final class QuizLoaded extends QuizState {
  final QuizModel quiz;
  final Map<String, String> selectedAnswers; // questionId -> optionId

  QuizLoaded(this.quiz, {this.selectedAnswers = const {}});

  int get answeredCount => selectedAnswers.length;
  bool get allAnswered => selectedAnswers.length == quiz.questions.length;

  QuizLoaded copyWith({Map<String, String>? selectedAnswers}) => QuizLoaded(
        quiz,
        selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      );
}

final class QuizSubmitting extends QuizState {
  final QuizModel quiz;
  final Map<String, String> selectedAnswers;
  QuizSubmitting(this.quiz, this.selectedAnswers);
}

final class QuizResult extends QuizState {
  final QuizResultModel result;
  QuizResult(this.result);
}

final class QuizError extends QuizState {
  final String error;
  QuizError(this.error);
}
