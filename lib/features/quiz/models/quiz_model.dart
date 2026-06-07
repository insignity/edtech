class QuizOptionModel {
  final String id;
  final String text;

  QuizOptionModel({required this.id, required this.text});

  factory QuizOptionModel.fromJson(Map<String, dynamic> json) => QuizOptionModel(
        id: json['id'] as String,
        text: json['text'] as String,
      );
}

class QuizQuestionModel {
  final String id;
  final String text;
  final List<QuizOptionModel> options;

  QuizQuestionModel({required this.id, required this.text, required this.options});

  factory QuizQuestionModel.fromJson(Map<String, dynamic> json) => QuizQuestionModel(
        id: json['id'] as String,
        text: json['text'] as String,
        options: (json['options'] as List<dynamic>)
            .map((e) => QuizOptionModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class QuizModel {
  final String id;
  final String title;
  final String? description;
  final List<QuizQuestionModel> questions;

  QuizModel({
    required this.id,
    required this.title,
    required this.description,
    required this.questions,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) => QuizModel(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        questions: (json['questions'] as List<dynamic>)
            .map((e) => QuizQuestionModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
