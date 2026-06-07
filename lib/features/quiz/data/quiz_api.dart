import 'package:edtech/core/api/api_client.dart';
import 'package:edtech/core/utils/error_handler.dart';
import 'package:edtech/core/utils/types.dart';
import 'package:edtech/features/quiz/models/quiz_model.dart';
import 'package:edtech/features/quiz/models/quiz_result_model.dart';

class QuizApi {
  final ApiClient api;

  QuizApi(this.api);

  Future<QuizModel> getQuiz(String lessonId) async {
    return guard<QuizModel>(() async {
      final response = await api.get('/lessons/$lessonId/quiz/');
      return QuizModel.fromJson(response.data as Json);
    });
  }

  Future<QuizResultModel> submitQuiz(
    String quizId,
    List<Map<String, String>> answers,
  ) async {
    return guard<QuizResultModel>(() async {
      final response = await api.post(
        '/quizzes/$quizId/submit/',
        data: {'answers': answers},
      );
      return QuizResultModel.fromJson(response.data as Json);
    });
  }
}
