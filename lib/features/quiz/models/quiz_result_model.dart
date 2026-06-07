class QuizAnswerResult {
  final String questionId;
  final String question;
  final String? selectedOptionId;
  final String? selectedOption;
  final String correctOption;
  final bool isCorrect;
  final String explanation;

  QuizAnswerResult({
    required this.questionId,
    required this.question,
    required this.selectedOptionId,
    required this.selectedOption,
    required this.correctOption,
    required this.isCorrect,
    required this.explanation,
  });

  factory QuizAnswerResult.fromJson(Map<String, dynamic> json) => QuizAnswerResult(
        questionId: json['question_id'] as String,
        question: json['question'] as String,
        selectedOptionId: json['selected_option_id'] as String?,
        selectedOption: json['selected_option'] as String?,
        correctOption: json['correct_option'] as String,
        isCorrect: json['is_correct'] as bool,
        explanation: json['explanation'] as String,
      );
}

class QuizResultModel {
  final String quizId;
  final int score;
  final int totalQuestions;
  final int percent;
  final String level;
  final List<QuizAnswerResult> answers;

  QuizResultModel({
    required this.quizId,
    required this.score,
    required this.totalQuestions,
    required this.percent,
    required this.level,
    required this.answers,
  });

  factory QuizResultModel.fromJson(Map<String, dynamic> json) => QuizResultModel(
        quizId: json['quiz_id'] as String,
        score: json['score'] as int,
        totalQuestions: json['total_questions'] as int,
        percent: json['percent'] as int,
        level: json['level'] as String,
        answers: (json['answers'] as List<dynamic>)
            .map((e) => QuizAnswerResult.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
