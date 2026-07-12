import 'package:edtech/features/quiz/models/quiz_model.dart';
import 'package:edtech/features/quiz/models/quiz_result_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QuizModel.fromJson', () {
    test('parses quiz with nested questions and options', () {
      final quiz = QuizModel.fromJson({
        'id': 'quiz-1',
        'title': 'Your English Level',
        'description': 'Take this test',
        'questions': [
          {
            'id': 'q1',
            'text': 'She ___ to the store.',
            'options': [
              {'id': 'o1', 'text': 'go'},
              {'id': 'o2', 'text': 'goes'},
            ],
          },
        ],
      });

      expect(quiz.id, 'quiz-1');
      expect(quiz.title, 'Your English Level');
      expect(quiz.questions, hasLength(1));
      expect(quiz.questions.first.options, hasLength(2));
      expect(quiz.questions.first.options.last.text, 'goes');
    });

    test('parses null description', () {
      final quiz = QuizModel.fromJson({
        'id': 'quiz-1',
        'title': 'Quiz',
        'description': null,
        'questions': const [],
      });

      expect(quiz.description, isNull);
      expect(quiz.questions, isEmpty);
    });
  });

  group('QuizResultModel.fromJson', () {
    test('parses result with answers including unanswered questions', () {
      final result = QuizResultModel.fromJson({
        'quiz_id': 'quiz-1',
        'score': 1,
        'total_questions': 2,
        'percent': 50,
        'level': 'A2',
        'answers': [
          {
            'question_id': 'q1',
            'question': 'She ___ to the store.',
            'selected_option_id': 'o2',
            'selected_option': 'goes',
            'correct_option': 'goes',
            'is_correct': true,
            'explanation': 'Third person singular.',
          },
          {
            'question_id': 'q2',
            'question': 'I have never ___ to Japan.',
            'selected_option_id': null,
            'selected_option': null,
            'correct_option': 'been',
            'is_correct': false,
            'explanation': 'Past participle of be.',
          },
        ],
      });

      expect(result.score, 1);
      expect(result.level, 'A2');
      expect(result.answers, hasLength(2));
      expect(result.answers.first.isCorrect, isTrue);
      expect(result.answers.last.selectedOption, isNull);
      expect(result.answers.last.correctOption, 'been');
    });
  });
}
