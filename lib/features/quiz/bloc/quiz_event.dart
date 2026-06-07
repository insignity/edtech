part of 'quiz_bloc.dart';

@immutable
sealed class QuizEvent {}

class QuizLoad extends QuizEvent {
  final String lessonId;
  QuizLoad(this.lessonId);
}

class QuizSelectAnswer extends QuizEvent {
  final String questionId;
  final String optionId;
  QuizSelectAnswer(this.questionId, this.optionId);
}

class QuizSubmit extends QuizEvent {
  final String quizId;
  QuizSubmit(this.quizId);
}
