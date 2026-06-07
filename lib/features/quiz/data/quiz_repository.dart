import 'package:edtech/features/quiz/data/quiz_api.dart';
import 'package:edtech/features/quiz/models/quiz_model.dart';
import 'package:edtech/features/quiz/models/quiz_result_model.dart';

abstract class QuizRepository {
  Future<QuizModel> getQuiz(String lessonId);
  Future<QuizResultModel> submitQuiz(String quizId, List<Map<String, String>> answers);
}

class QuizRepositoryImpl implements QuizRepository {
  final QuizApi api;

  QuizRepositoryImpl(this.api);

  @override
  Future<QuizModel> getQuiz(String lessonId) => api.getQuiz(lessonId);

  @override
  Future<QuizResultModel> submitQuiz(String quizId, List<Map<String, String>> answers) =>
      api.submitQuiz(quizId, answers);
}
