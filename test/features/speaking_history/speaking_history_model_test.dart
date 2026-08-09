import 'package:edtech/features/recording/models/speaking_attempt.dart';
import 'package:edtech/features/speaking_history/models/speaking_history.dart';
import 'package:flutter_test/flutter_test.dart';

/// Trimmed from the real `/me/speaking-history/` response.
const _page = {
  'count': 2,
  'next': null,
  'previous': null,
  'results': [
    {
      'id': '719733aa-e9ca-42dd-89ae-b51bbf96fbcc',
      'title': "Mia's Soccer Match",
      'level': 'upper-intermediate',
      'latest_attempt_at': '2026-08-02T14:59:01.670168Z',
      'attempts': [
        {
          'id': '3e8cfe19-76b9-4bdd-ab11-d4979e892267',
          'lesson_id': '719733aa-e9ca-42dd-89ae-b51bbf96fbcc',
          'attempt_number': 3,
          'status': 'completed',
          'duration_seconds': 59.62,
          'words_per_minute': 103.66,
          'overall_score': 80,
          'created_at': '2026-08-02T14:59:01.670168Z',
          'completed_at': '2026-08-02T14:59:15.849324Z',
        },
        {
          'id': '44f5a757-5ef6-4d85-822e-ebc72e82b974',
          'lesson_id': '719733aa-e9ca-42dd-89ae-b51bbf96fbcc',
          'attempt_number': 2,
          'status': 'completed',
          'duration_seconds': 80.13,
          'words_per_minute': 83.86,
          'overall_score': 76,
          'created_at': '2026-08-02T14:57:29.005512Z',
          'completed_at': '2026-08-02T14:57:43.642508Z',
        },
      ],
    },
    {
      'id': '9bb39e5e-8e1e-4ea6-b544-82705d1f144e',
      'title': 'Introduction to Conversational English',
      'level': 'beginner',
      'latest_attempt_at': '2026-07-29T16:57:13.543418Z',
      'attempts': <Map<String, dynamic>>[],
    },
  ],
};

void main() {
  group('SpeakingHistoryModel.fromJson', () {
    test('reads the envelope and every lesson', () {
      final page = SpeakingHistoryModel.fromJson(_page);

      expect(page.count, 2);
      expect(page.hasMore, isFalse);
      expect(page.lessons, hasLength(2));
      expect(page.lessons.first.title, "Mia's Soccer Match");
      expect(page.lessons.first.level, 'upper-intermediate');
      expect(
        page.lessons.first.latestAttemptAt,
        DateTime.utc(2026, 8, 2, 14, 59, 1, 670, 168),
      );
    });

    test('reports a further page when next is set', () {
      final page = SpeakingHistoryModel.fromJson({
        ..._page,
        'next': 'https://api.lingloop.org/api/me/speaking-history/?page=2',
      });

      expect(page.hasMore, isTrue);
    });

    test('survives an empty body', () {
      final page = SpeakingHistoryModel.fromJson(const {});

      expect(page.count, 0);
      expect(page.lessons, isEmpty);
      expect(page.hasMore, isFalse);
    });
  });

  group('SpeakingHistoryLesson', () {
    test('parses attempts into summaries', () {
      final lesson = SpeakingHistoryModel.fromJson(_page).lessons.first;

      expect(lesson.attempts, hasLength(2));
      expect(lesson.attempts.first.attemptNumber, 3);
      expect(lesson.attempts.first.status, SpeakingAttemptStatus.completed);
      expect(lesson.attempts.first.durationSeconds, 59.62);
      expect(lesson.attempts.first.wordsPerMinute, 103.66);
    });

    test('reports best, latest and delta from graded attempts', () {
      final lesson = SpeakingHistoryModel.fromJson(_page).lessons.first;

      expect(lesson.bestScore, 80);
      expect(lesson.latestScore, 80);
      expect(lesson.scoreDelta, 4);
    });

    test('leaves the score summary empty when nothing is graded', () {
      final lesson = SpeakingHistoryModel.fromJson(_page).lessons.last;

      expect(lesson.attempts, isEmpty);
      expect(lesson.bestScore, isNull);
      expect(lesson.latestScore, isNull);
      expect(lesson.scoreDelta, isNull);
    });

    test('skips ungraded attempts when picking the latest score', () {
      final lesson = SpeakingHistoryLesson.fromJson({
        'id': 'lesson-1',
        'title': 'In progress',
        'level': null,
        'latest_attempt_at': null,
        'attempts': [
          {
            'id': 'a2',
            'attempt_number': 2,
            'status': 'analyzing',
            'overall_score': null,
          },
          {
            'id': 'a1',
            'attempt_number': 1,
            'status': 'completed',
            'overall_score': 61,
          },
        ],
      });

      expect(lesson.latestScore, 61);
      expect(lesson.bestScore, 61);
      // One graded attempt is not enough to compare against.
      expect(lesson.scoreDelta, isNull);
      expect(lesson.latestAttemptAt, isNull);
    });
  });
}
