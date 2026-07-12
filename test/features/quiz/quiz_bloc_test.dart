import 'package:bloc_test/bloc_test.dart';
import 'package:edtech/features/quiz/bloc/quiz_bloc.dart';
import 'package:edtech/features/quiz/data/quiz_repository.dart';
import 'package:edtech/features/quiz/models/quiz_model.dart';
import 'package:edtech/features/quiz/models/quiz_result_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockQuizRepository extends Mock implements QuizRepository {}

QuizModel makeQuiz({int questionCount = 2}) {
  return QuizModel(
    id: 'quiz-1',
    title: 'Quiz',
    description: null,
    questions: List.generate(
      questionCount,
      (i) => QuizQuestionModel(
        id: 'q$i',
        text: 'Question $i',
        options: [
          QuizOptionModel(id: 'q$i-o1', text: 'Option 1'),
          QuizOptionModel(id: 'q$i-o2', text: 'Option 2'),
        ],
      ),
    ),
  );
}

QuizResultModel makeResult() {
  return QuizResultModel(
    quizId: 'quiz-1',
    score: 1,
    totalQuestions: 2,
    percent: 50,
    level: 'B1',
    answers: const [],
  );
}

void main() {
  late MockQuizRepository repository;

  setUp(() {
    repository = MockQuizRepository();
  });

  group('QuizLoad', () {
    blocTest<QuizBloc, QuizState>(
      'emits [Loading, Loaded] with empty answers',
      build: () {
        when(() => repository.getQuiz('lesson-1'))
            .thenAnswer((_) async => makeQuiz());
        return QuizBloc(repository);
      },
      act: (bloc) => bloc.add(QuizLoad('lesson-1')),
      expect: () => [
        isA<QuizLoading>(),
        isA<QuizLoaded>()
            .having((s) => s.quiz.id, 'quiz id', 'quiz-1')
            .having((s) => s.selectedAnswers, 'answers', isEmpty)
            .having((s) => s.allAnswered, 'allAnswered', isFalse),
      ],
    );

    blocTest<QuizBloc, QuizState>(
      'emits [Loading, Error] when quiz not found',
      build: () {
        when(() => repository.getQuiz(any())).thenThrow(Exception('404'));
        return QuizBloc(repository);
      },
      act: (bloc) => bloc.add(QuizLoad('lesson-1')),
      expect: () => [isA<QuizLoading>(), isA<QuizError>()],
    );
  });

  group('QuizSelectAnswer', () {
    blocTest<QuizBloc, QuizState>(
      'accumulates answers and reports allAnswered when complete',
      build: () => QuizBloc(repository),
      seed: () => QuizLoaded(makeQuiz()),
      act: (bloc) {
        bloc.add(QuizSelectAnswer('q0', 'q0-o1'));
        bloc.add(QuizSelectAnswer('q1', 'q1-o2'));
      },
      expect: () => [
        isA<QuizLoaded>()
            .having((s) => s.answeredCount, 'answered', 1)
            .having((s) => s.allAnswered, 'allAnswered', isFalse),
        isA<QuizLoaded>()
            .having((s) => s.answeredCount, 'answered', 2)
            .having((s) => s.allAnswered, 'allAnswered', isTrue),
      ],
    );

    blocTest<QuizBloc, QuizState>(
      'replaces answer when same question answered twice',
      build: () => QuizBloc(repository),
      seed: () => QuizLoaded(makeQuiz()),
      act: (bloc) {
        bloc.add(QuizSelectAnswer('q0', 'q0-o1'));
        bloc.add(QuizSelectAnswer('q0', 'q0-o2'));
      },
      expect: () => [
        isA<QuizLoaded>()
            .having((s) => s.selectedAnswers['q0'], 'answer', 'q0-o1'),
        isA<QuizLoaded>()
            .having((s) => s.selectedAnswers['q0'], 'answer', 'q0-o2')
            .having((s) => s.answeredCount, 'still one answer', 1),
      ],
    );
  });

  group('QuizSubmit', () {
    blocTest<QuizBloc, QuizState>(
      'emits [Submitting, Result] and sends answers in API format',
      build: () {
        when(() => repository.submitQuiz(any(), any()))
            .thenAnswer((_) async => makeResult());
        return QuizBloc(repository);
      },
      seed: () => QuizLoaded(
        makeQuiz(),
        selectedAnswers: const {'q0': 'q0-o1', 'q1': 'q1-o2'},
      ),
      act: (bloc) => bloc.add(QuizSubmit('quiz-1')),
      expect: () => [
        isA<QuizSubmitting>(),
        isA<QuizResult>()
            .having((s) => s.result.level, 'level', 'B1')
            .having((s) => s.result.percent, 'percent', 50),
      ],
      verify: (_) {
        final captured =
            verify(() => repository.submitQuiz('quiz-1', captureAny()))
                .captured
                .single as List<Map<String, String>>;
        expect(captured, hasLength(2));
        expect(captured.first, {'question_id': 'q0', 'option_id': 'q0-o1'});
      },
    );

    blocTest<QuizBloc, QuizState>(
      'returns to Loaded with answers preserved when submit fails',
      build: () {
        when(() => repository.submitQuiz(any(), any()))
            .thenThrow(Exception('network'));
        return QuizBloc(repository);
      },
      seed: () => QuizLoaded(
        makeQuiz(),
        selectedAnswers: const {'q0': 'q0-o1'},
      ),
      act: (bloc) => bloc.add(QuizSubmit('quiz-1')),
      expect: () => [
        isA<QuizSubmitting>(),
        isA<QuizLoaded>()
            .having((s) => s.selectedAnswers['q0'], 'answers kept', 'q0-o1'),
      ],
    );
  });
}
