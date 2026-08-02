import 'dart:convert';

import 'package:edtech/features/recording/models/retelling_result.dart';
import 'package:edtech/features/recording/models/speaking_attempt.dart';
import 'package:flutter_test/flutter_test.dart';

const _feedback = {
  'overall_score': 84,
  'meaning_score': 90,
  'compression_score': 80,
  'clarity_score': 85,
  'grammar_score': 88,
  'vocabulary_score': 82,
  'fluency_score': 78,
  'covered_key_points': ['The customer orders coffee'],
  'missed_key_points': ['The customer chooses the size'],
  'unnecessary_details': <String>[],
  'corrections': [
    {
      'original': 'He order coffee',
      'corrected': 'He orders coffee',
      'explanation': 'Use -s with a third-person singular verb.',
    },
  ],
  'short_feedback': 'You communicated the main idea clearly.',
  'concise_version': 'The customer orders a medium coffee.',
  'next_goal': 'Retell the story in 45 seconds.',
};

const _metrics = {
  'duration_seconds': 40.0,
  'word_count': 10,
  'words_per_minute': 15.0,
  'filler_word_count': 1,
};

Map<String, dynamic> completedJson({Object? feedback, Object? metrics}) => {
  'id': 'c71110b4-5844-4b18-ac83-4e6dfc7a8244',
  'lesson_id': '82449eb8-b329-4ad9-ba15-0a71349309b9',
  'attempt_number': 2,
  'status': 'completed',
  'transcript': 'The customer entered the cafe and ordered coffee.',
  'metrics': metrics ?? _metrics,
  'comparison': {
    'previous_attempt_number': 1,
    'duration_delta_seconds': -5.0,
    'words_per_minute_delta': 4.5,
    'filler_word_count_delta': -2,
  },
  'feedback': feedback ?? _feedback,
  'error': null,
};

void main() {
  group('SpeakingAttempt', () {
    test('reads a completed attempt', () {
      final attempt = SpeakingAttempt.fromJson(completedJson());

      expect(attempt.status, SpeakingAttemptStatus.completed);
      expect(attempt.attemptNumber, 2);
      expect(attempt.feedback!.overallScore, 84);
      expect(attempt.feedback!.nextGoal, isNotEmpty);
      expect(
        attempt.feedback!.corrections.single.corrected,
        'He orders coffee',
      );
      expect(attempt.metrics!.wordsPerMinute, 15.0);
      expect(attempt.comparison!.fillerWordCountDelta, -2);
      expect(attempt.error, isNull);
      expect(attempt.upload, isNull);
    });

    test('reads nested objects delivered as JSON strings', () {
      // Swagger types metrics/comparison/feedback/error as plain strings, so
      // both shapes have to land the same way.
      final attempt = SpeakingAttempt.fromJson(
        completedJson(
          feedback: jsonEncode(_feedback),
          metrics: jsonEncode(_metrics),
        ),
      );

      expect(attempt.feedback!.overallScore, 84);
      expect(attempt.metrics!.durationSeconds, 40.0);
    });

    test('leaves a processing attempt without a result', () {
      final attempt = SpeakingAttempt.fromJson({
        'id': 'attempt-1',
        'lesson_id': 'lesson-1',
        'attempt_number': 1,
        'status': 'transcribing',
        'transcript': '',
        'metrics': null,
        'comparison': null,
        'feedback': null,
        'error': null,
      });

      expect(attempt.status, SpeakingAttemptStatus.transcribing);
      expect(attempt.status.isTerminal, isFalse);
      expect(attempt.feedback, isNull);
      expect(attempt.metrics, isNull);
    });

    test('reads a failure with its safe message', () {
      final attempt = SpeakingAttempt.fromJson({
        'id': 'attempt-1',
        'attempt_number': 1,
        'status': 'failed',
        'error': {
          'code': 'empty_transcript',
          'message': 'The recording did not contain recognizable speech.',
        },
      });

      expect(attempt.status.isTerminal, isTrue);
      expect(attempt.error!.code, 'empty_transcript');
      expect(
        attempt.error!.message,
        'The recording did not contain recognizable speech.',
      );
    });

    test('treats an unknown status as still in flight', () {
      final attempt = SpeakingAttempt.fromJson({
        'id': 'attempt-1',
        'attempt_number': 1,
        'status': 'queued_for_something_new',
      });

      expect(attempt.status, SpeakingAttemptStatus.created);
      expect(attempt.status.isTerminal, isFalse);
    });

    test('reads the presigned upload target off the create response', () {
      final attempt = SpeakingAttempt.fromJson({
        'id': 'attempt-1',
        'lesson_id': 'lesson-1',
        'attempt_number': 1,
        'status': 'created',
        'upload': {
          'url': 'https://bucket.s3.amazonaws.com/key?signature',
          'method': 'PUT',
          'headers': {'Content-Type': 'audio/mp4'},
          'expires_in': 900,
        },
      });

      expect(attempt.upload!.method, 'PUT');
      expect(attempt.upload!.headers['Content-Type'], 'audio/mp4');
      expect(attempt.upload!.expiresIn, 900);
    });
  });

  group('SpeakingAttemptSummary', () {
    test('tolerates the empty columns of an unfinished attempt', () {
      final summary = SpeakingAttemptSummary.fromJson({
        'id': 'attempt-1',
        'lesson_id': 'lesson-1',
        'attempt_number': 3,
        'status': 'transcribing',
        'duration_seconds': null,
        'words_per_minute': null,
        'overall_score': null,
        'created_at': '2026-07-27T02:30:00Z',
        'completed_at': null,
      });

      expect(summary.overallScore, isNull);
      expect(summary.durationSeconds, isNull);
      expect(summary.completedAt, isNull);
      expect(summary.createdAt, isNotNull);
    });
  });

  group('RetellingResult.fromAttempt', () {
    test('maps a graded attempt onto what the results screen shows', () {
      final result = RetellingResult.fromAttempt(
        SpeakingAttempt.fromJson(completedJson()),
        delta: 4,
      );

      expect(result.score, 84);
      expect(result.delta, 4);
      expect(result.fluency, 78);
      expect(result.grammar, 88);
      expect(result.vocabulary, 82);
      expect(result.wpm, 15);
      expect(result.feedback, 'You communicated the main idea clearly.');
      expect(result.transcript, contains('ordered coffee'));
      expect(result.corrections.single.wrong, 'He order coffee');
      expect(result.corrections.single.right, 'He orders coffee');
      expect(result.corrections.single.explanation, isNotEmpty);
    });
  });
}
